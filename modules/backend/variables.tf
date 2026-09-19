variable "name" {
  type        = string
  description = "The name of the backend."
  nullable    = false

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 80
    error_message = "name must be between 1 and 80 characters."
  }
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

variable "credentials" {
  type = object({
    authorization = optional(object({
      parameter = string
      scheme    = string
    }))
    certificate     = optional(list(string), [])
    certificate_ids = optional(list(string), [])
    header          = optional(map(string), {})
    query           = optional(map(string), {})
  })
  default     = null
  description = <<DESCRIPTION
Credentials for the backend.

- `authorization` - Authorization header configuration.
- `certificate` - List of client certificate thumbprints.
- `certificate_ids` - List of APIM certificate resource IDs.
- `header` - Map of header names to comma-separated values; values are converted to ARM string arrays.
- `query` - Map of query parameter names to comma-separated values; values are converted to ARM string arrays.
DESCRIPTION
  sensitive   = true

  validation {
    condition     = var.credentials == null || length(var.credentials.certificate) <= 32
    error_message = "credentials.certificate must contain at most 32 certificate thumbprints."
  }
  validation {
    condition     = var.credentials == null || length(var.credentials.certificate_ids) <= 32
    error_message = "credentials.certificate_ids must contain at most 32 certificate resource IDs."
  }
  validation {
    condition = var.credentials == null || alltrue([
      for id in var.credentials.certificate_ids :
      can(provider::azapi::parse_resource_id("Microsoft.ApiManagement/service/certificates", id))
    ])
    error_message = "Each credentials.certificate_ids item must be a valid API Management certificate resource ID."
  }
  validation {
    condition = var.credentials == null || var.credentials.authorization == null || (
      length(var.credentials.authorization.parameter) >= 1 &&
      length(var.credentials.authorization.parameter) <= 300 &&
      length(var.credentials.authorization.scheme) >= 1 &&
      length(var.credentials.authorization.scheme) <= 100
    )
    error_message = "credentials.authorization parameter must be 1 to 300 characters and scheme must be 1 to 100 characters."
  }
}

variable "description" {
  type        = string
  default     = null
  description = "Backend description."

  validation {
    condition     = var.description == null || (length(var.description) >= 1 && length(var.description) <= 2000)
    error_message = "description must be between 1 and 2000 characters when set."
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

variable "pool" {
  type = object({
    services = list(object({
      id       = string
      priority = optional(number)
      weight   = optional(number)
    }))
  })
  default     = null
  description = <<DESCRIPTION
Backend pool configuration. Each service references an existing APIM backend resource ID.

- `services` - Backends that participate in the pool.
  - `id` - Fully-qualified `Microsoft.ApiManagement/service/backends` resource ID.
  - `priority` - Optional priority from 0 to 100.
  - `weight` - Optional weight from 0 to 100.
DESCRIPTION

  validation {
    condition = var.pool == null || alltrue([
      for service in var.pool.services :
      can(provider::azapi::parse_resource_id("Microsoft.ApiManagement/service/backends", service.id))
    ])
    error_message = "Each `pool.services[*].id` must be a valid API Management backend resource ID."
  }
  validation {
    condition = var.pool == null || alltrue([
      for service in var.pool.services :
      (service.priority == null || (service.priority >= 0 && service.priority <= 100)) &&
      (service.weight == null || (service.weight >= 0 && service.weight <= 100)) &&
      (service.priority == null || service.priority == floor(service.priority)) &&
      (service.weight == null || service.weight == floor(service.weight))
    ])
    error_message = "Backend pool priorities and weights must be whole numbers between 0 and 100."
  }
}

variable "protocol" {
  type        = string
  default     = null
  description = "Backend communication protocol. Possible values are `http` or `soap`."

  validation {
    condition     = var.protocol == null || contains(["http", "soap"], var.protocol)
    error_message = "`protocol` must be `http`, `soap`, or null."
  }
}

variable "proxy" {
  type = object({
    url      = string
    username = optional(string)
    password = optional(string)
  })
  default     = null
  description = "Proxy server configuration for the backend."
  sensitive   = true

  validation {
    condition     = var.proxy == null || (length(var.proxy.url) >= 1 && length(var.proxy.url) <= 2000)
    error_message = "proxy.url must be between 1 and 2000 characters."
  }
}

variable "resource_id" {
  type        = string
  default     = null
  description = "Management URI of the resource in an external system (ARM resource ID of Logic Apps, Function Apps, etc.)."

  validation {
    condition     = var.resource_id == null || (length(var.resource_id) >= 1 && length(var.resource_id) <= 2000)
    error_message = "resource_id must be between 1 and 2000 characters when set."
  }
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

  validation {
    condition     = var.title == null || (length(var.title) >= 1 && length(var.title) <= 300)
    error_message = "title must be between 1 and 300 characters when set."
  }
}

variable "tls" {
  type = object({
    validate_certificate_chain = optional(bool)
    validate_certificate_name  = optional(bool)
  })
  default     = null
  description = "TLS validation settings for self-signed certificates."
}

variable "type" {
  type        = string
  default     = "Single"
  description = "Backend type. `Single` configures one endpoint; `Pool` distributes traffic across existing backends."
  nullable    = false

  validation {
    condition     = contains(["Single", "Pool"], var.type)
    error_message = "`type` must be `Single` or `Pool`."
  }
}

variable "url" {
  type        = string
  default     = null
  description = "Runtime URL of the backend."

  validation {
    condition     = var.url == null || (length(var.url) >= 1 && length(var.url) <= 2000)
    error_message = "url must be between 1 and 2000 characters when set."
  }
}
