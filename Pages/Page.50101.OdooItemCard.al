page 50101 "Odoo Item Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = "Odoo Items";


    layout
    {
        area(Content)
        {
            group(General)
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
                field(Quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                    ApplicationArea = All;

                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    Caption = 'Unit of Measures';
                    ApplicationArea = All;

                }
                field("Sales Price"; Rec."Sales Price")
                {
                    Caption = 'Sales Price';
                    ApplicationArea = All;

                }
                field("Cost Price"; Rec."Cost Price")
                {
                    Caption = 'Cost Price';
                    ApplicationArea = All;
                }
                field("Currency ID"; Rec."Currency ID")
                {
                    Caption = 'Currency ID';
                    ApplicationArea = All;
                }
                field(Category; Rec.Category)
                {
                    Caption = 'Item Category';
                    ApplicationArea = All;
                }
                field("Vendor ID"; Rec."Vendor ID")
                {
                    Caption = 'Vendor ID';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}