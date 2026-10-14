namespace PrabinBhusal.OdooIntegration;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Item;

codeunit 50101 "Odoo Item Sync"
{
    var
        OdooApiClient: Codeunit "Odoo API Client";
        AlreadyLinkedErr: Label 'Odoo product %1 is already linked to item %2.', Comment = '%1 = Odoo product ID, %2 = item number';
        CurrencyMismatchErr: Label 'The Odoo prices are in %1, but your local currency is %2. Convert the prices before creating the item.', Comment = '%1 = Odoo currency code, %2 = local currency code';
        ProgressMsg: Label 'Fetching products from Odoo...\Products received: #1######', Comment = '#1 = number of products received so far';

    procedure SyncItems() SyncedCount: Integer
    var
        OdooConnectionSetup: Record "Odoo Connection Setup";
        Products: JsonArray;
        Product: JsonToken;
        Progress: Dialog;
    begin
        OdooConnectionSetup.Get();
        OdooConnectionSetup.CheckComplete();
        if GuiAllowed() then
            Progress.Open(ProgressMsg);

        // Fetch in pages so a large catalogue doesn't run into request size or timeout limits
        repeat
            Products := FetchProductPage(SyncedCount, OdooConnectionSetup."Batch Size");
            foreach Product in Products do begin
                StageProduct(Product.AsObject());
                SyncedCount += 1;
            end;
            if GuiAllowed() then
                Progress.Update(1, SyncedCount);
        until Products.Count() < OdooConnectionSetup."Batch Size";

        if GuiAllowed() then
            Progress.Close();

        OdooConnectionSetup."Last Sync At" := CurrentDateTime();
        OdooConnectionSetup."Last Sync Count" := SyncedCount;
        OdooConnectionSetup.Modify();
    end;

    procedure CreateItem(var OdooItem: Record "Odoo Item")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Item: Record Item;
    begin
        if OdooItem."Item No." <> '' then
            Error(AlreadyLinkedErr, OdooItem."Odoo ID", OdooItem."Item No.");
        OdooItem.TestField(Name);

        GeneralLedgerSetup.Get();
        if (OdooItem."Currency Code" <> '') and (GeneralLedgerSetup."LCY Code" <> '') and (OdooItem."Currency Code" <> GeneralLedgerSetup."LCY Code") then
            Error(CurrencyMismatchErr, OdooItem."Currency Code", GeneralLedgerSetup."LCY Code");

        Item.Init();
        Item.Insert(true);
        Item.Validate(Description, CopyStr(OdooItem.Name, 1, MaxStrLen(Item.Description)));
        Item.Validate("Unit Price", OdooItem."Sales Price");
        Item.Validate("Unit Cost", OdooItem."Cost Price");
        Item.Modify(true);

        OdooItem."Item No." := Item."No.";
        OdooItem.Modify();
    end;

    local procedure FetchProductPage(Offset: Integer; Limit: Integer): JsonArray
    var
        Arguments: JsonArray;
        Domain: JsonArray;
        Fields: JsonArray;
        Options: JsonObject;
    begin
        Arguments.Add(Domain);

        Fields.Add('name');
        Fields.Add('default_code');
        Fields.Add('categ_id');
        Fields.Add('uom_id');
        Fields.Add('list_price');
        Fields.Add('standard_price');
        Fields.Add('currency_id');
        Fields.Add('volume');

        Options.Add('fields', Fields);
        Options.Add('offset', Offset);
        Options.Add('limit', Limit);
        // Fixed order, otherwise paging can skip or repeat records
        Options.Add('order', 'id');

        exit(OdooApiClient.ExecuteKw('product.template', 'search_read', Arguments, Options).AsArray());
    end;

    local procedure StageProduct(Product: JsonObject)
    var
        OdooItem: Record "Odoo Item";
        IsNew: Boolean;
        OdooId: Integer;
    begin
        OdooId := GetInteger(Product, 'id');
        IsNew := not OdooItem.Get(OdooId);
        if IsNew then begin
            OdooItem.Init();
            OdooItem."Odoo ID" := OdooId;
        end;

        OdooItem.Name := CopyStr(GetText(Product, 'name'), 1, MaxStrLen(OdooItem.Name));
        OdooItem."Internal Reference" := CopyStr(GetText(Product, 'default_code'), 1, MaxStrLen(OdooItem."Internal Reference"));
        OdooItem.Category := CopyStr(GetRelationName(Product, 'categ_id'), 1, MaxStrLen(OdooItem.Category));
        OdooItem."Unit of Measure" := CopyStr(GetRelationName(Product, 'uom_id'), 1, MaxStrLen(OdooItem."Unit of Measure"));
        OdooItem."Currency Code" := CopyStr(GetRelationName(Product, 'currency_id'), 1, MaxStrLen(OdooItem."Currency Code"));
        OdooItem."Sales Price" := GetDecimal(Product, 'list_price');
        OdooItem."Cost Price" := GetDecimal(Product, 'standard_price');
        OdooItem.Volume := GetDecimal(Product, 'volume');
        OdooItem."Last Synced At" := CurrentDateTime();
        if IsNew then
            OdooItem.Insert()
        else
            OdooItem.Modify();
    end;

    local procedure GetText(Product: JsonObject; FieldName: Text): Text
    var
        ValueToken: JsonToken;
    begin
        if not TryGetValue(Product, FieldName, ValueToken) then
            exit('');
        exit(ValueToken.AsValue().AsText());
    end;

    local procedure GetDecimal(Product: JsonObject; FieldName: Text): Decimal
    var
        ValueToken: JsonToken;
    begin
        if not TryGetValue(Product, FieldName, ValueToken) then
            exit(0);
        exit(ValueToken.AsValue().AsDecimal());
    end;

    local procedure GetInteger(Product: JsonObject; FieldName: Text): Integer
    var
        ValueToken: JsonToken;
    begin
        if not TryGetValue(Product, FieldName, ValueToken) then
            exit(0);
        exit(ValueToken.AsValue().AsInteger());
    end;

    // Many2one fields come back as [id, "display name"], or false when empty
    local procedure GetRelationName(Product: JsonObject; FieldName: Text): Text
    var
        FieldToken: JsonToken;
        NameToken: JsonToken;
    begin
        if not Product.Get(FieldName, FieldToken) then
            exit('');
        if not FieldToken.IsArray() then
            exit('');
        if not FieldToken.AsArray().Get(1, NameToken) then
            exit('');
        exit(NameToken.AsValue().AsText());
    end;

    // Odoo sends false instead of null for empty fields
    local procedure TryGetValue(Product: JsonObject; FieldName: Text; var ValueToken: JsonToken): Boolean
    var
        RawValue: Text;
    begin
        if not Product.Get(FieldName, ValueToken) then
            exit(false);
        if not ValueToken.IsValue() then
            exit(false);
        if ValueToken.AsValue().IsNull() then
            exit(false);
        ValueToken.WriteTo(RawValue);
        exit(RawValue <> 'false');
    end;
}
