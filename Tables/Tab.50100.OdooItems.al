table 50100 "Odoo Items"
{
    Caption = 'Odoo Items';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Item Code"; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(2; "Item Name"; Text[250])
        {
            DataClassification = ToBeClassified;

        }
        field(3; Quantity; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(4; "Unit of Measure"; Code[100])
        {
            DataClassification = ToBeClassified;

        }
        field(5; Category; Code[100])
        {
            DataClassification = ToBeClassified;

        }
        field(6; "Currency ID"; Code[100])
        {
            DataClassification = ToBeClassified;

        }
        field(7; "Vendor ID"; Code[100])
        {
            DataClassification = ToBeClassified;

        }
        field(8; "Sales Price"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(9; "Cost Price"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
    }

    keys
    {
        key(PK; "Item Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}