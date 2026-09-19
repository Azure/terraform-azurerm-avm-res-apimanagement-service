# Azure API Management Service Policy Submodule

This submodule deploys the service-level policy singleton (`Microsoft.ApiManagement/service/policies`) under an existing API Management service using the AzAPI provider. The resource name must be `policy`.

## Usage

```hcl
module "policy" {
  source = "./modules/policy"

  name      = "policy"
  parent_id = azapi_resource.this.id
  format    = "xml"
  value     = <<-XML
    <policies>
      <inbound><base /></inbound>
      <backend><base /></backend>
      <outbound><base /></outbound>
    </policies>
  XML
}
```
