namespace PrabinBhusal.OdooIntegration;

using Microsoft.Inventory.Item;

page 50100 "Odoo Item List"
{
    ApplicationArea = All;
    Caption = 'Odoo Items';
    CardPageId = "Odoo Item Card";
    Editable = false;
    PageType = List;
    SourceTable = "Odoo Item";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Products)
            {
                field("Odoo ID"; Rec."Odoo ID")
                {
                }
                field(Name; Rec.Name)
                {
                }
                field("Internal Reference"; Rec."Internal Reference")
                {
                }
                field(Category; Rec.Category)
                {
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                }
                field("Sales Price"; Rec."Sales Price")
                {
                }
                field("Cost Price"; Rec."Cost Price")
                {
                }
                field("Currency Code"; Rec."Currency Code")
                {
                }
                field("Item No."; Rec."Item No.")
                {
                }
                field("Last Synced At"; Rec."Last Synced At")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SyncFromOdoo)
            {
                Caption = 'Sync from Odoo';
                Image = Refresh;
                ToolTip = 'Fetch all products from Odoo and update this list.';

                trigger OnAction()
                var
                    OdooItemSync: Codeunit "Odoo Item Sync";
                begin
                    Message(SyncDoneMsg, OdooItemSync.SyncItems());
                end;
            }
            action(CreateItem)
            {
                Caption = 'Create Item';
                Image = NewItem;
                ToolTip = 'Create a Business Central item from the selected Odoo product.';

                trigger OnAction()
                var
                    Item: Record Item;
                    OdooItemSync: Codeunit "Odoo Item Sync";
                begin
                    OdooItemSync.CreateItem(Rec);
                    CurrPage.Update(false);
                    Item.Get(Rec."Item No.");
                    Page.Run(Page::"Item Card", Item);
                end;
            }
        }
        area(Navigation)
        {
            action(ConnectionSetup)
            {
                Caption = 'Connection Setup';
                Image = Setup;
                RunObject = page "Odoo Connection Setup";
                ToolTip = 'Set up the connection to your Odoo server.';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(SyncFromOdoo_Promoted; SyncFromOdoo)
                {
                }
                actionref(CreateItem_Promoted; CreateItem)
                {
                }
            }
        }
    }

    var
        SyncDoneMsg: Label '%1 products synced from Odoo.', Comment = '%1 = number of products';
}
