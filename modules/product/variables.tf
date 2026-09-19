variable "display_name" {
  type        = string
  description = "Product display name."
  nullable    = false

  validation {
    condition     = length(var.display_name) >= 1 && length(var.display_name) <= 300
    error_message = "`display_name` must be between 1 and 300 characters."
  }
}

variable "name" {
  type        = string
  description = "The product identifier (ARM resource name)."
  nullable    = false
}

variable "parent_id" {
  type        = string
  description = "The fully-qualified ARM resource ID of the API Management service that will contain this product."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.ApiManagement/service", var.parent_id))
    error_message = "`parent_id` must be a valid API Management service resource ID."
  }
}

variable "approval_required" {
  type        = bool
  default     = null
  description = "Whether subscription approval is required. Only valid when `subscription_required` is true."
}

variable "description" {
  type        = string
  default     = null
  description = "Product description. May include HTML formatting tags."

  validation {
    condition     = var.description == null || length(var.description) <= 1000
    error_message = "`description` must have a maximum length of 1000."
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
    apimanagement_service_products = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths ignored on the product resource. Paths use dot notation.
Changes take effect only after apply. Ignored configuration is not sent to Azure.

- `apimanagement_service_products` - Paths ignored on the product resource.
DESCRIPTION
  nullable    = false
}

variable "resource_types" {
  type = object({
    apimanagement_service_products = optional(string, "Microsoft.ApiManagement/service/products@2024-05-01")
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by the product submodule.

- `apimanagement_service_products` - Resource type and API version for the product.
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

variable "state" {
  type        = string
  default     = null
  description = "Publication state. Valid values: `published`, `notPublished`."

  validation {
    condition     = var.state == null || contains(["notPublished", "published"], var.state)
    error_message = "`state` must be one of: `notPublished`, `published`."
  }
}

variable "subscription_required" {
  type        = bool
  default     = null
  description = "Whether a product subscription is required to access APIs in this product."
}

variable "subscriptions_limit" {
  type        = number
  default     = null
  description = "Maximum number of subscriptions a user can have to this product. Omit for unlimited."
}

variable "terms" {
  type        = string
  default     = null
  description = "Product terms of use presented to developers before they can subscribe."
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
