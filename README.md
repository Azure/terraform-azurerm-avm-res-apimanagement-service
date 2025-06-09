<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-template

This is a template repo for Terraform Azure Verified Modules.

Things to do:

1. Set up a GitHub repo environment called `test`.
1. Configure environment protection rule to ensure that approval is required before deploying to this environment.
1. Create a user-assigned managed identity in your test subscription.
1. Create a role assignment for the managed identity on your test subscription, use the minimum required role.
1. Configure federated identity credentials on the user assigned managed identity. Use the GitHub environment.
1. Search and update TODOs within the code and remove the TODO comments once complete.

> [!IMPORTANT]
> As the overall AVM framework is not GA (generally available) yet - the CI framework and test automation is not fully functional and implemented across all supported languages yet - breaking changes are expected, and additional customer feedback is yet to be gathered and incorporated. Hence, modules **MUST NOT** be published at version `1.0.0` or higher at this time.
>
> All module **MUST** be published as a pre-release version (e.g., `0.1.0`, `0.1.1`, `0.2.0`, etc.) until the AVM framework becomes GA.
>
> However, it is important to note that this **DOES NOT** mean that the modules cannot be consumed and utilized. They **CAN** be leveraged in all types of environments (dev, test, prod etc.). Consumers can treat them just like any other IaC module and raise issues or feature requests against them as they learn from the usage of the module. Consumers should also read the release notes for each version, if considering updating to a more recent version of a module to see if there are any considerations or breaking changes etc.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

## Resources

The following resources are used by this module:

- [azurerm_api_management.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management) (resource)
- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_private_endpoint.this_unmanaged_dns_zone_groups](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_private_endpoint_application_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint_application_security_group_association) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/Azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/Azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the this resource.

Type: `string`

### <a name="input_publisher_email"></a> [publisher\_email](#input\_publisher\_email)

Description: The email of the API Management service publisher.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_additional_location"></a> [additional\_location](#input\_additional\_location)

Description: Additional datacenter locations where the API Management service should be provisioned.

Type:

```hcl
list(object({
    location             = string
    capacity             = optional(number, null)
    zones                = optional(list(string), null)
    public_ip_address_id = optional(string, null)
    gateway_disabled     = optional(bool, null)
    virtual_network_configuration = optional(object({
      subnet_id = string
    }), null)
  }))
```

Default: `[]`

### <a name="input_certificate"></a> [certificate](#input\_certificate)

Description: Certificate configurations for the API Management service.

Type:

```hcl
list(object({
    encoded_certificate  = string
    store_name           = string
    certificate_password = optional(string, null)
  }))
```

Default: `[]`

### <a name="input_client_certificate_enabled"></a> [client\_certificate\_enabled](#input\_client\_certificate\_enabled)

Description: Enforce a client certificate to be presented on each request to the gateway. This is only supported when SKU type is Consumption.

Type: `bool`

Default: `false`

### <a name="input_delegation"></a> [delegation](#input\_delegation)

Description: Delegation settings for the API Management service.

Type:

```hcl
object({
    subscriptions_enabled     = optional(bool, false)
    user_registration_enabled = optional(bool, false)
    url                       = optional(string, null)
    validation_key            = optional(string, null)
  })
```

Default: `null`

### <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings)

Description: A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.

Type:

```hcl
map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_gateway_disabled"></a> [gateway\_disabled](#input\_gateway\_disabled)

Description: Disable the gateway in the main region? This is only supported when additional\_location is set.

Type: `bool`

Default: `false`

### <a name="input_hostname_configuration"></a> [hostname\_configuration](#input\_hostname\_configuration)

Description: Hostname configuration for the API Management service.

Type:

```hcl
object({
    management = optional(list(object({
      host_name                       = string
      key_vault_id                    = optional(string, null)
      certificate                     = optional(string, null)
      certificate_password            = optional(string, null)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string, null)
    })), [])
    portal = optional(list(object({
      host_name                       = string
      key_vault_id                    = optional(string, null)
      certificate                     = optional(string, null)
      certificate_password            = optional(string, null)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string, null)
    })), [])
    developer_portal = optional(list(object({
      host_name                       = string
      key_vault_id                    = optional(string, null)
      certificate                     = optional(string, null)
      certificate_password            = optional(string, null)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string, null)
    })), [])
    proxy = optional(list(object({
      host_name                       = string
      default_ssl_binding             = optional(bool, false)
      key_vault_id                    = optional(string, null)
      certificate                     = optional(string, null)
      certificate_password            = optional(string, null)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string, null)
    })), [])
    scm = optional(list(object({
      host_name                       = string
      key_vault_id                    = optional(string, null)
      certificate                     = optional(string, null)
      certificate_password            = optional(string, null)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string, null)
    })), [])
  })
