namespace PrabinBhusal.OdooIntegration;

table 50101 "Odoo Connection Setup"
{
    Caption = 'Odoo Connection Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Base URL"; Text[250])
        {
            Caption = 'Base URL';
            ExtendedDatatype = URL;
            ToolTip = 'Specifies the address of the Odoo server, for example https://mycompany.odoo.com.';

            trigger OnValidate()
            begin
                "Base URL" := CopyStr("Base URL".Trim().TrimEnd('/'), 1, MaxStrLen("Base URL"));
                if ("Base URL" <> '') and not ("Base URL".StartsWith('https://') or "Base URL".StartsWith('http://')) then
                    Error(InvalidUrlErr);
            end;
        }
        field(3; "Database Name"; Text[100])
        {
            Caption = 'Database Name';
            ToolTip = 'Specifies the name of the Odoo database.';
        }
        field(4; "Odoo User ID"; Integer)
        {
            Caption = 'Odoo User ID';
            MinValue = 0;
            ToolTip = 'Specifies the numeric ID of the Odoo user that the API key belongs to.';
        }
        field(5; "Batch Size"; Integer)
        {
            Caption = 'Batch Size';
            InitValue = 100;
            MaxValue = 1000;
            MinValue = 1;
            ToolTip = 'Specifies how many products are fetched from Odoo per request.';
        }
        field(10; "Last Sync At"; DateTime)
        {
            Caption = 'Last Sync At';
            Editable = false;
            ToolTip = 'Specifies when products were last synced from Odoo.';
        }
        field(11; "Last Sync Count"; Integer)
        {
            Caption = 'Last Sync Count';
            Editable = false;
            ToolTip = 'Specifies how many products the last sync fetched.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        DeleteApiKey();
    end;

    var
        ApiKeyStorageKeyTok: Label 'OdooApiKey', Locked = true;
        ApiKeyMissingErr: Label 'Enter the Odoo API key on the Odoo Connection Setup page.';
        InvalidUrlErr: Label 'The base URL must start with https:// or http://.';

    procedure InsertIfNotExists()
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert();
        end;
    end;

    procedure CheckComplete()
    begin
        TestField("Base URL");
        TestField("Database Name");
        TestField("Odoo User ID");
        TestField("Batch Size");
        if not HasApiKey() then
            Error(ApiKeyMissingErr);
    end;

    // The key never goes into a table field: it lives in isolated storage, encrypted when encryption is on
    [NonDebuggable]
    procedure SetApiKey(NewApiKey: SecretText)
    begin
        if NewApiKey.IsEmpty() then begin
            DeleteApiKey();
            exit;
        end;
        if EncryptionEnabled() then
            IsolatedStorage.SetEncrypted(ApiKeyStorageKeyTok, NewApiKey, DataScope::Company)
        else
            IsolatedStorage.Set(ApiKeyStorageKeyTok, NewApiKey, DataScope::Company);
    end;

    [NonDebuggable]
    procedure GetApiKey() ApiKey: SecretText
    begin
        if not IsolatedStorage.Get(ApiKeyStorageKeyTok, DataScope::Company, ApiKey) then
            Error(ApiKeyMissingErr);
    end;

    procedure HasApiKey(): Boolean
    begin
        exit(IsolatedStorage.Contains(ApiKeyStorageKeyTok, DataScope::Company));
    end;

    local procedure DeleteApiKey()
    begin
        if HasApiKey() then
            IsolatedStorage.Delete(ApiKeyStorageKeyTok, DataScope::Company);
    end;
}
