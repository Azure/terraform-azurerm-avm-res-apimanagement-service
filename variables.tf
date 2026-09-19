variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the this resource."
}

variable "parent_id" {
  type        = string
  description = "The fully-qualified ARM resource ID of the resource group into which the API Management service will be deployed."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.parent_id))
    error_message = "`parent_id` must be a valid resource group resource ID."
  }
}

variable "publisher_email" {
  type        = string
  description = "The email of the API Management service publisher."

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.publisher_email))
    error_message = "The publisher_email must be a valid email address."
  }
}

variable "additional_location" {
  type = list(object({
    location             = string
    capacity             = optional(number, null)
    zones                = optional(list(string), null)
    public_ip_address_id = optional(string, null)
    gateway_disabled     = optional(bool, null)
    virtual_network_configuration = optional(object({
      subnet_id = string
    }), null)
  }))
  default     = []
  description = "Additional datacenter locations where the API Management service should be provisioned."
  nullable    = false
}

# API Version Sets for managing API versions
variable "api_version_sets" {
  type = map(object({
    display_name        = string
    versioning_scheme   = string
    description         = optional(string)
    version_header_name = optional(string)
    version_query_name  = optional(string)
  }))
  default     = {}
  description = <<DESCRIPTION
API Version Sets for the API Management service. Version sets enable API versioning using Header, Query, or Segment-based schemes.

- `display_name` - (Required) The display name of the API version set.
- `versioning_scheme` - (Required) The versioning scheme. Valid values: `Header`, `Query`, `Segment`.
- `description` - (Optional) Description of the API version set.
- `version_header_name` - (Optional) Name of the HTTP header parameter for the `Header` versioning scheme. Required when `versioning_scheme` is `Header`.
- `version_query_name` - (Optional) Name of the query string parameter for the `Query` versioning scheme. Required when `versioning_scheme` is `Query`.

Example:
```terraform
api_version_sets = {
  "my-api-versions" = {
    display_name        = "My API Versions"
    versioning_scheme   = "Header"
    version_header_name = "api-version"
    description         = "Version set for My API"
  }
}
```
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue([
      for k, v in var.api_version_sets :
      contains(["Header", "Query", "Segment"], v.versioning_scheme)
    ])
    error_message = "versioning_scheme must be one of: Header, Query, Segment."
  }
  validation {
    condition = alltrue([
      for k, v in var.api_version_sets :
      v.versioning_scheme != "Header" || v.version_header_name != null
    ])
    error_message = "version_header_name is required when versioning_scheme is 'Header'."
  }
  validation {
    condition = alltrue([
      for k, v in var.api_version_sets :
      v.versioning_scheme != "Query" || v.version_query_name != null
    ])
    error_message = "version_query_name is required when versioning_scheme is 'Query'."
  }
}

# APIs - Core API definitions with operations and policies
variable "apis" {
  type = map(object({
    # Basic API properties
    display_name          = string
    path                  = string
    protocols             = optional(list(string), ["https"])
    revision              = optional(string, "1")
    service_url           = optional(string)
    description           = optional(string)
    subscription_required = optional(bool, true)

    # API versioning
    api_version          = optional(string)
    api_version_set_name = optional(string)
    revision_description = optional(string)

    # Import configuration (OpenAPI, WSDL, WADL, etc.)
    import = optional(object({
      content_format = string
      content_value  = string
      wsdl_selector = optional(object({
        service_name  = string
        endpoint_name = string
      }))
    }))

    # Source API for cloning
    source_api_id = optional(string)

    # OAuth2 Authorization
    oauth2_authorization = optional(object({
      authorization_server_name = string
      scope                     = optional(string)
    }))

    # OpenID Connect Authentication
    openid_authentication = optional(object({
      openid_provider_name         = string
      bearer_token_sending_methods = optional(list(string))
    }))

    # Subscription key parameter names
    subscription_key_parameter_names = optional(object({
      header = string
      query  = string
    }))

    # Contact information
    contact = optional(object({
      email = optional(string)
      name  = optional(string)
      url   = optional(string)
    }))

    # License information
    license = optional(object({
      name = optional(string)
      url  = optional(string)
    }))

    terms_of_service_url = optional(string)

    # API-level policy
    policy = optional(object({
      xml_content = optional(string)
      xml_link    = optional(string)
    }))

    # API operations
    operations = optional(map(object({
      display_name = string
      method       = string
      url_template = string
      description  = optional(string)

      # Template parameters (URL path parameters)
      template_parameters = optional(list(object({
        name          = string
        required      = bool
        type          = string
        description   = optional(string)
        default_value = optional(string)
        values        = optional(list(string))
      })))

      # Request configuration
      request = optional(object({
        description = optional(string)

        query_parameters = optional(list(object({
          name          = string
          required      = bool
          type          = string
          description   = optional(string)
          default_value = optional(string)
          values        = optional(list(string))
        })))

        headers = optional(list(object({
          name          = string
          required      = bool
          type          = string
          description   = optional(string)
          default_value = optional(string)
          values        = optional(list(string))
        })))

        representations = optional(list(object({
          content_type = string
          schema_id    = optional(string)
          type_name    = optional(string)

          form_parameters = optional(list(object({
            name          = string
            required      = bool
            type          = string
            description   = optional(string)
            default_value = optional(string)
            values        = optional(list(string))
          })))
        })))
      }))

      # Response configuration
      responses = optional(list(object({
        status_code = number
        description = optional(string)

        headers = optional(list(object({
          name          = string
          required      = bool
          type          = string
          description   = optional(string)
          default_value = optional(string)
          values        = optional(list(string))
        })))

        representations = optional(list(object({
          content_type = string
          schema_id    = optional(string)
          type_name    = optional(string)

          form_parameters = optional(list(object({
            name          = string
            required      = bool
            type          = string
            description   = optional(string)
            default_value = optional(string)
            values        = optional(list(string))
          })))
        })))
      })))

      # Operation-level policy
      policy = optional(object({
        xml_content = optional(string)
        xml_link    = optional(string)
      }))
    })), {})
  }))
  default     = {}
  description = <<DESCRIPTION
APIs for the API Management service. APIs define the operations available to API consumers.

- `display_name` - (Required) The display name of the API.
- `path` - (Required) The relative path for the API. Must be unique within the API Management service.
- `protocols` - (Optional) A list of protocols the API supports. Valid values: `http`, `https`, `ws`, `wss`. Defaults to `["https"]`.
- `revision` - (Optional) The revision number of the API. Defaults to `"1"`.
- `service_url` - (Optional) The backend service URL for the API.
- `description` - (Optional) Description of the API.
- `subscription_required` - (Optional) Whether a subscription key is required to access the API. Defaults to `true`.

Versioning:
- `api_version` - (Optional) The version identifier for the API.
- `api_version_set_name` - (Optional) The name of the API version set to associate with this API.
- `revision_description` - (Optional) Description of the API revision.

Import:
- `import` - (Optional) Import configuration for OpenAPI, WSDL, WADL specifications.
  - `content_format` - (Required) Format of the content. Valid values: `openapi`, `openapi+json`, `openapi+json-link`, `openapi-link`, `swagger-json`, `swagger-link-json`, `wadl-link-json`, `wadl-xml`, `wsdl`, `wsdl-link`.
  - `content_value` - (Required) The API definition content or URL.
  - `wsdl_selector` - (Optional) WSDL selector for SOAP APIs.

Operations:
- `operations` - (Optional) Map of API operations. Each operation defines an HTTP method and URL template.

Policies:
- `policy` - (Optional) API-level policy configuration.
  - `xml_content` - (Optional) XML policy content.
  - `xml_link` - (Optional) URL to XML policy content.

Example:
```terraform
apis = {
  "petstore-api" = {
    display_name = "Petstore API"
    path         = "petstore"
    protocols    = ["https"]
    service_url  = "https://petstore.swagger.io/v2"

    operations = {
      "get-pets" = {
        display_name = "Get all pets"
        method       = "GET"
        url_template = "/pets"
      }
    }
  }
}
```
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue([
      for k, v in var.apis :
      can(regex("^[^*#&+:<>?]+$", v.path))
    ])
    error_message = "API path cannot contain the following characters: *, #, &, +, :, <, >, ?."
  }
  validation {
    condition = alltrue([
      for k, v in var.apis :
      alltrue([
        for protocol in v.protocols :
        contains(["http", "https", "ws", "wss"], protocol)
      ])
    ])
    error_message = "API protocols must be one of: http, https, ws, wss."
  }
  validation {
    condition = alltrue(flatten([
      for k, v in var.apis : [
        for operation_key, operation_value in v.operations :
        contains(["GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS", "TRACE"], operation_value.method)
      ]
    ]))
    error_message = "API operation method must be one of: GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS, TRACE."
  }
}

