# Azure API Management Diagnostic Submodule

This submodule deploys a service-level diagnostic (`Microsoft.ApiManagement/service/diagnostics`) under an existing API Management service using the AzAPI provider, for example the `applicationinsights` diagnostic that sends gateway request telemetry and custom metrics to an Application Insights logger.

Every optional input is omitted from the request body when null, so Azure keeps its defaults.

## Usage

```hcl
module "diagnostic" {
  source = "./modules/diagnostic"

  name                      = "applicationinsights"
  parent_id                 = azapi_resource.apim.id
  logger_id                 = module.logger.resource_id
  always_log                = "allErrors"
  http_correlation_protocol = "W3C"
  log_client_ip             = false
  metrics                   = true
  operation_name_format     = "Url"
  verbosity                 = "information"

  sampling = {
    percentage = 100
  }

  frontend = {
    request  = { headers = [], body_bytes = 0 }
    response = { headers = [], body_bytes = 0 }
  }
  backend = {
    request  = { headers = [], body_bytes = 0 }
    response = { headers = [], body_bytes = 0 }
  }
}
```

## Migrating from a raw `azapi_resource`

A diagnostic managed as a raw `azapi_resource` with the same name moves into this submodule without replacement:

```hcl
moved {
  from = azapi_resource.diagnostic
  to   = module.diagnostic.azapi_resource.this
}
```

Through the root module the target is `module.<apim>.module.diagnostic["<key>"].azapi_resource.this`. When the inputs reproduce the raw body (as in the usage example above), the move produces no changes.

A service-level diagnostic is distinct from Azure Monitor diagnostic settings (`Microsoft.Insights/diagnosticSettings`), which the root module manages through `diagnostic_settings`.
