variable "parent_id" {
  type        = string
  description = "The fully-qualified ARM resource ID of the operation that will contain this policy."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.ApiManagement/service/apis/operations", var.parent_id))
    error_message = "`parent_id` must be a valid API Management operation resource ID."
  }
}

variable "value" {
  type        = string
  description = "Policy content or link target, depending on `format`."
  nullable    = false
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
  description = "Format of the policy content: `xml`, `xml-link`, `rawxml`, or `rawxml-link`."
}

variable "ignore_body_changes" {
  type = object({
    apimanagement_service_apis_operations_policies = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths ignored on the operation policy resource. Paths use dot notation.
Changes take effect only after apply. Ignored configuration is not sent to Azure.

- `apimanagement_service_apis_operations_policies` - Paths ignored on the operation policy resource.
DESCRIPTION
  nullable    = false
}

variable "name" {
  type        = string
  default     = "policy"
  description = "The policy resource name. Must be `policy` for API Management policies."
  nullable    = false
}

variable "resource_types" {
  type = object({
    apimanagement_service_apis_operations_policies = optional(string, "Microsoft.ApiManagement/service/apis/operations/policies@2024-05-01")
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by the operation_policy submodule.

- `apimanagement_service_apis_operations_policies` - Resource type and API version for the operation policy.
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