# Backends for API Management Service
variable "backends" {
  type = map(object({
    type        = optional(string, "Single")
    protocol    = optional(string)
    url         = optional(string)
    description = optional(string)
    resource_id = optional(string)
    title       = optional(string)

    credentials = optional(object({
      authorization = optional(object({
        parameter = string
        scheme    = string
      }))
      certificate     = optional(list(string), [])
      certificate_ids = optional(list(string), [])
      header          = optional(map(string), {})
      query           = optional(map(string), {})
    }))

    proxy = optional(object({
      url      = string
      username = optional(string)
      password = optional(string)
    }))

    pool = optional(object({
      services = list(object({
        backend_name = optional(string)
        backend_id   = optional(string)
        priority     = optional(number)
        weight       = optional(number)
      }))
    }))

    service_fabric_cluster = optional(object({
      client_certificate_thumbprint    = optional(string)
      client_certificate_id            = optional(string)
      management_endpoints             = list(string)
      max_partition_resolution_retries = number
      server_certificate_thumbprints   = optional(list(string), [])
      server_x509_name = optional(list(object({
        issuer_certificate_thumbprint = string
        name                          = string
      })), [])
    }))

    tls = optional(object({
      validate_certificate_chain = optional(bool)
      validate_certificate_name  = optional(bool)
    }))
  }))
  default     = {}
  description = <<DESCRIPTION
Backends for the API Management service. Backends represent the backend HTTP endpoint that an API operation forwards requests to.

- `type` - (Optional) `Single` or `Pool`. Defaults to `Single`.
- `protocol` - Required for `Single`. The protocol used by the backend host: `http` or `soap`.
- `url` - Required for `Single`. The backend host URL (e.g., `https://backend.example.com/api`). Avoid trailing slashes.
- `description` - (Optional) Description of the backend.
- `resource_id` - (Optional) The ARM Resource ID of the backend host in an external system (e.g., Logic Apps, Function Apps, AI Foundry / Cognitive Services).
- `title` - (Optional) The title of the backend.
- `credentials` - (Optional) Credentials for the backend.
  - `authorization` - (Optional) Authorization header configuration.
    - `parameter` - (Required) The authentication parameter value.
    - `scheme` - (Required) The authentication scheme name.
  - `certificate` - (Optional) List of client certificate thumbprints for the backend.
  - `certificate_ids` - (Optional) List of APIM certificate resource IDs for the backend.
  - `header` - (Optional) Map of header name to comma-separated header values.
  - `query` - (Optional) Map of query parameter name to comma-separated values.
- `proxy` - (Optional) Proxy server configuration.
  - `url` - (Required) The URL of the proxy server.
  - `username` - (Optional) The username to connect to the proxy server.
  - `password` - (Optional) The password to connect to the proxy server.
- `pool` - Required for `Pool`. Backend services that receive traffic.
  - `backend_name` - Key of another `backends` entry with `type = "Single"`.
  - `backend_id` - Existing APIM backend resource ID. Exactly one of `backend_name` or `backend_id` is required.
  - `priority` - Optional priority from 0 to 100.
  - `weight` - Optional weight from 0 to 100.
- `service_fabric_cluster` - (Optional) Service Fabric cluster backend configuration.
  - `client_certificate_thumbprint` - (Optional) Client certificate thumbprint for the management endpoint.
  - `client_certificate_id` - (Optional) Client certificate resource ID for the management endpoint.
  - `management_endpoints` - (Required) List of cluster management endpoints.
  - `max_partition_resolution_retries` - (Required) Maximum retries when resolving the partition.
  - `server_certificate_thumbprints` - (Optional) List of server certificate thumbprints.
  - `server_x509_name` - (Optional) List of server X.509 certificate names.
- `tls` - (Optional) TLS validation settings for self-signed certificates.
  - `validate_certificate_chain` - (Optional) Whether to validate the SSL certificate chain.
  - `validate_certificate_name` - (Optional) Whether to validate the SSL certificate name.

Example:
```terraform
backends = {
  "httpbin-backend" = {
    protocol    = "http"
    url         = "https://httpbin.org"
    description = "HTTPBin test backend"
    tls = {
      validate_certificate_chain = true
      validate_certificate_name  = true
    }
  }
  "ai-foundry-backend" = {
    protocol    = "http"
    url         = "https://my-ai-service.cognitiveservices.azure.com/openai"
    description = "Azure AI Foundry backend"
    resource_id = "/subscriptions/.../providers/Microsoft.CognitiveServices/accounts/my-ai-service"
  }
}
```
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue([
      for k, v in var.backends :
      contains(["Single", "Pool"], v.type)
    ])
    error_message = "Backend type must be one of: Single, Pool."
  }
  validation {
    condition = alltrue([
      for name in keys(var.backends) :
      length(name) >= 1 && length(name) <= 80
    ])
    error_message = "Backend names must be between 1 and 80 characters."
  }
  validation {
    condition = alltrue([
      for k, v in var.backends :
      v.type == "Single" ? (
        v.protocol != null &&
        v.url != null &&
        v.pool == null &&
        contains(["http", "soap"], v.protocol)
        ) : (
        v.protocol == null &&
        v.url == null &&
        v.pool != null &&
        length(v.pool.services) > 0
      )
    ])
    error_message = "Single backends require `protocol` and `url` and cannot set `pool`; Pool backends require non-empty `pool.services` and cannot set `protocol` or `url`."
  }
  validation {
    condition = alltrue(flatten([
      for _, backend in var.backends : backend.pool == null ? [] : [
        for service in backend.pool.services :
        (service.backend_name == null) != (service.backend_id == null)
      ]
    ]))
    error_message = "Each backend pool service must set exactly one of `backend_name` or `backend_id`."
  }
  validation {
    condition = alltrue(flatten([
      for _, backend in var.backends : backend.pool == null ? [] : [
        for service in backend.pool.services :
        service.backend_name == null || try(var.backends[service.backend_name].type == "Single", false)
      ]
    ]))
    error_message = "Each `backend_name` in a pool must identify a Single backend in the same `backends` map."
  }
  validation {
    condition = alltrue(flatten([
      for _, backend in var.backends : backend.pool == null ? [] : [
        for service in backend.pool.services :
        service.backend_id == null || can(provider::azapi::parse_resource_id("Microsoft.ApiManagement/service/backends", service.backend_id))
      ]
    ]))
    error_message = "Each `backend_id` in a pool must be a valid API Management backend resource ID."
  }
  validation {
    condition = alltrue(flatten([
      for _, backend in var.backends : backend.pool == null ? [] : [
        for service in backend.pool.services :
        (service.priority == null || (service.priority >= 0 && service.priority <= 100)) &&
        (service.weight == null || (service.weight >= 0 && service.weight <= 100)) &&
        (service.priority == null || service.priority == floor(service.priority)) &&
        (service.weight == null || service.weight == floor(service.weight))
      ]
    ]))
    error_message = "Backend pool priorities and weights must be whole numbers between 0 and 100."
  }
  validation {
    condition = alltrue([
      for _, backend in var.backends :
      backend.type == "Single" || (
        backend.credentials == null &&
        backend.proxy == null &&
        backend.resource_id == null &&
        backend.service_fabric_cluster == null &&
        backend.tls == null
      )
    ])
    error_message = "Pool backends cannot set `credentials`, `proxy`, `resource_id`, `service_fabric_cluster`, or `tls`."
  }
  validation {
    condition = alltrue([
      for _, backend in var.backends :
      backend.credentials == null || length(backend.credentials.certificate) <= 32
    ])
    error_message = "Backend credentials may contain at most 32 certificate thumbprints."
  }
  validation {
    condition = alltrue([
      for _, backend in var.backends :
      backend.credentials == null || length(backend.credentials.certificate_ids) <= 32
    ])
    error_message = "Backend credentials may contain at most 32 certificate resource IDs."
  }
  validation {
    condition = alltrue(flatten([
      for _, backend in var.backends : backend.credentials == null ? [] : [
        for id in backend.credentials.certificate_ids :
        can(provider::azapi::parse_resource_id("Microsoft.ApiManagement/service/certificates", id))
      ]
    ]))
    error_message = "Each backend credentials.certificate_ids item must be a valid API Management certificate resource ID."
  }
  validation {
    condition = alltrue([
      for _, backend in var.backends :
      backend.credentials == null || backend.credentials.authorization == null || (
        length(backend.credentials.authorization.parameter) >= 1 &&
        length(backend.credentials.authorization.parameter) <= 300 &&
        length(backend.credentials.authorization.scheme) >= 1 &&
        length(backend.credentials.authorization.scheme) <= 100
      )
    ])
    error_message = "Backend authorization parameters must be 1 to 300 characters and schemes must be 1 to 100 characters."
  }
  validation {
    condition = alltrue([
      for _, backend in var.backends :
      backend.description == null || (length(backend.description) >= 1 && length(backend.description) <= 2000)
    ])
    error_message = "Backend descriptions must be between 1 and 2000 characters when set."
  }
  validation {
    condition = alltrue([
      for _, backend in var.backends :
      backend.resource_id == null || (length(backend.resource_id) >= 1 && length(backend.resource_id) <= 2000)
    ])
    error_message = "Backend resource IDs must be between 1 and 2000 characters when set."
  }
  validation {
    condition = alltrue([
      for _, backend in var.backends :
      backend.title == null || (length(backend.title) >= 1 && length(backend.title) <= 300)
    ])
    error_message = "Backend titles must be between 1 and 300 characters when set."
  }
  validation {
    condition = alltrue([
      for _, backend in var.backends :
      backend.url == null || (length(backend.url) >= 1 && length(backend.url) <= 2000)
    ])
    error_message = "Backend URLs must be between 1 and 2000 characters when set."
  }
  validation {
    condition = alltrue([
      for _, backend in var.backends :
      backend.proxy == null || (length(backend.proxy.url) >= 1 && length(backend.proxy.url) <= 2000)
    ])
    error_message = "Backend proxy URLs must be between 1 and 2000 characters."
  }
  validation {
    condition = alltrue([
      for k, v in var.backends :
      v.service_fabric_cluster == null ? true : (
        try(v.service_fabric_cluster.client_certificate_thumbprint, null) != null ||
        try(v.service_fabric_cluster.client_certificate_id, null) != null
      )
    ])
    error_message = "When service_fabric_cluster is specified, at least one of client_certificate_thumbprint or client_certificate_id must be set."
  }
}

