# Azure API Management Subscription Submodule

This submodule deploys an API Management subscription (`Microsoft.ApiManagement/service/subscriptions`) using the AzAPI provider.

## Usage

```terraform
module "subscription" {
  source = "./modules/subscription"

  name      = "developer-sub"
  parent_id = azapi_resource.this.id
  display_name = "Developer Subscription"
  scope        = "/products/starter"
  state        = "active"
}
```
