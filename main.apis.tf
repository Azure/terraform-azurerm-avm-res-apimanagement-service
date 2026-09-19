# API Management APIs, operations, and policies.

module "api" {
  source   = "./modules/api"
  for_each = local.api_keys

  name                     = "${each.key};rev=${coalesce(nonsensitive(var.apis[each.key].revision), "1")}"
  parent_id                = azapi_resource.this.id
  path                     = nonsensitive(var.apis[each.key].path)
  api_revision             = nonsensitive(var.apis[each.key].revision)
  api_revision_description = nonsensitive(var.apis[each.key].revision_description)
  api_version              = nonsensitive(var.apis[each.key].api_version)
  api_version_set_id       = nonsensitive(var.apis[each.key].api_version_set_name) != null ? module.api_version_set[nonsensitive(var.apis[each.key].api_version_set_name)].resource_id : null
  authentication_settings = nonsensitive(var.apis[each.key].oauth2_authorization) != null || nonsensitive(var.apis[each.key].openid_authentication) != null ? {
    o_auth2 = nonsensitive(var.apis[each.key].oauth2_authorization) == null ? null : {
      authorization_server_id = nonsensitive(var.apis[each.key].oauth2_authorization.authorization_server_name)
      scope                   = nonsensitive(var.apis[each.key].oauth2_authorization.scope)
    }
    openid = nonsensitive(var.apis[each.key].openid_authentication) == null ? null : {
      openid_provider_id           = nonsensitive(var.apis[each.key].openid_authentication.openid_provider_name)
      bearer_token_sending_methods = nonsensitive(var.apis[each.key].openid_authentication.bearer_token_sending_methods)
    }
  } : null
  contact                          = nonsensitive(var.apis[each.key].contact)
  description                      = nonsensitive(var.apis[each.key].description)
  display_name                     = nonsensitive(var.apis[each.key].display_name)
  enable_telemetry                 = var.enable_telemetry
  format                           = nonsensitive(try(var.apis[each.key].import.content_format, null))
  ignore_body_changes              = var.ignore_body_changes.apimanagement_service_apis
  license                          = nonsensitive(var.apis[each.key].license)
  protocols                        = nonsensitive(var.apis[each.key].protocols)
  resource_types                   = var.resource_types.apimanagement_service_apis
  retry                            = var.retry
  service_url                      = nonsensitive(var.apis[each.key].service_url)
  source_api_id                    = nonsensitive(var.apis[each.key].source_api_id)
  subscription_key_parameter_names = nonsensitive(var.apis[each.key].subscription_key_parameter_names)
  subscription_required            = nonsensitive(var.apis[each.key].subscription_required)
  terms_of_service_url             = nonsensitive(var.apis[each.key].terms_of_service_url)
  timeouts                         = var.timeouts
  value                            = try(var.apis[each.key].import.content_value, null)
  wsdl_selector = nonsensitive(try(var.apis[each.key].import.wsdl_selector, null)) == null ? null : {
    wsdl_endpoint_name = nonsensitive(var.apis[each.key].import.wsdl_selector.endpoint_name)
    wsdl_service_name  = nonsensitive(var.apis[each.key].import.wsdl_selector.service_name)
  }

  depends_on = [
    azapi_resource.this,
    module.api_version_set,
  ]
}

module "operation" {
  source   = "./modules/operation"
  for_each = local.api_operations

  display_name        = each.value.display_name
  method              = each.value.method
  name                = each.value.operation_key
  parent_id           = module.api[each.value.api_key].resource_id
  url_template        = each.value.url_template
  description         = each.value.description
  enable_telemetry    = var.enable_telemetry
  ignore_body_changes = var.ignore_body_changes.apimanagement_service_apis_operations
  request             = each.value.request
  resource_types      = var.resource_types.apimanagement_service_apis_operations
  responses           = each.value.responses
  retry               = var.retry
  template_parameters = each.value.template_parameters
  timeouts            = var.timeouts
}

module "api_policy" {
  source   = "./modules/api_policy"
  for_each = local.api_policies

  parent_id           = module.api[each.key].resource_id
  value               = coalesce(each.value.xml_content, each.value.xml_link)
  enable_telemetry    = var.enable_telemetry
  format              = each.value.xml_link != null ? "xml-link" : "rawxml"
  ignore_body_changes = var.ignore_body_changes.apimanagement_service_apis_policies
  name                = "policy"
  resource_types      = var.resource_types.apimanagement_service_apis_policies
  retry               = var.retry
  timeouts            = var.timeouts

  depends_on = [
    module.operation,
    module.backend,
    module.backend_pool,
    module.named_value,
    module.policy_fragment,
  ]
}

module "operation_policy" {
  source   = "./modules/operation_policy"
  for_each = local.operation_policies

  parent_id           = module.operation[each.key].resource_id
  value               = coalesce(each.value.xml_content, each.value.xml_link)
  enable_telemetry    = var.enable_telemetry
  format              = each.value.xml_link != null ? "xml-link" : "rawxml"
  ignore_body_changes = var.ignore_body_changes.apimanagement_service_apis_operations_policies
  name                = "policy"
  resource_types      = var.resource_types.apimanagement_service_apis_operations_policies
  retry               = var.retry
  timeouts            = var.timeouts

  depends_on = [
    module.backend,
    module.backend_pool,
    module.named_value,
    module.policy_fragment,
  ]
}
