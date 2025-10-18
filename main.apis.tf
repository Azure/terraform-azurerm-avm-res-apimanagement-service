# API Management APIs and Operations
# This file implements APIs, Operations, and their associated policies

# API Version Sets (required for versioned APIs)
resource "azurerm_api_management_api_version_set" "this" {
  for_each = var.api_version_sets

  name                = each.key
  resource_group_name = azurerm_api_management.this.resource_group_name
  api_management_name = azurerm_api_management.this.name
  display_name        = each.value.display_name
  versioning_scheme   = each.value.versioning_scheme
  description         = each.value.description
  version_header_name = each.value.version_header_name
  version_query_name  = each.value.version_query_name

  depends_on = [azurerm_api_management.this]
}

# APIs - Core API definitions
resource "azurerm_api_management_api" "this" {
  for_each = var.apis

  name                  = each.key
  resource_group_name   = azurerm_api_management.this.resource_group_name
  api_management_name   = azurerm_api_management.this.name
  revision              = each.value.revision
  display_name          = each.value.display_name
  path                  = each.value.path
  protocols             = each.value.protocols
  service_url           = each.value.service_url
  subscription_required = each.value.subscription_required

  # API versioning
  version              = each.value.api_version
  version_set_id       = each.value.api_version_set_name != null ? azurerm_api_management_api_version_set.this[each.value.api_version_set_name].id : null
  description          = each.value.description
  revision_description = each.value.revision_description

  # SOAP API settings
  soap_pass_through = each.value.soap_pass_through
  api_type          = each.value.api_type

  # OAuth2 Authorization
  dynamic "oauth2_authorization" {
    for_each = each.value.oauth2_authorization != null ? [each.value.oauth2_authorization] : []

    content {
      authorization_server_name = oauth2_authorization.value.authorization_server_name
      scope                     = oauth2_authorization.value.scope
    }
  }

  # OpenID Connect Authentication
  dynamic "openid_authentication" {
    for_each = each.value.openid_authentication != null ? [each.value.openid_authentication] : []

    content {
      openid_provider_name         = openid_authentication.value.openid_provider_name
      bearer_token_sending_methods = openid_authentication.value.bearer_token_sending_methods
    }
  }

  # Subscription Key Configuration
  dynamic "subscription_key_parameter_names" {
    for_each = each.value.subscription_key_parameter_names != null ? [each.value.subscription_key_parameter_names] : []

    content {
      header = subscription_key_parameter_names.value.header
      query  = subscription_key_parameter_names.value.query
    }
  }

  # Import configuration for OpenAPI, WSDL, WADL
  dynamic "import" {
    for_each = each.value.import != null ? [each.value.import] : []

    content {
      content_format = import.value.content_format
      content_value  = import.value.content_value
      wsdl_selector {
        service_name  = import.value.wsdl_selector != null ? import.value.wsdl_selector.service_name : null
        endpoint_name = import.value.wsdl_selector != null ? import.value.wsdl_selector.endpoint_name : null
      }
    }
  }

  # Source API (for cloning)
  source_api_id = each.value.source_api_id

  # Contact information
  dynamic "contact" {
    for_each = each.value.contact != null ? [each.value.contact] : []

    content {
      email = contact.value.email
      name  = contact.value.name
      url   = contact.value.url
    }
  }

  # License information
  dynamic "license" {
    for_each = each.value.license != null ? [each.value.license] : []

    content {
      name = license.value.name
      url  = license.value.url
    }
  }

  terms_of_service_url = each.value.terms_of_service_url

  depends_on = [
    azurerm_api_management.this,
    azurerm_api_management_api_version_set.this
  ]
}

