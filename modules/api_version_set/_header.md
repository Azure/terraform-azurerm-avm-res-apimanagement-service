# Azure API Management API Version Set Submodule

This submodule deploys an API Management API version set (`Microsoft.ApiManagement/service/apiVersionSets`) using the AzAPI provider.

## Usage

```terraform
module "api_version_set" {
  source = "./modules/api_version_set"

  name              = "my-api-versions"
  parent_id         = azapi_resource.this.id
  display_name      = "My API Versions"
  versioning_scheme = "Header"
  version_header_name = "api-version"
}
```
