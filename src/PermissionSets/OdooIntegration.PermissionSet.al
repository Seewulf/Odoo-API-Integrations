namespace PrabinBhusal.OdooIntegration;

permissionset 50100 "Odoo Integration"
{
    Assignable = true;
    Caption = 'Odoo Integration';

    Permissions =
        table "Odoo Item" = X,
        tabledata "Odoo Item" = RIMD,
        table "Odoo Connection Setup" = X,
        tabledata "Odoo Connection Setup" = RIMD,
        codeunit "Odoo API Client" = X,
        codeunit "Odoo Item Sync" = X,
        page "Odoo Item List" = X,
        page "Odoo Item Card" = X,
        page "Odoo Connection Setup" = X;
}
