variable "display_name" {
  type        = string
  description = <<DESCRIPTION
Unique name of NamedValue. It may contain only letters, digits, period, dash, and underscore characters.
DESCRIPTION
  nullable    = false

  validation {
    condition     = length(var.display_name) >= 1
    error_message = "display_name must have a minimum length of 1."
  }
  validation {
    condition     = length(var.display_name) <= 256
    error_message = "display_name must have a maximum length of 256."
  }
  validation {
    condition     = can(regex("^[A-Za-z0-9-._]+$", var.display_name))
    error_message = "display_name must match the pattern: ^[A-Za-z0-9-._]+$."
  }
}

variable "name" {
  type        = string
  description = "The name of the named value resource."
  nullable    = false
}

variable "parent_id" {
  type        = string
  description = "The fully-qualified ARM resource ID of the API Management service that will contain the named value."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.ApiManagement/service", var.parent_id))
    error_message = "`parent_id` must be a valid API Management service resource ID."
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

variable "ignore_body_changes" {
  type = object({
    apimanagement_service_named_values = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths ignored on the named value resource. Paths use dot notation.
Changes take effect only after apply. Ignored configuration is not sent to Azure.

- `apimanagement_service_named_values` - Paths ignored on the named value resource.
DESCRIPTION
  nullable    = false
}

variable "key_vault" {
  type = object({
    identity_client_id = optional(string)
    secret_identifier  = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
KeyVault location details of the namedValue.

- `identity_client_id` - Null for SystemAssignedIdentity or Client Id for UserAssignedIdentity, which will be used to access key vault secret.
- `secret_identifier` - Key vault secret identifier for fetching secret. Providing a versioned secret will prevent auto-refresh. This requires API Management service to be configured with aka.ms/apimmsi.
DESCRIPTION
}

variable "resource_types" {
  type = object({
    apimanagement_service_named_values = optional(string, "Microsoft.ApiManagement/service/namedValues@2024-05-01")
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by the named_value submodule.

- `apimanagement_service_named_values` - Resource type and API version for the named value.
DESCRIPTION
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string), null)
    interval_seconds     = optional(number, null)
    max_interval_seconds = optional(number, null)
    multiplier           = optional(number, null)
    randomization_factor = optional(number, null)
  })
  default     = null
  description = "Retry configuration for AzAPI resources. See AzAPI provider `retry` documentation."
}

variable "secret" {
  type        = bool
  default     = null
  description = "Determines whether the value is a secret and should be encrypted or not. Default value is false."
}

variable "tags" {
  type        = list(string)
  default     = null
  description = "Optional tags that when provided can be used to filter the NamedValue list."

  validation {
    condition     = var.tags == null || length(var.tags) <= 32
    error_message = "tags must have at most 32 item(s)."
  }
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = "Timeouts for AzAPI resources."
}

variable "value" {
  type        = string
  default     = null
  description = <<DESCRIPTION
Value of the NamedValue. Can contain policy expressions. It may not be empty or consist only of whitespace.
When `secret` is true this is sent via `sensitive_body` and is not stored on the AzAPI resource state.
DESCRIPTION
  sensitive   = true

  validation {
    condition     = var.value == null || length(var.value) <= 4096
    error_message = "value must have a maximum length of 4096."
  }
}
