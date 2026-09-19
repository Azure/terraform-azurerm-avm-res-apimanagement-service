variable "name" {
  type        = string
  description = "The group name to associate with the product (ARM resource name)."
  nullable    = false
}

variable "parent_id" {
  type        = string
  description = "The fully-qualified ARM resource ID of the product that will contain this group association."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.ApiManagement/service/products", var.parent_id))
    error_message = "`parent_id` must be a valid API Management product resource ID."
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
    apimanagement_service_products_groups = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths ignored on the product-group association resource. Paths use dot notation.
Changes take effect only after apply. Ignored configuration is not sent to Azure.

- `apimanagement_service_products_groups` - Paths ignored on the product-group association.
DESCRIPTION
  nullable    = false
}

variable "resource_types" {
  type = object({
    apimanagement_service_products_groups = optional(string, "Microsoft.ApiManagement/service/products/groups@2024-05-01")
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by the product_group submodule.

- `apimanagement_service_products_groups` - Resource type and API version for the product-group association.
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
