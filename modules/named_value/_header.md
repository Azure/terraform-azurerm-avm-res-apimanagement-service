# Azure API Management Named Value Submodule

This submodule deploys a named value (`Microsoft.ApiManagement/service/namedValues`) under an existing API Management service using the AzAPI provider.

## Usage

```hcl
module "named_value" {
  source = "./modules/named_value"

  name         = "api-key"
  parent_id    = azapi_resource.this.id
  display_name = "API Key"
  value        = "my-secret-key"
  secret       = true
}
```
