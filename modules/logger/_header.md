# Azure API Management Logger Submodule

This submodule deploys a logger (`Microsoft.ApiManagement/service/loggers`) under an existing API Management service using the AzAPI provider. It supports the `applicationInsights` and `azureMonitor` logger types.

## Usage

```hcl
module "logger" {
  source = "./modules/logger"

  name               = "gateway-appinsights"
  parent_id          = azapi_resource.apim.id
  connection_string  = azapi_resource.appi.output.properties.ConnectionString
  description        = "Gateway Application Insights."
  identity_client_id = azapi_resource.gateway_identity.output.properties.clientId
  is_buffered        = true
  resource_id        = azapi_resource.appi.id
}
```

## Credentials

`connection_string` and `identity_client_id` are sent as `properties.credentials` through AzAPI's write-only `sensitive_body`, so they are not stored on the AzAPI resource state and are never read back. APIM's GET returns the connection string in plain text and the identity client ID as a generated `{{named-value}}` placeholder; excluding credentials from `body` keeps both out of state and avoids placeholder drift.

The submodule does not set `sensitive_body_version`. With a version map, AzAPI sends only the changed `sensitive_body` paths, but the logger PUT replaces the whole resource, so credentials must accompany every write. AzAPI instead detects credential changes from a SHA-256 hash in the resource's private state and sends the full `sensitive_body` on every create and update.

## Migrating from a raw `azapi_resource`

A logger managed as a raw `azapi_resource` with the same name moves into this submodule without replacement:

```hcl
moved {
  from = azapi_resource.logger
  to   = module.logger.azapi_resource.this
}
```

Through the root module the target is `module.<apim>.module.logger["<key>"].azapi_resource.this`. Expect one in-place update after the move: `properties.credentials` leaves the stored body and is written from `sensitive_body`, which also records the private-state hash. Subsequent plans show no changes.
