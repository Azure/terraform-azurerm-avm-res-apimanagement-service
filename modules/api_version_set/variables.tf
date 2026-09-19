variable "display_name" {
  type        = string
  description = "Display name of the API version set."
  nullable    = false

  validation {
    condition     = length(var.display_name) >= 1 && length(var.display_name) <= 100
    error_message = "display_name must be between 1 and 100 characters."
  }
}

variable "name" {
  type        = string
  description = "The name of the API version set."
  nullable    = false
}

variable "parent_id" {
  type        = string
  description = "The fully-qualified ARM resource ID of the existing API Management service that will contain the API version set."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.ApiManagement/service", var.parent_id))
    error_message = "`parent_id` must be a valid Microsoft.ApiManagement/service resource ID."
  }
}

variable "versioning_scheme" {
  type        = string
  description = "Where the API version identifier is located in an HTTP request. Valid values: `Header`, `Query`, `Segment`."
  nullable    = false

  validation {
    condition     = contains(["Header", "Query", "Segment"], var.versioning_scheme)
    error_message = "versioning_scheme must be one of: Header, Query, Segment."
  }
}

variable "description" {
  type        = string
  default     = null
  description = "Description of the API version set."
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
    apimanagement_service_api_version_sets = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths ignored on the API version set resource. Paths use dot notation.
Changes take effect only after apply. Ignored configuration is not sent to Azure.

- `apimanagement_service_api_version_sets` - Paths ignored on the API version set resource.
DESCRIPTION
  nullable    = false
}

variable "resource_types" {
  type = object({
    apimanagement_service_api_version_sets = optional(string, "Microsoft.ApiManagement/service/apiVersionSets@2024-05-01")
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by the api_version_set submodule.

- `apimanagement_service_api_version_sets` - Resource type and API version for the API version set.
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

variable "version_header_name" {
  type        = string
  default     = null
  description = "Name of the HTTP header parameter that indicates the API version when `versioning_scheme` is `Header`."

  validation {
    condition     = var.version_header_name == null || (length(var.version_header_name) >= 1 && length(var.version_header_name) <= 100)
    error_message = "version_header_name must be between 1 and 100 characters when set."
  }
}

variable "version_query_name" {
  type        = string
  default     = null
  description = "Name of the query parameter that indicates the API version when `versioning_scheme` is `Query`."

  validation {
    condition     = var.version_query_name == null || (length(var.version_query_name) >= 1 && length(var.version_query_name) <= 100)
    error_message = "version_query_name must be between 1 and 100 characters when set."
  }
}
