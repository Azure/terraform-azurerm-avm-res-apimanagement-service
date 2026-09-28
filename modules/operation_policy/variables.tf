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
  description = <<DESCRIPTION
Format of the policy content: `xml`, `xml-link`, `rawxml`, or `rawxml-link`.

The resource is read back with `?format=` set to the written format (`xml` or `rawxml`; link formats are read back as their inline equivalent), so the `format` property and rawxml escaping do not drift.
APIM still normalises whitespace on read (CRLF line endings and tab indentation), so write policy content in that canonical form to avoid a whitespace-only diff.
With `xml-link` or `rawxml-link`, the GET returns the inline policy content rather than the link, so the value drifts; add `properties.format` and `properties.value` to `ignore_body_changes` if needed.
DESCRIPTION
  nullable    = false

  validation {
    condition     = contains(["xml", "xml-link", "rawxml", "rawxml-link"], var.format)
    error_message = "`format` must be one of: xml, xml-link, rawxml, rawxml-link."
  }
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
