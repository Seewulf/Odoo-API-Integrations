page 50100 "Odoo Item List"
{
    Caption = 'Odoo Item Lists';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "Odoo Item Card";
    SourceTable = "Odoo Items";
    Editable = false;


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Item Code"; Rec."Item Code")
                {
                    Caption = 'Item Code';
                    ApplicationArea = All;
                }
                field("Item Name"; Rec."Item Name")
                {
                    Caption = 'Item Name';
                    ApplicationArea = All;
                }
                field(Category; Rec.Category)
                {
                    Caption = 'Item Category';
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                    ApplicationArea = All;
                }

                field("Currency ID"; Rec."Currency ID")
                {
                    Caption = 'Currency';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(FetchOdooItems)
            {
                Caption = 'Fetch Items from Odoo';
                PromotedCategory = Process;
                PromotedIsBig = true;
                Promoted = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    OdooAPIMgt: Codeunit "Odoo API Management";
                begin
                    OdooAPIMgt.FetchItemsFromOdoo();
                end;
            }
        }
    }

    var
        myInt: Integer;


}