variable "certificate" {
  type = list(object({
    encoded_certificate  = string
    store_name           = string
    certificate_password = optional(string, null)
  }))
  default     = []
  description = "Certificate configurations for the API Management service."
  nullable    = false
  sensitive   = true

  validation {
    condition     = length(var.certificate) <= 10
    error_message = "A maximum of 10 certificates can be added to an API Management service."
  }
  validation {
    condition     = alltrue([for cert in var.certificate : contains(["CertificateAuthority", "Root"], cert.store_name)])
    error_message = "The store_name must be one of: 'CertificateAuthority', 'Root'."
  }
}

variable "client_certificate_enabled" {
  type        = bool
  default     = false
  description = "Enforce a client certificate to be presented on each request to the gateway. This is only supported when SKU type is Consumption."
  nullable    = false

  validation {
    condition     = startswith(var.sku_name, "Consumption") ? true : !var.client_certificate_enabled
    error_message = "Client certificate is only supported when SKU type is Consumption (e.g., Consumption_1, Consumption_2, etc)."
  }
}

variable "delegation" {
  type = object({
    subscriptions_enabled     = optional(bool, false)
    user_registration_enabled = optional(bool, false)
    url                       = optional(string, null)
    validation_key            = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Developer portal delegation settings for the API Management service.

- `subscriptions_enabled` - Whether subscription delegation is enabled. Defaults to `false`.
- `user_registration_enabled` - Whether user-registration delegation is enabled. Defaults to `false`.
- `url` - Optional delegation endpoint URL.
- `validation_key` - Optional base64-encoded validation key. The module sends this value through AzAPI's write-only body and stores only a SHA-256 change token on the resource.
DESCRIPTION

  validation {
    condition     = var.delegation == null || !can(regex("^(Consumption|BasicV2|StandardV2|PremiumV2)_", var.sku_name))
    error_message = "delegation is not supported for Consumption or V2 SKU tiers."
  }
}

variable "diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of diagnostic settings to create on the API Management service. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.
DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
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

variable "gateway_disabled" {
  type        = bool
  default     = false
  description = "Disable the gateway in the main region? This is only supported when additional_location is set."
  nullable    = false

  validation {
    condition     = var.gateway_disabled == false || length(var.additional_location) > 0
    error_message = "Gateway can only be disabled in the main region when at least one additional location is configured."
  }
}

variable "hostname_configuration" {
  type = object({
    management = optional(list(object({
      host_name                       = string
      key_vault_id                    = optional(string, null)
      certificate                     = optional(string, null)
      certificate_password            = optional(string, null)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string, null)
    })), [])
    portal = optional(list(object({
      host_name                       = string
      key_vault_id                    = optional(string, null)
      certificate                     = optional(string, null)
      certificate_password            = optional(string, null)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string, null)
    })), [])
    developer_portal = optional(list(object({
      host_name                       = string
      key_vault_id                    = optional(string, null)
      certificate                     = optional(string, null)
      certificate_password            = optional(string, null)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string, null)
    })), [])
    proxy = optional(list(object({
      host_name                       = string
      default_ssl_binding             = optional(bool, false)
      key_vault_id                    = optional(string, null)
      certificate                     = optional(string, null)
      certificate_password            = optional(string, null)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string, null)
    })), [])
    scm = optional(list(object({
      host_name                       = string
      key_vault_id                    = optional(string, null)
      certificate                     = optional(string, null)
      certificate_password            = optional(string, null)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string, null)
    })), [])
  })
  default     = null
  description = "Hostname configuration for the API Management service."
  sensitive   = true
}

