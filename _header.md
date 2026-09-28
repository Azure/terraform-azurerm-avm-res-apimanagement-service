# terraform-azurerm-avm-res-apimanagement-service

This module deploys Azure API Management (`Microsoft.ApiManagement/service`) using the AzAPI provider.

## AzAPI-managed capabilities

The module manages the API Management service and its common control-plane children with AzAPI `2024-05-01`.

| Capability | Input | Stable ID/output |
| --- | --- | --- |
| APIs, operations, and API/operation policies | `apis` | `api_ids`, `api_operation_ids`, `apis`, `api_operations` |
| Backends and backend pools | `backends` (`type = "Single"` or `"Pool"`) | `backend_ids`, `backend_pool_ids`, `backends` |
| Loggers and service-level diagnostics (gateway request telemetry) | `loggers`, `diagnostics` | `logger_ids`, `diagnostic_ids` |
| Named values, including Key Vault references | `named_values` | `named_value_ids`, `named_values` |
| Products and API/group associations | `products` | `product_ids`, `products` |
| Service policy and reusable policy fragments | `policy`, `policy_fragments` | `policy`, `policy_fragment_ids`, `policy_fragments` |
| Subscriptions | `subscriptions` | `subscription_ids`, `subscriptions`, `subscription_keys` |
| Developer portal delegation, sign-in, and sign-up settings | `delegation`, `sign_in`, `sign_up` | `delegation_id`, `sign_in_id`, `sign_up_id` and corresponding detail outputs |
| Tenant access | `tenant_access` | `tenant_access_id`, `tenant_access` |

Backend pools can reference another `Single` entry in `backends` by `backend_name`, or an existing API Management backend resource ID by `backend_id`. The module orders in-module backends before pools and orders named values, fragments, and backends before policies that may reference them.

Service-level `diagnostics` reference a `loggers` entry by `logger_name`, or an existing APIM logger by `logger_id`. They control APIM gateway request telemetry (for example the `applicationinsights` diagnostic) and are distinct from the Azure Monitor `diagnostic_settings` interface.

### Tier-dependent service properties

Some service properties are accepted in a PUT but not persisted on every tier. With AzAPI's `ignore_missing_property`, a value Azure drops shows no drift, so the control would be silently absent. The module therefore omits these properties when the input is null and rejects values on tiers where Azure is documented or observed not to apply them:

| Input | Omitted when null | Rejected on |
| --- | --- | --- |
| `developer_portal_status` | `properties.developerPortalStatus` | `Consumption` (no developer portal) |
| `gateway_disabled`, `additional_location[*].gateway_disabled` | `properties.disableGateway` | `BasicV2`, `StandardV2`, `PremiumV2` (no multi-region deployment); main-region value also requires `additional_location` |
| `min_api_version` | `properties.apiVersionConstraint` | `BasicV2`, `StandardV2`, `PremiumV2` |

Each variable description records the evidence and any tiers that were not verified by deployment.

### Policy read-back format

The service policy, API policies, and operation policies are read back with `?format=` matching the written `format` (`rawxml-link` and `xml-link` read back as `rawxml` and `xml`), as policy fragments already are. A default GET returns escaped `xml`, which would otherwise diff against a `rawxml` body. APIM normalises policy whitespace and line endings on every read, so keep policy documents in APIM's canonical formatting or add `properties.value` to `ignore_body_changes`. A `*-link` format always reads back inline content, so add `properties.format` and `properties.value` to `ignore_body_changes` for linked policies.

### Migrating raw loggers and diagnostics

A logger and service diagnostic managed as raw `azapi_resource` blocks move into this module without replacement when the map keys match the resource names:

```hcl
moved {
  from = azapi_resource.logger
  to   = module.apim.module.logger["gateway-appinsights"].azapi_resource.this
}

moved {
  from = azapi_resource.diagnostic
  to   = module.apim.module.diagnostic["applicationinsights"].azapi_resource.this
}
```

Expect one in-place logger update after the move: `properties.credentials` leaves the stored body and is written through `sensitive_body`. A diagnostic whose inputs reproduce the raw body at the same API version moves with no changes.

### Sensitive values and Terraform state

Backend credentials and proxy configuration, the delegation validation key, secret named-value values, and custom subscription keys are sent through AzAPI write-only `sensitive_body`. Those child resources store only SHA-256 change tokens through `sensitive_body_version`, not the supplied raw secret values.

Logger credentials (`loggers[*].connection_string` and `identity_client_id`) are also sent through `sensitive_body`, but without `sensitive_body_version`, because the logger PUT replaces the whole resource and the credentials must accompany every write. AzAPI detects credential changes from a SHA-256 hash in the resource's private state. The `loggers` variable is sensitive, and the module never reads logger credentials back.

Key Vault-backed named values store the secret identifier and optional managed-identity client ID in state, but this module never reads the Key Vault secret value. Use an unversioned secret identifier for APIM automatic refresh or a versioned identifier to pin a version.

These protections do not remove secrets from Terraform configuration, variable files, shell history, saved plan files, or the state of upstream resources and data sources that supply the values. Treat all of those artifacts as sensitive and use an encrypted remote backend. Non-secret named values (`secret = false`) are ordinary resource body values and are stored in Terraform state.

The module does not call APIM `listSecrets` operations. Azure-generated subscription and tenant-access keys are not read into Terraform state; `subscription_keys` and the key fields in `tenant_access` intentionally return null placeholders. Retrieve generated keys out-of-band when they are required.

### Developer portal and tenant access settings

The module manages `delegation`, `sign_in`, `sign_up`, and `tenant_access` through the stable `2024-05-01` singleton child APIs:

- `Microsoft.ApiManagement/service/portalsettings@2024-05-01`, child name `delegation`
- `Microsoft.ApiManagement/service/portalsettings@2024-05-01`, child name `signin`
- `Microsoft.ApiManagement/service/portalsettings@2024-05-01`, child name `signup`
- `Microsoft.ApiManagement/service/tenant@2024-05-01`, child name `access`

Set an input to `null` to leave that singleton unmanaged. Because Azure does not expose DELETE operations for these settings, changing a configured value to `null` stops Terraform management without resetting the current Azure value. Set `enabled = false` explicitly when the setting must be disabled.

The reusable module contains no AzureRM resource or data-source exceptions.

> [!IMPORTANT]
> As the overall AVM framework is not GA (generally available) yet - the CI framework and test automation is not fully functional and implemented across all supported languages yet - breaking changes are expected, and additional customer feedback is yet to be gathered and incorporated. Hence, modules **MUST NOT** be published at version `1.0.0` or higher at this time.
> 
> All module **MUST** be published as a pre-release version (e.g., `0.1.0`, `0.1.1`, `0.2.0`, etc.) until the AVM framework becomes GA.
> 
> However, it is important to note that this **DOES NOT** mean that the modules cannot be consumed and utilized. They **CAN** be leveraged in all types of environments (dev, test, prod etc.). Consumers can treat them just like any other IaC module and raise issues or feature requests against them as they learn from the usage of the module. Consumers should also read the release notes for each version, if considering updating to a more recent version of a module to see if there are any considerations or breaking changes etc.