```

Default: `null`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.

Type:

```hcl
object({
    kind = string
    name = optional(string, null)
  })
```

Default: `null`

### <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities)

Description: Controls the Managed Identity configuration on this resource. The following properties can be specified:

- `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
- `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.

Type:

```hcl
object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
```

Default: `{}`

### <a name="input_min_api_version"></a> [min\_api\_version](#input\_min\_api\_version)

Description: The version which the control plane API calls to API Management service are limited with version equal to or newer than.

Type: `string`

Default: `null`

### <a name="input_notification_sender_email"></a> [notification\_sender\_email](#input\_notification\_sender\_email)

Description: Email address from which the notification will be sent.

Type: `string`

Default: `null`

### <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints)

Description: A map of private endpoints to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the private endpoint. One will be generated if not set.
- `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.
- `lock` - (Optional) The lock level to apply to the private endpoint. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.
- `tags` - (Optional) A mapping of tags to assign to the private endpoint.
- `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
- `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. One will be generated if not set.
- `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. If not set, no zone groups will be created and the private endpoint will not be associated with any private DNS zones. DNS records must be managed external to this module.
- `application_security_group_resource_ids` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
- `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set.
- `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set.
- `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the resource group.
- `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of this resource.
- `ip_configurations` - (Optional) A map of IP configurations to create on the private endpoint. If not specified the platform will create one. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `name` - The name of the IP configuration.
  - `private_ip_address` - The private IP address of the IP configuration.

Type:

```hcl
map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    tags                                    = optional(map(string), null)
    subnet_resource_id                      = string
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(set(string), [])
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    location                                = optional(string, null)
    resource_group_name                     = optional(string, null)
    ip_configurations = optional(map(object({
      name               = string
      private_ip_address = string
    })), {})
  }))
```

Default: `{}`

### <a name="input_private_endpoints_manage_dns_zone_group"></a> [private\_endpoints\_manage\_dns\_zone\_group](#input\_private\_endpoints\_manage\_dns\_zone\_group)

Description: Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy.

Type: `bool`

Default: `true`

### <a name="input_protocols"></a> [protocols](#input\_protocols)

Description: Protocol settings for the API Management service.

Type:

```hcl
object({
    enable_http2 = optional(bool, false)
  })
```

Default: `null`

### <a name="input_public_ip_address_id"></a> [public\_ip\_address\_id](#input\_public\_ip\_address\_id)

Description: ID of a standard SKU IPv4 Public IP. Only supported on Premium and Developer tiers when deployed in a virtual network.

Type: `string`

Default: `null`

### <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)

Description: Is public access to the API Management service allowed? This only applies to the Management plane, not the API gateway or Developer portal.

Type: `bool`

Default: `true`

### <a name="input_publisher_name"></a> [publisher\_name](#input\_publisher\_name)

Description: The name of the API Management service publisher.

Type: `string`

Default: `"Apim Example Publisher"`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description: A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_security"></a> [security](#input\_security)

Description: Security settings for the API Management service.

Type:

```hcl
object({
    enable_backend_ssl30                                = optional(bool, false)
    enable_backend_tls10                                = optional(bool, false)
    enable_backend_tls11                                = optional(bool, false)
    enable_frontend_ssl30                               = optional(bool, false)
    enable_frontend_tls10                               = optional(bool, false)
    enable_frontend_tls11                               = optional(bool, false)
    tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = optional(bool, false)
    tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = optional(bool, false)
    tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = optional(bool, false)
    tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = optional(bool, false)
    tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes128_cbc_sha_ciphers_enabled         = optional(bool, false)
    tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes256_gcm_sha384_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes256_cbc_sha_ciphers_enabled         = optional(bool, false)
    triple_des_ciphers_enabled                          = optional(bool, false)
  })
