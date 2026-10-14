namespace PrabinBhusal.OdooIntegration;

page 50101 "Odoo Item Card"
{
    ApplicationArea = All;
    Caption = 'Odoo Item Card';
    Editable = false;
    PageType = Card;
    SourceTable = "Odoo Item";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

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
                field(Volume; Rec.Volume)
                {
                }
            }
            group(Prices)
            {
                Caption = 'Prices';

                field("Sales Price"; Rec."Sales Price")
                {
                }
                field("Cost Price"; Rec."Cost Price")
                {
                }
                field("Currency Code"; Rec."Currency Code")
                {
                }
            }
            group(BusinessCentral)
            {
                Caption = 'Business Central';

                field("Item No."; Rec."Item No.")
                {
                }
                field("Last Synced At"; Rec."Last Synced At")
                {
                }
            }
        }
    }
}
