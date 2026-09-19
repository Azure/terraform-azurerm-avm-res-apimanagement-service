# terraform-azurerm-avm-res-apimanagement-service

This module deploys Azure API Management (`Microsoft.ApiManagement/service`) using the AzAPI provider.

## AzAPI-managed capabilities

The module manages the API Management service and its common control-plane children with AzAPI `2024-05-01`.

| Capability | Input | Stable ID/output |
| --- | --- | --- |
| APIs, operations, and API/operation policies | `apis` | `api_ids`, `api_operation_ids`, `apis`, `api_operations` |
| Backends and backend pools | `backends` (`type = "Single"` or `"Pool"`) | `backend_ids`, `backend_pool_ids`, `backends` |
| Named values, including Key Vault references | `named_values` | `named_value_ids`, `named_values` |
| Products and API/group associations | `products` | `product_ids`, `products` |
| Service policy and reusable policy fragments | `policy`, `policy_fragments` | `policy`, `policy_fragment_ids`, `policy_fragments` |
| Subscriptions | `subscriptions` | `subscription_ids`, `subscriptions` |
| Developer portal delegation, sign-in, and sign-up settings | `delegation`, `sign_in`, `sign_up` | `delegation_id`, `sign_in_id`, `sign_up_id` and corresponding detail outputs |
| Tenant access | `tenant_access` | `tenant_access_id`, `tenant_access` |

Backend pools can reference another `Single` entry in `backends` by `backend_name`, or an existing API Management backend resource ID by `backend_id`. The module orders in-module backends before pools and orders named values, fragments, and backends before policies that may reference them.

### Sensitive values and Terraform state

Certificate payloads and passwords, hostname certificate configuration, API import payloads, backend credentials and proxy configuration, the delegation validation key, secret named-value values, and custom subscription keys are sent through AzAPI write-only `sensitive_body`. The corresponding AzAPI resources do not persist the raw payload in Terraform state; only SHA-256 change tokens are stored through `sensitive_body_version`.

Key Vault-backed named values store the secret identifier and optional managed-identity client ID in state, but this module never reads the Key Vault secret value. Use an unversioned secret identifier for APIM automatic refresh or a versioned identifier to pin a version.

These protections do not remove secrets from Terraform configuration, variable files, shell history, saved plan files, or the state of upstream resources and data sources that supply the values. Treat all of those artifacts as sensitive and use an encrypted remote backend. Non-secret named values (`secret = false`) are ordinary resource body values and are stored in Terraform state. Azure-generated subscription keys are not read or exported; `subscription_keys` intentionally returns null placeholders. When `tenant_access` is configured, its generated primary and secondary keys are read with the APIM `listSecrets` action and exposed through the sensitive `tenant_access` output. Those keys are necessarily stored in Terraform state.

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
