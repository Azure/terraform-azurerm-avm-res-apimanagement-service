variable "name" {
  type        = string
  description = "The API entity name. For revisions other than the default, use `{apiId};rev={n}`."
  nullable    = false
}

variable "parent_id" {
  type        = string
  description = "The fully-qualified ARM resource ID of the API Management service that will contain this API."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.ApiManagement/service", var.parent_id))
    error_message = "`parent_id` must be a valid API Management service resource ID."
  }
}

variable "path" {
  type        = string
  description = "Relative URL uniquely identifying this API within the API Management service."
  nullable    = false

  validation {
    condition     = length(var.path) <= 400
    error_message = "path must have a maximum length of 400."
  }
}

variable "api_revision" {
  type        = string
  default     = null
  description = "Revision of the API. Defaults to `1` when omitted at the service."

  validation {
    condition     = var.api_revision == null || (length(var.api_revision) >= 1 && length(var.api_revision) <= 100)
    error_message = "api_revision must be between 1 and 100 characters."
  }
}

variable "api_revision_description" {
  type        = string
  default     = null
  description = "Description of the API revision."

  validation {
    condition     = var.api_revision_description == null || length(var.api_revision_description) <= 256
    error_message = "api_revision_description must have a maximum length of 256."
  }
}

variable "api_type" {
  type        = string
  default     = null
  description = "Type of API: `http`, `soap`, `websocket`, or `graphql`."
}

variable "api_version" {
  type        = string
  default     = null
  description = "Version identifier when the API is versioned."

  validation {
    condition     = var.api_version == null || length(var.api_version) <= 100
    error_message = "api_version must have a maximum length of 100."
  }
}

variable "api_version_description" {
  type        = string
  default     = null
  description = "Description of the API version."

  validation {
    condition     = var.api_version_description == null || length(var.api_version_description) <= 256
    error_message = "api_version_description must have a maximum length of 256."
  }
}

variable "api_version_set_id" {
  type        = string
  default     = null
  description = "Resource ID of the related API version set."
}

variable "authentication_settings" {
  type = object({
    o_auth2 = optional(object({
      authorization_server_id = optional(string)
      scope                   = optional(string)
    }))
    o_auth2_authentication_settings = optional(list(object({
      authorization_server_id = optional(string)
      scope                   = optional(string)
    })))
    openid = optional(object({
      bearer_token_sending_methods = optional(list(string))
      openid_provider_id           = optional(string)
    }))
    openid_authentication_settings = optional(list(object({
      bearer_token_sending_methods = optional(list(string))
      openid_provider_id           = optional(string)
    })))
  })
  default     = null
  description = "Collection of authentication settings included into this API."
}

variable "contact" {
  type = object({
    email = optional(string)
    name  = optional(string)
    url   = optional(string)
  })
  default     = null
  description = "Contact information for the API."
}

variable "description" {
  type        = string
  default     = null
  description = "Description of the API. May include HTML formatting tags."
}

variable "display_name" {
  type        = string
  default     = null
  description = "API display name. Must be 1 to 300 characters long."

  validation {
    condition     = var.display_name == null || (length(var.display_name) >= 1 && length(var.display_name) <= 300)
    error_message = "display_name must be between 1 and 300 characters."
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

variable "format" {
  type        = string
  default     = null
  description = "Import content format (for example `openapi`, `swagger-json`, `wsdl`)."
  sensitive   = true
}

variable "ignore_body_changes" {
  type = object({
    apimanagement_service_apis = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths ignored on the API resource. Paths use dot notation.
Changes take effect only after apply. Ignored configuration is not sent to Azure.

- `apimanagement_service_apis` - Paths ignored on the API resource.
DESCRIPTION
  nullable    = false
}

variable "license" {
  type = object({
    name = optional(string)
    url  = optional(string)
  })
  default     = null
  description = "License information for the API."
}

variable "protocols" {
  type        = list(string)
  default     = null
  description = "Protocols on which operations in this API can be invoked."
}

variable "resource_types" {
  type = object({
    apimanagement_service_apis = optional(string, "Microsoft.ApiManagement/service/apis@2024-05-01")
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by the api submodule.

- `apimanagement_service_apis` - Resource type and API version for the API.
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
  description = "Retry configuration for AzAPI resources."
}

variable "service_url" {
  type        = string
  default     = null
  description = "Absolute URL of the backend service implementing this API."

  validation {
    condition     = var.service_url == null || length(var.service_url) <= 2000
    error_message = "service_url must have a maximum length of 2000."
  }
}

variable "source_api_id" {
  type        = string
  default     = null
  description = "API identifier of the source API when cloning."
}

variable "subscription_key_parameter_names" {
  type = object({
    header = optional(string)
    query  = optional(string)
  })
  default     = null
  description = "Subscription key header and query parameter names."
}

variable "subscription_required" {
  type        = bool
  default     = null
  description = "Whether a subscription is required to access the API."
}

variable "terms_of_service_url" {
  type        = string
  default     = null
  description = "URL to the Terms of Service for the API."
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

variable "translate_required_query_parameters" {
  type        = string
  default     = null
  description = "Strategy for translating required query parameters: `template` or `query`."
}

variable "type" {
  type        = string
  default     = null
  description = "Type of API (legacy ARM `type` property)."
}

variable "value" {
  type        = string
  default     = null
  description = "Import content value (definition body or link target depending on format)."
  sensitive   = true
}

variable "wsdl_selector" {
  type = object({
    wsdl_endpoint_name = optional(string)
    wsdl_service_name  = optional(string)
  })
  default     = null
  description = "Criteria to limit WSDL import to a subset of the document."
  sensitive   = true
}