```

Default: `null`

### <a name="input_sign_in"></a> [sign\_in](#input\_sign\_in)

Description: Sign-in settings for the API Management service. When enabled, anonymous users will be redirected to the sign-in page.

Type:

```hcl
object({
    enabled = bool
  })
```

Default: `null`

### <a name="input_sign_up"></a> [sign\_up](#input\_sign\_up)

Description: Sign-up settings for the API Management service.

Type:

```hcl
object({
    enabled = bool
    terms_of_service = object({
      consent_required = bool
      enabled          = bool
      text             = optional(string, null)
    })
  })
```

Default: `null`

### <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name)

Description: The SKU name of the API Management service.

Type: `string`

Default: `"Developer_1"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

### <a name="input_tenant_access"></a> [tenant\_access](#input\_tenant\_access)

Description: Controls whether access to the management API is enabled. When enabled, the primary/secondary keys provide access to this API.

Type:

```hcl
object({
    enabled = bool
  })
```

Default: `null`

### <a name="input_virtual_network_subnet_id"></a> [virtual\_network\_subnet\_id](#input\_virtual\_network\_subnet\_id)

Description: The ID of the subnet in the virtual network where the API Management service will be deployed.

Type: `string`

Default: `null`

### <a name="input_virtual_network_type"></a> [virtual\_network\_type](#input\_virtual\_network\_type)

Description: The type of virtual network configuration for the API Management service.

Type: `string`

Default: `"None"`

### <a name="input_zones"></a> [zones](#input\_zones)

Description: Specifies a list of Availability Zones in which this API Management service should be located. Only supported in the Premium tier.

Type: `list(string)`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_additional_locations"></a> [additional\_locations](#output\_additional\_locations)

Description: Information about additional locations for the API Management Service.

### <a name="output_apim_gateway_url"></a> [apim\_gateway\_url](#output\_apim\_gateway\_url)

Description: The gateway URL of the API Management service.

### <a name="output_apim_management_url"></a> [apim\_management\_url](#output\_apim\_management\_url)

Description: The management URL of the API Management service.

### <a name="output_certificates"></a> [certificates](#output\_certificates)

Description: Certificate information for the API Management Service.

### <a name="output_developer_portal_url"></a> [developer\_portal\_url](#output\_developer\_portal\_url)

Description: The publisher URL of the API Management service.

### <a name="output_gateway_regional_url"></a> [gateway\_regional\_url](#output\_gateway\_regional\_url)

Description: The Region URL for the Gateway of the API Management Service.

### <a name="output_hostname_configuration"></a> [hostname\_configuration](#output\_hostname\_configuration)

Description: The hostname configuration for the API Management Service.

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the API Management service.

### <a name="output_portal_url"></a> [portal\_url](#output\_portal\_url)

Description: The URL for the Publisher Portal associated with this API Management service.

### <a name="output_private_endpoints"></a> [private\_endpoints](#output\_private\_endpoints)

Description: A map of the private endpoints created.

### <a name="output_private_ip_addresses"></a> [private\_ip\_addresses](#output\_private\_ip\_addresses)

Description: The private IP addresses of the private endpoints created by this module

### <a name="output_public_ip_addresses"></a> [public\_ip\_addresses](#output\_public\_ip\_addresses)

Description: The Public IP addresses of the API Management Service.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: The API Management service resource.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The ID of the API Management service.

### <a name="output_scm_url"></a> [scm\_url](#output\_scm\_url)

Description: The URL for the SCM (Source Code Management) Endpoint associated with this API Management service.

### <a name="output_tenant_access"></a> [tenant\_access](#output\_tenant\_access)

Description: The tenant access information for the API Management Service.

### <a name="output_workspace_identity"></a> [workspace\_identity](#output\_workspace\_identity)

Description: The identity for the created workspace.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->