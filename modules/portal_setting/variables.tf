variable "name" {
  type        = string
  description = "The singleton portal setting name."

  validation {
    condition     = contains(["delegation", "signin", "signup"], var.name)
    error_message = "The name must be one of: delegation, signin, or signup."
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

variable "enabled" {
  type        = bool
  default     = null
  description = "Whether sign-in or sign-up is enabled."
}

variable "ignore_body_changes" {
  type = object({
    apimanagement_service_portalsettings = optional(list(string), [])
  })
  default     = {}
  description = "Body-relative paths to omit from the portal setting PATCH request."
  nullable    = false
}

variable "resource_types" {
  type = object({
    apimanagement_service_portalsettings = optional(string, "Microsoft.ApiManagement/service/portalsettings@2024-05-01")
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
  description = "Retry configuration for the AzAPI resource."
}

variable "subscriptions_enabled" {
  type        = bool
  default     = null
  description = "Whether subscription delegation is enabled."
}

variable "terms_of_service" {
  type = object({
    consent_required = bool
    enabled          = bool
    text             = optional(string)
  })
  default     = null
  description = "Terms of service displayed during sign-up."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = "Timeouts for the AzAPI resource."
}

variable "url" {
  type        = string
  default     = null
  description = "The delegation endpoint URL."
}

variable "user_registration_enabled" {
  type        = bool
  default     = null
  description = "Whether user registration delegation is enabled."
}

variable "validation_key" {
  type        = string
  default     = null
  description = "The base64-encoded delegation validation key. The raw value is sent through AzAPI's write-only body."
  sensitive   = true
}
