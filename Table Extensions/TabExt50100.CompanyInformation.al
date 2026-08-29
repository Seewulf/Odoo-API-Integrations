tableextension 50100 "Company Information Ext" extends "Company Information"
{
    fields
    {
        // Add changes to table fields here
        field(50100; "Odoo Base URL"; Text[250])
        {
            Caption = 'Odoo Base URL';
            DataClassification = ToBeClassified;
        }
        field(50101; "API Key"; Text[250])
        {
            Caption = 'API Key';
            DataClassification = ToBeClassified;
        }
        field(50102; "Database Name"; Text[250])
        {
            Caption = 'Database Name';
            DataClassification = ToBeClassified;
        }
        field(50103; "User UID"; Integer)
        {
            Caption = 'User UID';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
}