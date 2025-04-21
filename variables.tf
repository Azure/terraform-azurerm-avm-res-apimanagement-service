# required AVM interfaces
# remove only if not supported by the resource
# tflint-ignore: terraform_unused_declarations

# Below AI generated 

variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the this resource."
}

# This is required for most resource modules
variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "additional_location" {
  type = list(object({
    location             = string
    capacity             = optional(number, null)
    zones                = optional(list(string), null)
    public_ip_address_id = optional(string, null)
    gateway_disabled     = optional(bool, null)
    virtual_network_configuration = optional(object({
      subnet_id = string
    }), null)
  }))
  default     = []
  description = "Additional datacenter locations where the API Management service should be provisioned."
  nullable    = false
}

variable "certificate" {
  type = list(object({
    encoded_certificate  = string
    store_name           = string
    certificate_password = optional(string, null)
  }))
  default     = []
  description = "Certificate configurations for the API Management service."
  nullable    = false

  validation {
    condition     = length(var.certificate) <= 10
    error_message = "A maximum of 10 certificates can be added to an API Management service."
  }
  validation {
    condition     = alltrue([for cert in var.certificate : contains(["CertificateAuthority", "Root"], cert.store_name)])
    error_message = "The store_name must be one of: 'CertificateAuthority', 'Root'."
  }
}

variable "client_certificate_enabled" {
  type        = bool
  default     = false
  description = "Enforce a client certificate to be presented on each request to the gateway. This is only supported when SKU type is Consumption."
  nullable    = false

  validation {
    condition     = startswith(var.sku_name, "Consumption") ? true : !var.client_certificate_enabled
    error_message = "Client certificate is only supported when SKU type is Consumption (e.g., Consumption_1, Consumption_2, etc)."
  }
}

variable "delegation" {
  type = object({
    subscriptions_enabled     = optional(bool, false)
    user_registration_enabled = optional(bool, false)
    url                       = optional(string, null)
    validation_key            = optional(string, null)
  })
  default     = null
  description = "Delegation settings for the API Management service."
}

variable "diagnostic_settings" {
  type = map(object({
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
  default     = {}
  description = <<DESCRIPTION
A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

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
DESCRIPTION  
  nullable    = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
  }
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "gateway_disabled" {
  type        = bool
  default     = false
  description = "Disable the gateway in the main region? This is only supported when additional_location is set."
  nullable    = false

  validation {
    condition     = var.gateway_disabled == false || length(var.additional_location) > 0
    error_message = "Gateway can only be disabled in the main region when at least one additional location is configured."
  }
}

variable "hostname_configuration" {
  type = object({
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
  default     = null
  description = "Hostname configuration for the API Management service."
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

# tflint-ignore: terraform_unused_declarations
variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Controls the Managed Identity configuration on this resource. The following properties can be specified:

- `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
- `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.
DESCRIPTION
  nullable    = false
}

variable "min_api_version" {
  type        = string
  default     = null
  description = "The version which the control plane API calls to API Management service are limited with version equal to or newer than."
}

variable "notification_sender_email" {
  type        = string
  default     = null
  description = "Email address from which the notification will be sent."
}

variable "private_endpoints" {
  type = map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
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
  default     = {}
  description = <<DESCRIPTION
A map of private endpoints to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

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
DESCRIPTION
  nullable    = false

  validation {
    condition     = var.virtual_network_type == "None" || length(var.private_endpoints) == 0
    error_message = "Private endpoints cannot be used with API Management in Internal or External virtual network mode. Use either private endpoints (with virtual_network_type = None ) or Internal/External virtual network mode."
  }
}

# This variable is used to determine if the private_dns_zone_group block should be included,
# or if it is to be managed externally, e.g. using Azure Policy.
# https://github.com/Azure/terraform-azurerm-avm-res-keyvault-vault/issues/32
# Alternatively you can use AzAPI, which does not have this issue.
#TODO: add DNS zone if enabled
# variable "private_endpoints_manage_dns_zone_group" {
#   type        = bool
#   default     = true
#   description = "Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy."
#   nullable    = false
# }

variable "protocols" {
  type = object({
    enable_http2 = optional(bool, false)
  })
  default     = null
  description = "Protocol settings for the API Management service."
}

variable "public_ip_address_id" {
  type        = string
  default     = null
  description = "ID of a standard SKU IPv4 Public IP. Only supported on Premium and Developer tiers when deployed in a virtual network."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Is public access to the API Management service allowed? This only applies to the Management plane, not the API gateway or Developer portal."
  nullable    = false
}

variable "publisher_email" {
  type        = string
  default     = ""
  description = "The email of the API Management service publisher."

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.publisher_email))
    error_message = "The publisher_email must be a valid email address."
  }
}

variable "publisher_name" {
  type        = string
  default     = "Apim Example Publisher"
  description = "The name of the API Management service publisher."
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false
}

variable "security" {
  type = object({
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
  default     = null
  description = "Security settings for the API Management service."
}

variable "sign_in" {
  type = object({
    enabled = bool
  })
  default     = null
  description = "Sign-in settings for the API Management service. When enabled, anonymous users will be redirected to the sign-in page."
}

variable "sign_up" {
  type = object({
    enabled = bool
    terms_of_service = object({
      consent_required = bool
      enabled          = bool
      text             = optional(string, null)
    })
  })
  default     = null
  description = "Sign-up settings for the API Management service."
}

variable "sku_name" {
  type        = string
  default     = "Developer_1"
  description = "The SKU name of the API Management service."

  validation {
    condition     = can(regex("^(Consumption|Developer|Basic|Standard|Premium)_([1-9]|[1-9][0-9])$", var.sku_name))
    error_message = "The sku_name must be a string consisting of two parts separated by an underscore(_). The first part must be one of: Consumption, Developer, Basic, Standard, or Premium. The second part must be a positive integer between 1-99 (e.g. Developer_1)."
  }
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "tenant_access" {
  type = object({
    enabled = bool
  })
  default     = null
  description = "Controls whether access to the management API is enabled. When enabled, the primary/secondary keys provide access to this API."
}

variable "virtual_network_subnet_id" {
  type        = string
  default     = null
  description = "The ID of the subnet in the virtual network where the API Management service will be deployed."

  validation {
    condition     = var.virtual_network_type == "None" ? var.virtual_network_subnet_id == null : true
    error_message = "The virtual_network_subnet_id must not be set when virtual_network_type is None."
  }
}

variable "virtual_network_type" {
  type        = string
  default     = "None"
  description = "The type of virtual network configuration for the API Management service."

  validation {
    condition     = contains(["None", "External", "Internal"], var.virtual_network_type)
    error_message = "The virtual_network_type must be one of: None, External, or Internal."
  }
}

variable "zones" {
  type        = list(string)
  default     = null
  description = "Specifies a list of Availability Zones in which this API Management service should be located. Only supported in the Premium tier."

  validation {
    condition     = var.zones == null || startswith(var.sku_name, "Premium")
    error_message = "Availability Zones are only supported in the Premium tier."
  }
}
