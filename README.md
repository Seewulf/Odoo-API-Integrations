# Odoo API Integrations for Business Central

A Business Central extension (AL) that pulls products from Odoo into a staging list, so they can be checked before they become items.

## What it does

- Connects to Odoo through its external JSON-RPC API (`/jsonrpc`, `object.execute_kw`).
- Fetches product templates in pages (`search_read` with `limit` and `offset`), so a large catalogue doesn't run into timeouts.
- Stages them in an **Odoo Items** list: name, internal reference, category, unit of measure, prices, currency and volume.
- **Create Item** turns a reviewed product into a Business Central item and keeps the link, so the same product can't be created twice.
- **Test Connection** on the setup page checks the settings and shows how many products are waiting in Odoo.

## Design notes

- **The API key stays out of the database.** It is saved in isolated storage (encrypted when encryption is enabled), handled as `SecretText` and merged into the request body with `SecretStrSubstNo`, so it never sits in a plain `Text` variable or shows up in the debugger.
- **Odoo's JSON quirks are handled.** Empty fields come back as `false` rather than `null`, and many2one fields come back as `[id, "name"]`. The parser deals with both, so a category shows as `All / Saleable` and not `[1,"All / Saleable"]`.
- **Errors you can act on.** Odoo reports business errors (unknown field, missing access right) with HTTP 200 and an `error` object. The extension shows Odoo's own message instead of a generic failure.
- **Re-runs are safe.** Products are matched on their Odoo ID, so syncing again updates the list instead of duplicating it, and the link to the created item is kept.
- **Currency check.** Item creation stops if the Odoo prices are in a different currency from the local currency, rather than creating an item with wrong prices.
- Builds with no CodeCop, UICop or PerTenantExtensionCop warnings.

## Requirements

- Business Central 28 (runtime 17), online or on-premises.
- An Odoo database and an API key for the user the integration runs as (in Odoo: **Preferences > Account Security > New API Key**).

## Setup

1. Open the folder in VS Code with the AL Language extension, run **AL: Download Symbols** and publish (F5). `launch.json` has a cloud sandbox and a local container configuration.
2. In Business Central, open **Extension Management**, select the extension, choose **Configure** and turn on **Allow HttpClient Requests**. Sandboxes block outgoing calls from extensions published from VS Code until this is on.
3. Assign the **Odoo Integration** permission set.
4. Open **Odoo Connection Setup**, fill in the fields below and choose **Test Connection**.

| Field | Example | Where to find it |
|---|---|---|
| Base URL | `https://mycompany.odoo.com` | The address you use to open Odoo |
| Database Name | `mycompany` | Odoo database selector, or ask your Odoo admin |
| Odoo User ID | `2` | Odoo **Settings > Users**, open the user: the ID is in the URL |
| API Key | | Created in Odoo as described above |

## Usage

Open **Odoo Items** and choose **Sync from Odoo**. Review the list, select a product and choose **Create Item**. The new item card opens so you can finish the posting groups and other item setup.

## Project structure

```
src/
  Codeunits/
    OdooAPIClient.Codeunit.al        JSON-RPC calls and error handling
    OdooItemSync.Codeunit.al         paging, field mapping, item creation
  Tables/
    OdooItem.Table.al                staging table
    OdooConnectionSetup.Table.al     connection settings and API key storage
  Pages/
    OdooItemList.Page.al
    OdooItemCard.Page.al
    OdooConnectionSetup.Page.al
  PermissionSets/
    OdooIntegration.PermissionSet.al
```

## Next steps

- Scheduled sync through the Job Queue.
- Customers and vendors (`res.partner`).
- Support for Odoo's newer JSON-2 API (Odoo 19 and later).

## Author

Prabin Bhusal, Business Central AL developer. [LinkedIn](https://www.linkedin.com/in/prabin-bhusal-44537635b)

## License

[MIT](LICENSE)