variable "ignore_body_changes" {
  type = object({
    apimanagement_service           = optional(list(string), [])
    authorization_locks             = optional(list(string), [])
    authorization_role_assignments  = optional(list(string), [])
    insights_diagnostic_settings    = optional(list(string), [])
    network_private_endpoints       = optional(list(string), [])
    network_private_dns_zone_groups = optional(list(string), [])

    apimanagement_service_backends = optional(object({
      apimanagement_service_backends = optional(list(string), [])
    }), {})
    apimanagement_service_named_values = optional(object({
      apimanagement_service_named_values = optional(list(string), [])
    }), {})
    apimanagement_service_policies = optional(object({
      apimanagement_service_policies = optional(list(string), [])
    }), {})
    apimanagement_service_policy_fragments = optional(object({
      apimanagement_service_policy_fragments = optional(list(string), [])
    }), {})
    apimanagement_service_portalsettings = optional(object({
      apimanagement_service_portalsettings = optional(list(string), [])
    }), {})
    apimanagement_service_subscriptions = optional(object({
      apimanagement_service_subscriptions = optional(list(string), [])
    }), {})
    apimanagement_service_tenant = optional(object({
      apimanagement_service_tenant = optional(list(string), [])
    }), {})
    apimanagement_service_api_version_sets = optional(object({
      apimanagement_service_api_version_sets = optional(list(string), [])
    }), {})
    apimanagement_service_apis = optional(object({
      apimanagement_service_apis = optional(list(string), [])
    }), {})
    apimanagement_service_apis_operations = optional(object({
      apimanagement_service_apis_operations = optional(list(string), [])
    }), {})
    apimanagement_service_apis_policies = optional(object({
      apimanagement_service_apis_policies = optional(list(string), [])
    }), {})
    apimanagement_service_apis_operations_policies = optional(object({
      apimanagement_service_apis_operations_policies = optional(list(string), [])
    }), {})
    apimanagement_service_products = optional(object({
      apimanagement_service_products = optional(list(string), [])
    }), {})
    apimanagement_service_products_apis = optional(object({
      apimanagement_service_products_apis = optional(list(string), [])
    }), {})
    apimanagement_service_products_groups = optional(object({
      apimanagement_service_products_groups = optional(list(string), [])
    }), {})
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative paths to ignore for each AzAPI resource. Paths use dot notation.
Changes take effect only after apply.

- `apimanagement_service` - Paths ignored on the API Management service.
- Nested `apimanagement_service_*` objects are passed unchanged to the matching submodule.
- The portal setting and tenant access singleton submodules omit ignored paths from their PATCH request because their Azure APIs do not expose DELETE operations.
DESCRIPTION
  nullable    = false
}

variable "lock" {
  type = object({
    kind  = string
    name  = optional(string, null)
    notes = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
- `notes` - (Optional) Notes stored on the lock.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Controls the Managed Identity configuration on this resource. The following properties can be specified:

- `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
- `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.
DESCRIPTION
  nullable    = false
}

variable "min_api_version" {
  type        = string
  default     = null
  description = "The version which the control plane API calls to API Management service are limited with version equal to or newer than."
}

# Named Values for configuration and secrets management
variable "named_values" {
  type = map(object({
    display_name = string
    value        = optional(string)
    secret       = optional(bool, false)
    tags         = optional(list(string), [])
    value_from_key_vault = optional(object({
      secret_id          = string
      identity_client_id = optional(string)
    }))
  }))
  default     = {}
  description = <<DESCRIPTION
Named values for the API Management service. Named values are a collection of key/value pairs that can be referenced in policies and API configurations.

- `display_name` - (Required) The display name of the named value. Must be unique within the API Management service.
- `value` - (Optional) The value of the named value. Exactly one of `value` or `value_from_key_vault` is required.
- `secret` - (Optional) Whether the value is a secret and should be encrypted. Defaults to `false`.
- `tags` - (Optional) A list of tags that can be used to filter the named values list.
- `value_from_key_vault` - (Optional) A Key Vault configuration for secret values. Exactly one of `value` or `value_from_key_vault` is required, and `secret` must be `true`.
  - `secret_id` - (Required) The secret ID from Key Vault. An unversioned ID enables APIM automatic refresh; a versioned ID pins the named value to that version.
  - `identity_client_id` - (Optional) The client ID of a user-assigned managed identity to use for Key Vault access. If not specified, the system-assigned identity will be used.

Example:
```terraform
named_values = {
  "api-key" = {
    display_name = "API Key"
    value        = "my-secret-key"
    secret       = true
    tags         = ["production", "api"]
  }
  "keyvault-secret" = {
    display_name = "Database Connection String"
    secret       = true
    value_from_key_vault = {
      secret_id = "https://myvault.vault.azure.net/secrets/db-conn/abc123"
    }
  }
}
```
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue([
      for k, v in var.named_values :
      length(v.display_name) >= 1 &&
      length(v.display_name) <= 256 &&
      can(regex("^[A-Za-z0-9-._]+$", v.display_name))
    ])
    error_message = "Named-value display names must be 1 to 256 characters and contain only letters, digits, periods, dashes, and underscores."
  }
  validation {
    condition = alltrue([
      for k, v in var.named_values :
      (v.value != null) != (v.value_from_key_vault != null)
    ])
    error_message = "Each named value must specify exactly one of `value` or `value_from_key_vault`."
  }
  validation {
    condition = alltrue([
      for k, v in var.named_values :
      can(regex("^[a-zA-Z0-9-._]+$", k))
    ])
    error_message = "Named value keys can only contain letters, numbers, hyphens, periods, and underscores."
  }
  validation {
    condition = alltrue([
      for k in keys(var.named_values) :
      length(k) >= 1 && length(k) <= 256
    ])
    error_message = "Named value keys must be between 1 and 256 characters."
  }
  validation {
    condition = alltrue([
      for _, v in var.named_values :
      v.value_from_key_vault == null || v.secret
    ])
    error_message = "Named values using `value_from_key_vault` must set `secret = true`."
  }
  validation {
    condition = alltrue([
      for _, v in var.named_values :
      v.value == null || (trimspace(v.value) != "" && length(v.value) <= 4096)
    ])
    error_message = "Named values must contain a non-whitespace character and have a maximum length of 4096."
  }
}

variable "notification_sender_email" {
  type        = string
  default     = null
  description = "Email address from which the notification will be sent."
}

variable "policy" {
  type = object({
    xml_content = string
  })
  default     = null
  description = <<DESCRIPTION
Service-level (global) policy for the API Management service. This policy applies to all APIs.

- `xml_content` - (Required) The XML content of the policy.

Example:
```terraform
policy = {
  xml_content = <<XML
<policies>
  <inbound>
    <base />
    <cors allow-credentials="true">
      <allowed-origins>
        <origin>https://example.com</origin>
      </allowed-origins>
      <allowed-methods>
        <method>GET</method>
        <method>POST</method>
      </allowed-methods>
    </cors>
    <rate-limit-by-key calls="100" renewal-period="60" counter-key="@(context.Subscription.Id)" />
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
    <set-header name="X-Powered-By" exists-action="delete" />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
XML
}
```
DESCRIPTION
}

variable "policy_fragments" {
  type = map(object({
    value       = string
    description = optional(string)
    format      = optional(string, "rawxml")
  }))
  default     = {}
  description = <<DESCRIPTION
Reusable API Management policy fragments.

- `value` - XML policy fragment content.
- `description` - Optional description, up to 1000 characters.
- `format` - `xml` or `rawxml`. Defaults to `rawxml`.

Policies can reference a fragment with `<include-fragment fragment-id="fragment-name" />`.
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue([
      for _, fragment in var.policy_fragments :
      contains(["xml", "rawxml"], fragment.format)
    ])
    error_message = "Policy fragment format must be `xml` or `rawxml`."
  }
  validation {
    condition = alltrue([
      for _, fragment in var.policy_fragments :
      fragment.description == null || length(fragment.description) <= 1000
    ])
    error_message = "Policy fragment descriptions must not exceed 1000 characters."
  }
  validation {
    condition = alltrue([
      for name in keys(var.policy_fragments) :
      length(name) >= 1 && length(name) <= 80 && can(regex("(^[\\w]+$)|(^[\\w][\\w\\-]+[\\w]$)", name))
    ])
    error_message = "Policy fragment names must be 1 to 80 characters and contain only letters, numbers, underscores, and internal hyphens."
  }
}

variable "private_endpoints" {
  type = map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      name                                   = optional(string, null)
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    lock = optional(object({
      kind  = string
      name  = optional(string, null)
      notes = optional(string, null)
    }), null)
    tags                                    = optional(map(string), null)
    subnet_resource_id                      = string
    subresource_name                        = optional(string, null)
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(set(string), [])
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    location                                = optional(string, null)
    resource_group_name                     = optional(string, null)
    ip_configurations = optional(map(object({
      name               = string
      private_ip_address = string
      member_name        = optional(string)
    })), {})
  }))
  default     = {}
  description = <<DESCRIPTION
