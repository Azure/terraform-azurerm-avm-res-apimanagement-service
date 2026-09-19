variable "display_name" {
  type        = string
  description = "Operation display name."
  nullable    = false

  validation {
    condition     = length(var.display_name) >= 1 && length(var.display_name) <= 300
    error_message = "display_name must be between 1 and 300 characters."
  }
}

variable "method" {
  type        = string
  description = "HTTP method for the operation (GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS, TRACE)."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The operation identifier (ARM resource name)."
  nullable    = false
}

variable "parent_id" {
  type        = string
  description = "The fully-qualified ARM resource ID of the API that will contain this operation."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.ApiManagement/service/apis", var.parent_id))
    error_message = "`parent_id` must be a valid API Management API resource ID."
  }
}

variable "url_template" {
  type        = string
  description = "Relative URL template identifying the target resource for this operation."
  nullable    = false

  validation {
    condition     = length(var.url_template) >= 1 && length(var.url_template) <= 1000
    error_message = "url_template must be between 1 and 1000 characters."
  }
}

variable "description" {
  type        = string
  default     = null
  description = "Description of the operation. May include HTML formatting tags."

  validation {
    condition     = var.description == null || length(var.description) <= 1000
    error_message = "description must have a maximum length of 1000."
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
    apimanagement_service_apis_operations = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths ignored on the operation resource. Paths use dot notation.
Changes take effect only after apply. Ignored configuration is not sent to Azure.

- `apimanagement_service_apis_operations` - Paths ignored on the operation resource.
DESCRIPTION
  nullable    = false
}

variable "request" {
  type = object({
    description = optional(string)
    headers = optional(list(object({
      default_value = optional(string)
      description   = optional(string)
      name          = string
      required      = optional(bool)
      schema_id     = optional(string)
      type          = string
      type_name     = optional(string)
      values        = optional(list(string))
    })))
    query_parameters = optional(list(object({
      default_value = optional(string)
      description   = optional(string)
      name          = string
      required      = optional(bool)
      schema_id     = optional(string)
      type          = string
      type_name     = optional(string)
      values        = optional(list(string))
    })))
    representations = optional(list(object({
      content_type = string
      form_parameters = optional(list(object({
        default_value = optional(string)
        description   = optional(string)
        name          = string
        required      = optional(bool)
        schema_id     = optional(string)
        type          = string
        type_name     = optional(string)
        values        = optional(list(string))
      })))
      schema_id = optional(string)
      type_name = optional(string)
    })))
  })
  default     = null
  description = "Request details for the operation."
}

variable "resource_types" {
  type = object({
    apimanagement_service_apis_operations = optional(string, "Microsoft.ApiManagement/service/apis/operations@2024-05-01")
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by the operation submodule.

- `apimanagement_service_apis_operations` - Resource type and API version for the operation.
DESCRIPTION
  nullable    = false
}

variable "responses" {
  type = list(object({
    status_code = number
    description = optional(string)
    headers = optional(list(object({
      default_value = optional(string)
      description   = optional(string)
      name          = string
      required      = optional(bool)
      schema_id     = optional(string)
      type          = string
      type_name     = optional(string)
      values        = optional(list(string))
    })))
    representations = optional(list(object({
      content_type = string
      form_parameters = optional(list(object({
        default_value = optional(string)
        description   = optional(string)
        name          = string
        required      = optional(bool)
        schema_id     = optional(string)
        type          = string
        type_name     = optional(string)
        values        = optional(list(string))
      })))
      schema_id = optional(string)
      type_name = optional(string)
    })))
  }))
  default     = null
  description = "Array of operation responses."
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

variable "template_parameters" {
  type = list(object({
    default_value = optional(string)
    description   = optional(string)
    name          = string
    required      = optional(bool)
    schema_id     = optional(string)
    type          = string
    type_name     = optional(string)
    values        = optional(list(string))
  }))
  default     = null
  description = "Collection of URL template parameters."
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
