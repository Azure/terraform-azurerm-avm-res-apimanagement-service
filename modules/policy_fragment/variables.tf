variable "name" {
  type        = string
  description = "The name of the policy fragment."
  nullable    = false

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 80 && can(regex("(^[\\w]+$)|(^[\\w][\\w\\-]+[\\w]$)", var.name))
    error_message = "`name` must be 1 to 80 characters and contain only letters, numbers, underscores, and internal hyphens."
  }
}

variable "parent_id" {
  type        = string
  description = "The fully-qualified ARM resource ID of the API Management service that will contain the policy fragment."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.ApiManagement/service", var.parent_id))
    error_message = "`parent_id` must be a valid API Management service resource ID."
  }
}

variable "value" {
  type        = string
  description = "XML contents of the reusable policy fragment."
  nullable    = false
}

variable "description" {
  type        = string
  default     = null
  description = "Description of the policy fragment."

  validation {
    condition     = var.description == null || length(var.description) <= 1000
    error_message = "`description` must not exceed 1000 characters."
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

variable "format" {
  type        = string
  default     = "rawxml"
  description = "Policy fragment format. Valid values are `xml` and `rawxml`."
  nullable    = false

  validation {
    condition     = contains(["xml", "rawxml"], var.format)
    error_message = "`format` must be `xml` or `rawxml`."
  }
}

variable "ignore_body_changes" {
  type = object({
    apimanagement_service_policy_fragments = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths ignored on the policy fragment. Paths use dot notation.
Changes take effect only after apply. Ignored configuration is not sent to Azure.

- `apimanagement_service_policy_fragments` - Paths ignored on the policy fragment.
DESCRIPTION
  nullable    = false
}

variable "resource_types" {
  type = object({
    apimanagement_service_policy_fragments = optional(string, "Microsoft.ApiManagement/service/policyFragments@2024-05-01")
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by the policy fragment submodule.

- `apimanagement_service_policy_fragments` - Resource type and API version for the policy fragment.
DESCRIPTION
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string), null)
    interval_seconds     = optional(number, null)
    max_interval_seconds = optional(number, null)
  })
  default     = null
  description = "Retry configuration for AzAPI resources."
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
