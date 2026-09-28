variable "logger_id" {
  type        = string
  description = "The resource ID of the API Management logger that receives the diagnostic telemetry, sent as `properties.loggerId`."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.ApiManagement/service/loggers", var.logger_id))
    error_message = "`logger_id` must be a valid API Management logger resource ID."
  }
}

variable "name" {
  type        = string
  description = "The diagnostic identifier, for example `applicationinsights` or `azuremonitor`."
  nullable    = false

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 80 && can(regex("^[^*#&+:<>?]+$", var.name))
    error_message = "name must be 1 to 80 characters and cannot contain `*`, `#`, `&`, `+`, `:`, `<`, `>`, or `?`."
  }
}

variable "parent_id" {
  type        = string
  description = "The fully-qualified ARM resource ID of the API Management service that will contain the diagnostic."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.ApiManagement/service", var.parent_id))
    error_message = "`parent_id` must be a valid API Management service resource ID."
  }
}

variable "always_log" {
  type        = string
  default     = null
  description = "Message types for which sampling does not apply. Valid value: `allErrors`. When null, `alwaysLog` is not sent."

  validation {
    condition     = var.always_log == null ? true : var.always_log == "allErrors"
    error_message = "always_log must be `allErrors`."
  }
}

variable "backend" {
  type = object({
    request = optional(object({
      headers    = optional(list(string))
      body_bytes = optional(number)
      data_masking = optional(object({
        headers = optional(list(object({
          mode  = string
          value = string
        })))
        query_params = optional(list(object({
          mode  = string
          value = string
        })))
      }))
    }))
    response = optional(object({
      headers    = optional(list(string))
      body_bytes = optional(number)
      data_masking = optional(object({
        headers = optional(list(object({
          mode  = string
          value = string
        })))
        query_params = optional(list(object({
          mode  = string
          value = string
        })))
      }))
    }))
  })
  default     = null
  description = <<DESCRIPTION
Diagnostic settings for HTTP messages between the gateway and the backend. When null, `backend` is not sent.

- `request` / `response` - (Optional) Settings for the request or response message. When null, the message is not sent.
  - `headers` - (Optional) HTTP header names to log. `[]` is sent as an empty list.
  - `body_bytes` - (Optional) Number of body bytes to log, sent as `body.bytes` (0 to 8192).
  - `data_masking` - (Optional) Data masking settings.
    - `headers` - (Optional) Headers to mask, each with `mode` (`Mask` or `Hide`) and `value` (the header name).
    - `query_params` - (Optional) Query parameters to mask, each with `mode` (`Mask` or `Hide`) and `value` (the parameter name).
DESCRIPTION

  validation {
    condition = var.backend == null ? true : alltrue([
      for message in [var.backend.request, var.backend.response] :
      message == null ? true : (message.body_bytes == null ? true : message.body_bytes >= 0 && message.body_bytes <= 8192)
    ])
    error_message = "`backend` body_bytes must be between 0 and 8192."
  }
  validation {
    condition = var.backend == null ? true : alltrue(flatten([
      for message in [var.backend.request, var.backend.response] : message == null ? [] : message.data_masking == null ? [] : [
        for entity in concat(coalesce(message.data_masking.headers, []), coalesce(message.data_masking.query_params, [])) :
        contains(["Mask", "Hide"], entity.mode)
      ]
    ]))
    error_message = "`backend` data masking mode must be `Mask` or `Hide`."
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

variable "frontend" {
  type = object({
    request = optional(object({
      headers    = optional(list(string))
      body_bytes = optional(number)
      data_masking = optional(object({
        headers = optional(list(object({
          mode  = string
          value = string
        })))
        query_params = optional(list(object({
          mode  = string
          value = string
        })))
      }))
    }))
    response = optional(object({
      headers    = optional(list(string))
      body_bytes = optional(number)
      data_masking = optional(object({
        headers = optional(list(object({
          mode  = string
          value = string
        })))
        query_params = optional(list(object({
          mode  = string
          value = string
        })))
      }))
    }))
  })
  default     = null
  description = <<DESCRIPTION
Diagnostic settings for HTTP messages between the client and the gateway. When null, `frontend` is not sent.

- `request` / `response` - (Optional) Settings for the request or response message. When null, the message is not sent.
  - `headers` - (Optional) HTTP header names to log. `[]` is sent as an empty list.
  - `body_bytes` - (Optional) Number of body bytes to log, sent as `body.bytes` (0 to 8192).
  - `data_masking` - (Optional) Data masking settings.
    - `headers` - (Optional) Headers to mask, each with `mode` (`Mask` or `Hide`) and `value` (the header name).
    - `query_params` - (Optional) Query parameters to mask, each with `mode` (`Mask` or `Hide`) and `value` (the parameter name).
DESCRIPTION

  validation {
    condition = var.frontend == null ? true : alltrue([
      for message in [var.frontend.request, var.frontend.response] :
      message == null ? true : (message.body_bytes == null ? true : message.body_bytes >= 0 && message.body_bytes <= 8192)
    ])
    error_message = "`frontend` body_bytes must be between 0 and 8192."
  }
  validation {
    condition = var.frontend == null ? true : alltrue(flatten([
      for message in [var.frontend.request, var.frontend.response] : message == null ? [] : message.data_masking == null ? [] : [
        for entity in concat(coalesce(message.data_masking.headers, []), coalesce(message.data_masking.query_params, [])) :
        contains(["Mask", "Hide"], entity.mode)
      ]
    ]))
    error_message = "`frontend` data masking mode must be `Mask` or `Hide`."
  }
}

variable "http_correlation_protocol" {
  type        = string
  default     = null
  description = "Correlation protocol for Application Insights diagnostics. Valid values: `None`, `Legacy`, `W3C`. When null, `httpCorrelationProtocol` is not sent."

  validation {
    condition     = var.http_correlation_protocol == null ? true : contains(["None", "Legacy", "W3C"], var.http_correlation_protocol)
    error_message = "http_correlation_protocol must be `None`, `Legacy` or `W3C`."
  }
}

variable "ignore_body_changes" {
  type = object({
    apimanagement_service_diagnostics = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths ignored on the diagnostic resource. Paths use dot notation.
Changes take effect only after apply. Ignored configuration is not sent to Azure.

- `apimanagement_service_diagnostics` - Paths ignored on the diagnostic resource.
DESCRIPTION
  nullable    = false
}

variable "log_client_ip" {
  type        = bool
  default     = null
  description = "Whether to log the client IP address. When null, `logClientIp` is not sent and Azure defaults to `false`."
}

variable "metrics" {
  type        = bool
  default     = null
  description = "Whether to emit custom metrics through the `emit-metric` and `llm-emit-token-metric` policies. Applies only to Application Insights diagnostics. When null, `metrics` is not sent."
}

variable "operation_name_format" {
  type        = string
  default     = null
  description = "Format of the operation name in Application Insights telemetry. Valid values: `Name`, `Url`. When null, `operationNameFormat` is not sent and Azure defaults to `Name`."

  validation {
    condition     = var.operation_name_format == null ? true : contains(["Name", "Url"], var.operation_name_format)
    error_message = "operation_name_format must be `Name` or `Url`."
  }
}

variable "resource_types" {
  type = object({
    apimanagement_service_diagnostics = optional(string, "Microsoft.ApiManagement/service/diagnostics@2024-05-01")
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by the diagnostic submodule.

- `apimanagement_service_diagnostics` - Resource type and API version for the diagnostic.
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

variable "sampling" {
  type = object({
    percentage    = number
    sampling_type = optional(string, "fixed")
  })
  default     = null
  description = <<DESCRIPTION
Sampling settings. When null, `sampling` is not sent.

- `percentage` - (Required) Fixed sampling rate, 0 to 100.
- `sampling_type` - (Optional) Sampling type. Valid value: `fixed`. Defaults to `fixed`.
DESCRIPTION

  validation {
    condition     = var.sampling == null ? true : var.sampling.percentage >= 0 && var.sampling.percentage <= 100
    error_message = "sampling.percentage must be between 0 and 100."
  }
  validation {
    condition     = var.sampling == null ? true : var.sampling.sampling_type == "fixed"
    error_message = "sampling.sampling_type must be `fixed`."
  }
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

variable "verbosity" {
  type        = string
  default     = null
  description = "Verbosity applied to traces emitted by trace policies. Valid values: `verbose`, `information`, `error`. When null, `verbosity` is not sent."

  validation {
    condition     = var.verbosity == null ? true : contains(["verbose", "information", "error"], var.verbosity)
    error_message = "verbosity must be `verbose`, `information` or `error`."
  }
}