A map of private endpoints to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the private endpoint. One will be generated if not set.
- `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.
- `lock` - (Optional) The lock level to apply to the private endpoint. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.
- `tags` - Reserved by the standard private endpoint interface. Private endpoints inherit the module-level `tags`.
- `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
- `subresource_name` - (Optional) APIM private-link subresource name. Defaults to `Gateway`.
- `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. One will be generated if not set.
- `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. If not set, no zone groups will be created and the private endpoint will not be associated with any private DNS zones. DNS records must be managed external to this module.
- `application_security_group_resource_ids` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
- `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set.
- `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set.
- `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the resource group.
- `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of this resource.
- `ip_configurations` - (Optional) A map of IP configurations to create on the private endpoint. If not specified the platform will create one. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `name` - The name of the IP configuration.
  - `private_ip_address` - The private IP address of the IP configuration.
  - `member_name` - (Optional) Private-link member name. Defaults to `default`.
DESCRIPTION
  nullable    = false

  validation {
    condition = length(var.private_endpoints) == 0 || (
    var.virtual_network_type == "None" || can(regex("StandardV2|PremiumV2", var.sku_name))) && !startswith(var.sku_name, "Consumption")
    error_message = "Private endpoints are not supported with Consumption SKU or when using Internal/External virtual network mode (unless using StandardV2 or PremiumV2 SKU)."
  }
}

