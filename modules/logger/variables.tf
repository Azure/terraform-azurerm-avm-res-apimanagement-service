variable "name" {
  type        = string
  description = "The name of the logger resource."
  nullable    = false

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 256 && can(regex("^[^*#&+:<>?]+$", var.name))
    error_message = "name must be 1 to 256 characters and cannot contain `*`, `#`, `&`, `+`, `:`, `<`, `>`, or `?`."
  }
}

variable "parent_id" {
  type        = string
  description = "The fully-qualified ARM resource ID of the API Management service that will contain the logger."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.ApiManagement/service", var.parent_id))
    error_message = "`parent_id` must be a valid API Management service resource ID."
  }
}

variable "connection_string" {
  type        = string
  default     = null
  description = <<DESCRIPTION
The Application Insights connection string, sent as `properties.credentials.connectionString`. Required when `logger_type` is `applicationInsights`.
It is sent through AzAPI's write-only `sensitive_body` and is not stored on the AzAPI resource state or read back from Azure.
DESCRIPTION
  sensitive   = true
}

variable "description" {
  type        = string
  default     = null
  description = "Logger description. When null, `description` is not sent."

  validation {
    condition     = var.description == null ? true : length(var.description) <= 256
    error_message = "description must have a maximum length of 256."
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

variable "identity_client_id" {
  type        = string
  default     = null
  description = <<DESCRIPTION
Client ID of the user-assigned managed identity that APIM uses to authenticate to Application Insights (Microsoft Entra authentication), sent as `properties.credentials.identityClientId`.
It is sent with the connection string through `sensitive_body` because APIM returns a generated `{{named-value}}` placeholder instead of the client ID. The identity needs the `Monitoring Metrics Publisher` role on the Application Insights resource.
DESCRIPTION

  validation {
    condition     = var.identity_client_id == null ? true : can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.identity_client_id))
    error_message = "identity_client_id must be a GUID."
  }
}

variable "ignore_body_changes" {
  type = object({
    apimanagement_service_loggers = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths ignored on the logger resource. Paths use dot notation.
Changes take effect only after apply. Ignored configuration is not sent to Azure.

- `apimanagement_service_loggers` - Paths ignored on the logger resource.
DESCRIPTION
  nullable    = false
}

variable "is_buffered" {
  type        = bool
  default     = null
  description = "Whether records are buffered in the logger before publishing. When null, `isBuffered` is not sent and Azure assumes `true`."
}

variable "logger_type" {
  type        = string
  default     = "applicationInsights"
  description = <<DESCRIPTION
Logger type. Valid values: `applicationInsights`, `azureMonitor`.
The `azureEventHub` logger type is not supported by this submodule.
DESCRIPTION
  nullable    = false

  validation {
    condition     = contains(["applicationInsights", "azureMonitor"], var.logger_type)
    error_message = "logger_type must be `applicationInsights` or `azureMonitor`."
  }
}

variable "resource_id" {
  type        = string
  default     = null
  description = "The resource ID of the Application Insights component that receives the logs, sent as `properties.resourceId`. When null, `resourceId` is not sent."

  validation {
    condition     = var.resource_id == null ? true : can(provider::azapi::parse_resource_id("Microsoft.Insights/components", var.resource_id))
    error_message = "`resource_id` must be a valid Application Insights component resource ID."
  }
}

variable "resource_types" {
  type = object({
    apimanagement_service_loggers = optional(string, "Microsoft.ApiManagement/service/loggers@2024-05-01")
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by the logger submodule.

- `apimanagement_service_loggers` - Resource type and API version for the logger.
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
