variable "name" {
  type        = string
  description = "The name of the backend."
  nullable    = false
}

variable "parent_id" {
  type        = string
  description = "The fully-qualified ARM resource ID of the API Management service that will contain the backend."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.ApiManagement/service", var.parent_id))
    error_message = "`parent_id` must be a valid API Management service resource ID."
  }
}

variable "protocol" {
  type        = string
  description = "Backend communication protocol. Possible values are `http` or `soap`."
  nullable    = false
}

variable "url" {
  type        = string
  description = "Runtime URL of the backend."
  nullable    = false
}

variable "credentials" {
  type = object({
    authorization = optional(object({
      parameter = optional(string)
      scheme    = optional(string)
    }))
    certificate = optional(list(string), [])
    header      = optional(map(string), {})
    query       = optional(map(string), {})
  })
  default     = null
  description = <<DESCRIPTION
Credentials for the backend.

- `authorization` - Authorization header configuration.
- `certificate` - List of client certificate thumbprints.
- `header` - Map of header name to comma-separated values (AzureRM shape; converted to string arrays for ARM).
- `query` - Map of query parameter name to comma-separated values (AzureRM shape; converted to string arrays for ARM).
DESCRIPTION
}

variable "description" {
  type        = string
  default     = null
  description = "Backend description."
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
    apimanagement_service_backends = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths ignored on the backend resource. Paths use dot notation.
Changes take effect only after apply. Ignored configuration is not sent to Azure.

- `apimanagement_service_backends` - Paths ignored on the backend resource.
DESCRIPTION
  nullable    = false
}

variable "proxy" {
  type = object({
    url      = string
    username = string
    password = optional(string)
  })
  default     = null
  description = "Proxy server configuration for the backend."
}

variable "resource_id" {
  type        = string
  default     = null
  description = "Management URI of the resource in an external system (ARM resource ID of Logic Apps, Function Apps, etc.)."
}

variable "resource_types" {
  type = object({
    apimanagement_service_backends = optional(string, "Microsoft.ApiManagement/service/backends@2024-05-01")
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by the backend submodule.

- `apimanagement_service_backends` - Resource type and API version for the backend.
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

variable "service_fabric_cluster" {
  type = object({
    client_certificate_thumbprint    = optional(string)
    client_certificate_id            = optional(string)
    management_endpoints             = list(string)
    max_partition_resolution_retries = number
    server_certificate_thumbprints   = optional(list(string), [])
    server_x509_name = optional(list(object({
      issuer_certificate_thumbprint = string
      name                          = string
    })), [])
  })
  default     = null
  description = <<DESCRIPTION
Service Fabric cluster backend configuration (AzureRM-shaped). Mapped to `properties.properties.serviceFabricCluster` in the ARM body.
DESCRIPTION
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

variable "title" {
  type        = string
  default     = null
  description = "Backend title."
}

variable "tls" {
  type = object({
    validate_certificate_chain = optional(bool)
    validate_certificate_name  = optional(bool)
  })
  default     = null
  description = "TLS validation settings for self-signed certificates."
}