# This variable is used to determine if the private_dns_zone_group block should be included,
# or if it is to be managed externally, e.g. using Azure Policy.
# https://github.com/Azure/terraform-azurerm-avm-res-keyvault-vault/issues/32
# Alternatively you can use AzAPI, which does not have this issue.
variable "private_endpoints_manage_dns_zone_group" {
  type        = bool
  default     = true
  description = "Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy."
  nullable    = false
}

# Products variable
variable "products" {
  type = map(object({
    display_name          = string
    description           = optional(string)
    terms                 = optional(string)
    subscription_required = optional(bool, false)
    approval_required     = optional(bool, false)
    subscriptions_limit   = optional(number)
    state                 = optional(string, "published") # published, notPublished

    # Associations
    api_names   = optional(list(string), [])
    group_names = optional(list(string), [])
  }))
  default     = {}
  description = <<DESCRIPTION
Products for the API Management service. The map key is the product identifier.

- `display_name` - (Required) The display name of the product.
- `description` - (Optional) Description of the product.
- `terms` - (Optional) Terms of use for the product.
- `subscription_required` - (Optional) Whether a subscription is required to access APIs in this product. Default is `false`.
- `approval_required` - (Optional) Whether subscription approval is required. Default is `false`.
- `subscriptions_limit` - (Optional) Maximum number of subscriptions allowed for this product.
- `state` - (Optional) Publication state of the product. Valid values: `published`, `notPublished`. Default is `published`.
- `api_names` - (Optional) List of API names to associate with this product.
- `group_names` - (Optional) List of group names to associate with this product (e.g., "developers", "administrators", "guests").

Example:
```terraform
products = {
  "starter" = {
    display_name          = "Starter"
    description           = "Starter product for new developers"
    subscription_required = true
    approval_required     = false
    state                 = "published"
    api_names             = ["petstore-api", "weather-api"]
    group_names           = ["developers"]
  }
}
```
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue([
      for k, v in var.products :
      contains(["published", "notPublished"], v.state)
    ])
    error_message = "Product state must be either 'published' or 'notPublished'."
  }
}

variable "protocols" {
  type = object({
    enable_http2 = optional(bool, false)
  })
  default     = null
  description = "Protocol settings for the API Management service."
}

variable "public_ip_address_id" {
  type        = string
  default     = null
  description = "ID of a standard SKU IPv4 Public IP. Only supported on Premium and Developer tiers when deployed in a virtual network."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Is public access to the API Management service allowed? This only applies to the Management plane, not the API gateway or Developer portal."
  nullable    = false
}

variable "publisher_name" {
  type        = string
  default     = "Apim Example Publisher"
  description = "The name of the API Management service publisher."
}

