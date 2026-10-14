namespace PrabinBhusal.OdooIntegration;

page 50102 "Odoo Connection Setup"
{
    ApplicationArea = All;
    Caption = 'Odoo Connection Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Odoo Connection Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(Connection)
            {
                Caption = 'Connection';

                field("Base URL"; Rec."Base URL")
                {
                }
                field("Database Name"; Rec."Database Name")
                {
                }
                field("Odoo User ID"; Rec."Odoo User ID")
                {
                }
                field(ApiKey; ApiKeyText)
                {
                    Caption = 'API Key';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the Odoo API key of the user. It is stored in isolated storage, not in the database table.';

                    trigger OnValidate()
                    begin
                        Rec.SetApiKey(ApiKeyText);
                    end;
                }
            }
            group(Sync)
            {
                Caption = 'Sync';

                field("Batch Size"; Rec."Batch Size")
                {
                }
                field("Last Sync At"; Rec."Last Sync At")
                {
                }
                field("Last Sync Count"; Rec."Last Sync Count")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TestConnection)
            {
                Caption = 'Test Connection';
                Image = Approve;
                ToolTip = 'Check that Business Central can reach Odoo with these settings.';

                trigger OnAction()
                var
                    OdooApiClient: Codeunit "Odoo API Client";
                begin
                    CurrPage.SaveRecord();
                    Message(ConnectedMsg, OdooApiClient.TestConnection());
                end;
            }
        }
        area(Promoted)
        {
            actionref(TestConnection_Promoted; TestConnection)
            {
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InsertIfNotExists();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        // Show that a key is stored without ever reading it back
        Clear(ApiKeyText);
        if Rec.HasApiKey() then
            ApiKeyText := '********';
    end;

    var
        [NonDebuggable]
        ApiKeyText: Text;
        ConnectedMsg: Label 'Connected to Odoo. %1 products are available to sync.', Comment = '%1 = number of products in Odoo';
}
