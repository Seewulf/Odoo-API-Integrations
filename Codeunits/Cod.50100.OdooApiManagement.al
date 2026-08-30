codeunit 50100 "Odoo API Management"
{
    procedure FetchItemsFromOdoo()
    var
        OdooSetup: Record "Company Information";
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestContent: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestBody: JsonObject;
        Params: JsonObject;
        Args: JsonArray;
        Domain: JsonArray;
        FieldsObj: JsonObject;
        FieldsArr: JsonArray;
        BodyText: Text;
        ResponsePayload: Text;
    begin
        OdooSetup.Get();

        // Build the fields + limit options
        FieldsArr.Add('name');
        FieldsArr.Add('id');
        FieldsArr.Add('list_price');
        FieldsArr.Add('volume');
        FieldsArr.Add('standard_price');
        FieldsArr.Add('currency_id');
        FieldsArr.Add('uom_name');
        FieldsArr.Add('seller_ids');
        FieldsArr.Add('categ_id');
        FieldsObj.Add('fields', FieldsArr);
        FieldsObj.Add('limit', 100);

        // Build args: db, uid, api_key, model, method, domain, options
        Args.Add(OdooSetup."Database Name");
        Args.Add(OdooSetup."User UID");
        Args.Add(OdooSetup."API Key");
        Args.Add('product.template');
        Args.Add('search_read');
        Args.Add(Domain); // empty = no filter
        Args.Add(FieldsObj);

        Params.Add('service', 'object');
        Params.Add('method', 'execute_kw');
        Params.Add('args', Args);

        RequestBody.Add('jsonrpc', '2.0');
        RequestBody.Add('method', 'call');
        RequestBody.Add('params', Params);
        RequestBody.WriteTo(BodyText);

        // Odoo's JSON-RPC endpoint: single URL, POST, no auth header
        RequestContent.WriteFrom(BodyText);
        RequestContent.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');

        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(OdooSetup."Odoo Base URL" + '/jsonrpc');
        RequestMessage.Content := RequestContent;

        // Message('About to call: %1', OdooSetup."Odoo Base URL" + '/jsonrpc');
        // if not Client.Send(RequestMessage, ResponseMessage) then
        //     Error('Send failed. GetLastErrorText: %1', GetLastErrorText());
        if not Client.Send(RequestMessage, ResponseMessage) then
            Error('Failed to establish network connection with Odoo.');

        if not ResponseMessage.IsSuccessStatusCode() then
            Error('API Error: %1', ResponseMessage.HttpStatusCode());

        ResponseMessage.Content().ReadAs(ResponsePayload);
        ParseAndStage(ResponsePayload);
    end;

    local procedure ParseAndStage(Payload: Text)
    var
        OdooItems: Record "Odoo Items";
        ResponseJson: JsonObject;
        ResultToken: JsonToken;
        ErrorToken: JsonToken;
        ResultArray: JsonArray;
        JToken: JsonToken;
        JObject: JsonObject;
        ValToken: JsonToken;
        RecordCount: Integer;
    begin
        if not ResponseJson.ReadFrom(Payload) then
            Error('Invalid JSON received from Odoo.');

        if ResponseJson.Get('error', ErrorToken) then
            Error('Odoo returned an error: %1', Format(ErrorToken));

        if not ResponseJson.Get('result', ResultToken) then
            Error('Unexpected response shape from Odoo: no result field.');

        ResultArray := ResultToken.AsArray();

        foreach JToken in ResultArray do begin
            JObject := JToken.AsObject();
            OdooItems.Init();

            if JObject.Get('id', ValToken) then
                if not ValToken.AsValue().IsNull() then
                    OdooItems."Item Code" := ValToken.AsValue().AsInteger();

            if JObject.Get('name', ValToken) then
                OdooItems."Item Name" := CopyStr(ValToken.AsValue().AsText(), 1, MaxStrLen(OdooItems."Item Name"));

            if JObject.Get('list_price', ValToken) then
                OdooItems."Sales Price" := ValToken.AsValue().AsDecimal();

            if JObject.Get('standard_price', ValToken) then
                OdooItems."Cost Price" := ValToken.AsValue().AsDecimal();
            if JObject.Get('volume', ValToken) then
                OdooItems.Quantity := ValToken.AsValue().AsDecimal();
            if JObject.Get('seller_ids', ValToken) then
                OdooItems."Vendor ID" := CopyStr(Format(ValToken), 1, MaxStrLen(OdooItems."Vendor ID"));
            if JObject.Get('uom_name', ValToken) then
                OdooItems."Unit of Measure" := CopyStr(Format(ValToken), 1, MaxStrLen(OdooItems."Unit of Measure"));
            if JObject.Get('currency_id', ValToken) then
                OdooItems."Currency ID" := CopyStr(Format(ValToken), 1, MaxStrLen(OdooItems."Currency ID"));
            if JObject.Get('categ_id', ValToken) then
                OdooItems.Category := CopyStr(Format(ValToken), 1, MaxStrLen(OdooItems.Category));


            if OdooItems.Get(OdooItems."Item Code") then
                OdooItems.Modify()
            else
                OdooItems.Insert();

            RecordCount += 1;
        end;

        Message('Sync complete: %1 records staged.', RecordCount);
    end;
}