variable "resource_types" {
  type = object({
    apimanagement_service           = optional(string, "Microsoft.ApiManagement/service@2024-05-01")
    authorization_locks             = optional(string, "Microsoft.Authorization/locks@2020-05-01")
    authorization_role_assignments  = optional(string, "Microsoft.Authorization/roleAssignments@2022-04-01")
    insights_diagnostic_settings    = optional(string, "Microsoft.Insights/diagnosticSettings@2021-05-01-preview")
    network_private_endpoints       = optional(string, "Microsoft.Network/privateEndpoints@2024-05-01")
    network_private_dns_zone_groups = optional(string, "Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01")

    # Child submodule slots (no string defaults on parent — children own defaults)
    apimanagement_service_backends = optional(object({
      apimanagement_service_backends = optional(string)
    }), {})
    apimanagement_service_named_values = optional(object({
      apimanagement_service_named_values = optional(string)
    }), {})
    apimanagement_service_policies = optional(object({
      apimanagement_service_policies = optional(string)
    }), {})
    apimanagement_service_policy_fragments = optional(object({
      apimanagement_service_policy_fragments = optional(string)
    }), {})
    apimanagement_service_portalsettings = optional(object({
      apimanagement_service_portalsettings = optional(string)
    }), {})
    apimanagement_service_subscriptions = optional(object({
      apimanagement_service_subscriptions = optional(string)
    }), {})
    apimanagement_service_tenant = optional(object({
      apimanagement_service_tenant = optional(string)
    }), {})
    apimanagement_service_api_version_sets = optional(object({
      apimanagement_service_api_version_sets = optional(string)
    }), {})
    apimanagement_service_apis = optional(object({
      apimanagement_service_apis = optional(string)
    }), {})
    apimanagement_service_apis_operations = optional(object({
      apimanagement_service_apis_operations = optional(string)
    }), {})
    apimanagement_service_apis_policies = optional(object({
      apimanagement_service_apis_policies = optional(string)
    }), {})
    apimanagement_service_apis_operations_policies = optional(object({
      apimanagement_service_apis_operations_policies = optional(string)
    }), {})
    apimanagement_service_products = optional(object({
      apimanagement_service_products = optional(string)
    }), {})
    apimanagement_service_products_apis = optional(object({
      apimanagement_service_products_apis = optional(string)
    }), {})
    apimanagement_service_products_groups = optional(object({
      apimanagement_service_products_groups = optional(string)
    }), {})
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by the module.

- `apimanagement_service` - Primary API Management service.
- `authorization_locks` - Resource locks.
- `authorization_role_assignments` - Role assignments.
- `insights_diagnostic_settings` - Diagnostic settings.
- `network_private_endpoints` - Private endpoints.
- `network_private_dns_zone_groups` - Private DNS zone groups on private endpoints.
- `apimanagement_service_backends` - Overrides for the backend submodule.
- `apimanagement_service_named_values` - Overrides for the named_value submodule.
- `apimanagement_service_policies` - Overrides for the policy submodule.
- `apimanagement_service_policy_fragments` - Overrides for the policy_fragment submodule.
- `apimanagement_service_portalsettings` - Overrides for the portal_setting submodule.
- `apimanagement_service_subscriptions` - Overrides for the subscription submodule.
- `apimanagement_service_tenant` - Overrides for the tenant_access submodule.
- `apimanagement_service_api_version_sets` - Overrides for the api_version_set submodule.
- `apimanagement_service_apis` - Overrides for the api submodule.
- `apimanagement_service_apis_operations` - Overrides for the operation submodule.
- `apimanagement_service_apis_policies` - Overrides for the api_policy submodule.
- `apimanagement_service_apis_operations_policies` - Overrides for the operation_policy submodule.
- `apimanagement_service_products` - Overrides for the product submodule.
- `apimanagement_service_products_apis` - Overrides for the product_api submodule.
- `apimanagement_service_products_groups` - Overrides for the product_group submodule.
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

variable "role_assignment_definition_lookup_enabled" {
  type        = bool
  default     = true
  description = "Whether to look up role definition IDs from names via the Azure API when creating role assignments."
  nullable    = false
}

variable "role_assignment_definition_scope" {
  type        = string
  default     = null
  description = "Scope used to look up role definition IDs. Defaults to `parent_id` (the resource group)."
}

variable "role_assignments" {
  type = map(object({
    name                                   = optional(string, null)
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `name` - Optional deterministic role assignment GUID. A random UUID is generated when omitted.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false
}

variable "security" {
  type = object({
    enable_backend_ssl30                                = optional(bool, false)
    enable_backend_tls10                                = optional(bool, false)
    enable_backend_tls11                                = optional(bool, false)
    enable_backend_tls13                                = optional(bool)
    enable_frontend_ssl30                               = optional(bool, false)
    enable_frontend_tls10                               = optional(bool, false)
    enable_frontend_tls11                               = optional(bool, false)
    enable_frontend_tls13                               = optional(bool)
    tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = optional(bool, false)
    tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = optional(bool, false)
    tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = optional(bool, false)
    tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = optional(bool, false)
    tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes128_cbc_sha_ciphers_enabled         = optional(bool, false)
    tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes256_gcm_sha384_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes256_cbc_sha_ciphers_enabled         = optional(bool, false)
    triple_des_ciphers_enabled                          = optional(bool, false)
  })
  default     = null
  description = <<DESCRIPTION
Security settings for the API Management service.

- `enable_backend_ssl30` - (Optional) Whether to enable SSL 3.0 on the backend. Defaults to `false`.
- `enable_backend_tls10` - (Optional) Whether to enable TLS 1.0 on the backend. Defaults to `false`.
- `enable_backend_tls11` - (Optional) Whether to enable TLS 1.1 on the backend. Defaults to `false`.
- `enable_backend_tls13` - (Optional) Whether to enable TLS 1.3 on the backend. If not set, this module does not attempt to modify backend TLS 1.3 settings. Note: TLS 1.3 support is configured via Azure REST API custom properties.
- `enable_frontend_ssl30` - (Optional) Whether to enable SSL 3.0 on the frontend. Defaults to `false`.
- `enable_frontend_tls10` - (Optional) Whether to enable TLS 1.0 on the frontend. Defaults to `false`.
- `enable_frontend_tls11` - (Optional) Whether to enable TLS 1.1 on the frontend. Defaults to `false`.
- `enable_frontend_tls13` - (Optional) Whether to enable TLS 1.3 on the frontend (client-to-gateway). If not set, this module does not attempt to modify frontend TLS 1.3 settings. Note: TLS 1.3 support is configured via Azure REST API custom properties.
DESCRIPTION
}

variable "sign_in" {
  type = object({
    enabled = bool
  })
  default     = null
  description = "Sign-in settings for the API Management service. When enabled, anonymous users will be redirected to the sign-in page."

  validation {
    condition     = var.sign_in == null || !can(regex("^(Consumption|BasicV2|StandardV2|PremiumV2)_", var.sku_name))
    error_message = "sign_in is not supported for Consumption or V2 SKU tiers."
  }
}

variable "sign_up" {
  type = object({
    enabled = bool
    terms_of_service = object({
      consent_required = bool
      enabled          = bool
      text             = optional(string, null)
    })
  })
  default     = null
  description = "Sign-up settings for the API Management service."

  validation {
    condition     = var.sign_up == null || !can(regex("^(Consumption|BasicV2|StandardV2|PremiumV2)_", var.sku_name))
    error_message = "sign_up is not supported for Consumption or V2 SKU tiers."
  }
}

variable "sku_name" {
  type        = string
  default     = "Developer_1"
  description = "The SKU name of the API Management service."

  validation {
    condition     = can(regex("^Consumption_0$|^Basic_(1|2)$|^BasicV2_([1-9]|10)|^Developer_1$|^Premium_([1-9][0-9]{0,1})$|^PremiumV2_([1-9]|1[0-9]|2[0-9]|30)$|^Standard_[1-4]$|^StandardV2_([1-9]|10)$", var.sku_name))
    error_message = "The sku_name must be one of: Consumption_0, Basic_1, Basic_2, BasicV2_1 through BasicV2_10, Developer_1, Premium_1 through Premium_99, PremiumV2_1 through PremiumV2_30, Standard_1 through Standard_4, or StandardV2_1 through StandardV2_10."
  }
}

# Subscriptions variable
variable "subscriptions" {
  type = map(object({
    display_name     = string
    scope_type       = string           # "product", "api", or "all_apis"
    scope_identifier = optional(string) # Product ID or API name (not needed for "all_apis")
    user_id          = optional(string)
    primary_key      = optional(string)
    secondary_key    = optional(string)
    state            = optional(string, "active") # active, suspended, submitted, rejected, cancelled
    allow_tracing    = optional(bool, false)
  }))
  default     = {}
  description = <<DESCRIPTION
Subscriptions for the API Management service. The map key is the subscription identifier.

- `display_name` - (Required) The display name of the subscription.
- `scope_type` - (Required) The scope type. Valid values: `product`, `api`, `all_apis`.
- `scope_identifier` - (Optional) The product ID or API name. Required for `product` and `api` scope types. Not needed for `all_apis`.
- `user_id` - (Optional) The user ID for this subscription (format: /users/{userId}).
- `primary_key` - (Optional) Custom primary subscription key.
- `secondary_key` - (Optional) Custom secondary subscription key.
- `state` - (Optional) The state of the subscription. Valid values: `active`, `cancelled`, `expired`, `rejected`, `submitted`, `suspended`. Default is `active`.
- `allow_tracing` - (Optional) Whether tracing is allowed. Default is `false`.

Example:
```terraform
subscriptions = {
  "developer-sub" = {
    display_name     = "Developer Subscription"
    scope_type       = "product"
    scope_identifier = "starter"
    state            = "active"
    allow_tracing    = true
  }
  "api-specific-sub" = {
    display_name     = "Petstore API Subscription"
    scope_type       = "api"
    scope_identifier = "petstore-api"
    state            = "active"
  }
}
```
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue([
      for k, v in var.subscriptions :
      contains(["product", "api", "all_apis"], v.scope_type)
    ])
    error_message = "Subscription scope_type must be one of: product, api, all_apis."
  }
  validation {
    condition = alltrue([
      for k, v in var.subscriptions :
      (v.scope_type == "all_apis") == (v.scope_identifier == null)
    ])
    error_message = "Subscription scope_identifier is required for `product` and `api` scopes and must be omitted for `all_apis`."
  }
  validation {
    condition = alltrue([
      for k, v in var.subscriptions :
      contains(["active", "cancelled", "expired", "rejected", "submitted", "suspended"], v.state)
    ])
    error_message = "Subscription state must be one of: active, cancelled, expired, rejected, submitted, suspended."
  }
  validation {
    condition = alltrue([
      for name in keys(var.subscriptions) :
      length(name) >= 1 && length(name) <= 256 && can(regex("^[^*#&+:<>?]+$", name))
    ])
    error_message = "Subscription identifiers must be 1 to 256 characters and cannot contain `*`, `#`, `&`, `+`, `:`, `<`, `>`, or `?`."
  }
  validation {
    condition = alltrue([
      for _, subscription in var.subscriptions :
      length(subscription.display_name) >= 1 && length(subscription.display_name) <= 100
    ])
    error_message = "Subscription display names must be between 1 and 100 characters."
  }
  validation {
    condition = alltrue([
      for _, subscription in var.subscriptions :
      subscription.primary_key == null || (length(subscription.primary_key) >= 1 && length(subscription.primary_key) <= 256)
    ])
    error_message = "Custom primary subscription keys must be between 1 and 256 characters."
  }
  validation {
    condition = alltrue([
      for _, subscription in var.subscriptions :
      subscription.secondary_key == null || (length(subscription.secondary_key) >= 1 && length(subscription.secondary_key) <= 256)
    ])
    error_message = "Custom secondary subscription keys must be between 1 and 256 characters."
  }
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "tenant_access" {
  type = object({
    enabled = bool
  })
  default     = null
  description = "Controls whether direct access to the management API is enabled. The sensitive `tenant_access` output contains the generated primary and secondary keys when this input is configured."

  validation {
    condition     = var.tenant_access == null || !can(regex("^(Consumption|BasicV2|StandardV2|PremiumV2)_", var.sku_name))
    error_message = "tenant_access is not supported for Consumption or V2 SKU tiers."
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

variable "virtual_network_subnet_id" {
  type        = string
  default     = null
  description = "The ID of the subnet in the virtual network where the API Management service will be deployed."

  validation {
    condition     = var.virtual_network_type == "None" ? var.virtual_network_subnet_id == null : true
    error_message = "The virtual_network_subnet_id must not be set when virtual_network_type is None."
  }
}

variable "virtual_network_type" {
  type        = string
  default     = "None"
  description = "The type of virtual network configuration for the API Management service."

  validation {
    condition     = contains(["None", "External", "Internal"], var.virtual_network_type)
    error_message = "The virtual_network_type must be one of: None, External, or Internal."
  }
}

variable "zones" {
  type        = list(string)
  default     = null
  description = "Specifies a list of Availability Zones in which this API Management service should be located. Only supported in the Premium tier."

  validation {
    condition     = var.zones == null || startswith(var.sku_name, "Premium")
    error_message = "Availability Zones are only supported in the Premium tier."
  }
}
