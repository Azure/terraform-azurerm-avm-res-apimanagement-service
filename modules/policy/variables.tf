variable "name" {
  type        = string
  description = "The name of the policy resource. Must be `policy` for the service-level policy singleton."
  nullable    = false

  validation {
    condition     = var.name == "policy"
    error_message = "`name` must be `policy` for Microsoft.ApiManagement/service/policies."
  }
}

variable "parent_id" {
  type        = string
  description = "The fully-qualified ARM resource ID of the API Management service that will contain the policy."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.ApiManagement/service", var.parent_id))
    error_message = "`parent_id` must be a valid API Management service resource ID."
  }
}

variable "value" {
  type        = string
  description = "Contents of the policy as defined by the format (typically XML policy document)."
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
  default     = "xml"
  description = <<DESCRIPTION
Format of the policy content. Valid values: `xml`, `xml-link`, `rawxml`, `rawxml-link`.
Defaults to `xml` for inline XML content (maps from AzureRM `xml_content`).
DESCRIPTION

  validation {
    condition     = contains(["xml", "xml-link", "rawxml", "rawxml-link"], var.format)
    error_message = "`format` must be one of: xml, xml-link, rawxml, rawxml-link."
  }
}

variable "ignore_body_changes" {
  type = object({
    apimanagement_service_policies = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths ignored on the policy resource. Paths use dot notation.
Changes take effect only after apply. Ignored configuration is not sent to Azure.

- `apimanagement_service_policies` - Paths ignored on the policy resource.
DESCRIPTION
  nullable    = false
}

variable "resource_types" {
  type = object({
    apimanagement_service_policies = optional(string, "Microsoft.ApiManagement/service/policies@2024-05-01")
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by the policy submodule.

- `apimanagement_service_policies` - Resource type and API version for the service policy.
DESCRIPTION
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = null
  description = "Retry configuration for AzAPI resources. See AzAPI provider `retry` documentation."
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
