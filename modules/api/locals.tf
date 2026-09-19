locals {
  has_import = var.format != null || var.value != null || var.wsdl_selector != null

  resource_body = {
    properties = {
      apiRevision            = var.api_revision
      apiRevisionDescription = var.api_revision_description
      apiType                = var.api_type
      apiVersion             = var.api_version
      apiVersionDescription  = var.api_version_description
      apiVersionSetId        = var.api_version_set_id
      authenticationSettings = var.authentication_settings == null ? null : {
        oAuth2 = var.authentication_settings.o_auth2 == null ? null : {
          authorizationServerId = var.authentication_settings.o_auth2.authorization_server_id
          scope                 = var.authentication_settings.o_auth2.scope
        }
        oAuth2AuthenticationSettings = var.authentication_settings.o_auth2_authentication_settings == null ? null : [
          for item in var.authentication_settings.o_auth2_authentication_settings : {
            authorizationServerId = item.authorization_server_id
            scope                 = item.scope
          }
        ]
        openid = var.authentication_settings.openid == null ? null : {
          bearerTokenSendingMethods = var.authentication_settings.openid.bearer_token_sending_methods
          openidProviderId          = var.authentication_settings.openid.openid_provider_id
        }
        openidAuthenticationSettings = var.authentication_settings.openid_authentication_settings == null ? null : [
          for item in var.authentication_settings.openid_authentication_settings : {
            bearerTokenSendingMethods = item.bearer_token_sending_methods
            openidProviderId          = item.openid_provider_id
          }
        ]
      }
      contact = var.contact == null ? null : {
        email = var.contact.email
        name  = var.contact.name
        url   = var.contact.url
      }
      description = var.description
      displayName = var.display_name
      license = var.license == null ? null : {
        name = var.license.name
        url  = var.license.url
      }
      path        = var.path
      protocols   = var.protocols
      serviceUrl  = var.service_url
      sourceApiId = var.source_api_id
      subscriptionKeyParameterNames = var.subscription_key_parameter_names == null ? null : {
        header = var.subscription_key_parameter_names.header
        query  = var.subscription_key_parameter_names.query
      }
      subscriptionRequired             = var.subscription_required
      termsOfServiceUrl                = var.terms_of_service_url
      translateRequiredQueryParameters = var.translate_required_query_parameters
      type                             = var.type
    }
  }

  sensitive_body = !local.has_import ? null : {
    properties = {
      format = var.format
      value  = var.value
      wsdlSelector = var.wsdl_selector == null ? null : {
        wsdlEndpointName = var.wsdl_selector.wsdl_endpoint_name
        wsdlServiceName  = var.wsdl_selector.wsdl_service_name
      }
    }
  }

  # Detect sensitive_body changes without persisting secret values in state comparisons.
  sensitive_body_version = !local.has_import ? null : {
    "properties.format"       = var.format != null ? parseint(substr(sha256(tostring(var.format)), 0, 8), 16) : null
    "properties.value"        = var.value != null ? parseint(substr(sha256(var.value), 0, 8), 16) : null
    "properties.wsdlSelector" = var.wsdl_selector != null ? parseint(substr(sha256(jsonencode(var.wsdl_selector)), 0, 8), 16) : null
  }
  main_location = "unknown"
}
