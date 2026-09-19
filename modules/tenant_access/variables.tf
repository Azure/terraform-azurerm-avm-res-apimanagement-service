variable "enabled" {
  type        = bool
  description = "Whether direct tenant access is enabled."
}

variable "name" {
  type        = string
  description = "The tenant access singleton name."

  validation {
    condition     = var.name == "access"
    error_message = "The tenant access name must be access."
  }
}

variable "parent_id" {
  type        = string
  description = "The resource ID of the API Management service."

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.ApiManagement/service", var.parent_id))
    error_message = "`parent_id` must be a valid API Management service resource ID."
  }
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = "Controls whether telemetry is enabled for this module."
  nullable    = false
}

variable "ignore_body_changes" {
  type = object({
    apimanagement_service_tenant = optional(list(string), [])
  })
  default     = {}
  description = "Body-relative paths to omit from the tenant access PATCH request."
  nullable    = false
}

variable "resource_types" {
  type = object({
    apimanagement_service_tenant = optional(string, "Microsoft.ApiManagement/service/tenant@2024-05-01")
  })
  default     = {}
  description = "AzAPI resource types and API versions used by the submodule."
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = null
  description = "Retry configuration for AzAPI operations."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = "Timeouts for AzAPI operations."
}
