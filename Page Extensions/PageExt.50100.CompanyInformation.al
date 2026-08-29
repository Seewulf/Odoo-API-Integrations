pageextension 50100 "Company Information Ext." extends "Company Information"
{
    layout
    {
        // Add changes to page layout here
        addafter(General)
        {
            group("Odoo API Integration Credentials")
            {
                Caption = 'Odoo API Integration Credentials';

                field("Odoo Base URL"; Rec."Odoo Base URL")
                {
                    ApplicationArea = All;

                }

                field("API Key"; Rec."API Key")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;


                }
                field("Database Name"; Rec."Database Name")
                {
                    ApplicationArea = All;


                }
                field("User UID"; Rec."User UID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }






}