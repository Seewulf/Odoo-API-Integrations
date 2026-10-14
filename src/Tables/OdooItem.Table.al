namespace PrabinBhusal.OdooIntegration;

using Microsoft.Inventory.Item;

table 50100 "Odoo Item"
{
    Caption = 'Odoo Item';
    DataClassification = CustomerContent;
    DrillDownPageId = "Odoo Item List";
    LookupPageId = "Odoo Item List";

    fields
    {
        field(1; "Odoo ID"; Integer)
        {
            Caption = 'Odoo ID';
            ToolTip = 'Specifies the ID of the product template in Odoo.';
        }
        field(2; Name; Text[250])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the product name in Odoo.';
        }
        field(3; "Internal Reference"; Text[50])
        {
            Caption = 'Internal Reference';
            ToolTip = 'Specifies the internal reference (default code) of the product in Odoo.';
        }
        field(4; Category; Text[100])
        {
            Caption = 'Category';
            ToolTip = 'Specifies the product category in Odoo.';
        }
        field(5; "Unit of Measure"; Text[50])
        {
            Caption = 'Unit of Measure';
            ToolTip = 'Specifies the unit of measure of the product in Odoo.';
        }
        field(6; "Sales Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Sales Price';
            ToolTip = 'Specifies the sales price of the product in Odoo.';
        }
        field(7; "Cost Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Cost Price';
            ToolTip = 'Specifies the cost price of the product in Odoo.';
        }
        field(8; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            ToolTip = 'Specifies the currency of the prices in Odoo.';
        }
        field(9; Volume; Decimal)
        {
            Caption = 'Volume';
            DecimalPlaces = 0 : 5;
            ToolTip = 'Specifies the volume of the product in Odoo.';
        }
        field(20; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            TableRelation = Item;
            ToolTip = 'Specifies the Business Central item created from this product.';
        }
        field(30; "Last Synced At"; DateTime)
        {
            Caption = 'Last Synced At';
            Editable = false;
            ToolTip = 'Specifies when the product was last fetched from Odoo.';
        }
    }

    keys
    {
        key(PK; "Odoo ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Odoo ID", Name, "Internal Reference")
        {
        }
    }
}