# API Operations - HTTP operations for each API
resource "azurerm_api_management_api_operation" "this" {
  for_each = local.api_operations

  operation_id        = each.key
  api_name            = azurerm_api_management_api.this[each.value.api_key].name
  api_management_name = azurerm_api_management.this.name
  resource_group_name = azurerm_api_management.this.resource_group_name
  display_name        = each.value.display_name
  method              = each.value.method
  url_template        = each.value.url_template
  description         = each.value.description

  # Request configuration
  dynamic "request" {
    for_each = each.value.request != null ? [each.value.request] : []

    content {
      description = request.value.description

      dynamic "query_parameter" {
        for_each = request.value.query_parameters != null ? request.value.query_parameters : []

        content {
          name          = query_parameter.value.name
          required      = query_parameter.value.required
          type          = query_parameter.value.type
          description   = query_parameter.value.description
          default_value = query_parameter.value.default_value
          values        = query_parameter.value.values
        }
      }

      dynamic "header" {
        for_each = request.value.headers != null ? request.value.headers : []

        content {
          name          = header.value.name
          required      = header.value.required
          type          = header.value.type
          description   = header.value.description
          default_value = header.value.default_value
          values        = header.value.values
        }
      }

      dynamic "representation" {
        for_each = request.value.representations != null ? request.value.representations : []

        content {
          content_type = representation.value.content_type
          sample       = representation.value.sample
          schema_id    = representation.value.schema_id
          type_name    = representation.value.type_name

          dynamic "form_parameter" {
            for_each = representation.value.form_parameters != null ? representation.value.form_parameters : []

            content {
              name          = form_parameter.value.name
              required      = form_parameter.value.required
              type          = form_parameter.value.type
              description   = form_parameter.value.description
              default_value = form_parameter.value.default_value
              values        = form_parameter.value.values
            }
          }
        }
      }
    }
  }

  # Response configuration
  dynamic "response" {
    for_each = each.value.responses != null ? each.value.responses : []

    content {
      status_code = response.value.status_code
      description = response.value.description

      dynamic "header" {
        for_each = response.value.headers != null ? response.value.headers : []

        content {
          name          = header.value.name
          required      = header.value.required
          type          = header.value.type
          description   = header.value.description
          default_value = header.value.default_value
          values        = header.value.values
        }
      }

      dynamic "representation" {
        for_each = response.value.representations != null ? response.value.representations : []

        content {
          content_type = representation.value.content_type
          sample       = representation.value.sample
          schema_id    = representation.value.schema_id
          type_name    = representation.value.type_name

          dynamic "form_parameter" {
            for_each = representation.value.form_parameters != null ? representation.value.form_parameters : []

            content {
              name          = form_parameter.value.name
              required      = form_parameter.value.required
              type          = form_parameter.value.type
              description   = form_parameter.value.description
              default_value = form_parameter.value.default_value
              values        = form_parameter.value.values
            }
          }
        }
      }
    }
  }

  # Template parameters (URL path parameters)
  dynamic "template_parameter" {
    for_each = each.value.template_parameters != null ? each.value.template_parameters : []

    content {
      name          = template_parameter.value.name
      required      = template_parameter.value.required
      type          = template_parameter.value.type
      description   = template_parameter.value.description
      default_value = template_parameter.value.default_value
      values        = template_parameter.value.values
    }
  }

  depends_on = [azurerm_api_management_api.this]
}

# API-Level Policies
resource "azurerm_api_management_api_policy" "this" {
  for_each = { for k, v in var.apis : k => v if v.policy != null }

  api_name            = azurerm_api_management_api.this[each.key].name
  api_management_name = azurerm_api_management.this.name
  resource_group_name = azurerm_api_management.this.resource_group_name
  xml_content         = each.value.policy.xml_content
  xml_link            = each.value.policy.xml_link

  depends_on = [azurerm_api_management_api.this]
}

# API Operation-Level Policies
resource "azurerm_api_management_api_operation_policy" "this" {
  for_each = local.operation_policies

  api_name            = azurerm_api_management_api.this[each.value.api_key].name
  api_management_name = azurerm_api_management.this.name
  resource_group_name = azurerm_api_management.this.resource_group_name
  operation_id        = azurerm_api_management_api_operation.this[each.key].operation_id
  xml_content         = each.value.xml_content
  xml_link            = each.value.xml_link

  depends_on = [
    azurerm_api_management_api.this,
    azurerm_api_management_api_operation.this
  ]
}
