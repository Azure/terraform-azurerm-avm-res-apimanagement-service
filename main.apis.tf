# API Management APIs, operations, and policies (AzAPI submodules).
#
# BREAKING (composition): AzureRM root collections were extracted into for_each
# submodules. Addresses change from `azurerm_api_management_api.this["key"]` to
# `module.api["key"].azapi_resource.this` (and similarly for operations/policies).
#
# This AVM module cannot ship state moves that preserve arbitrary consumer keys
# across that resource->module boundary. State continuity belongs in the calling
# module, where keys are known. azapi >= 2.0 moves azurerm state natively, but it
# adopts the azurerm `id` verbatim as the ARM ID, and a `name` or `parent_id`
# mismatch then forces replacement. Replace `module.apim` with the local module
# label used to call this AVM.
#
# APIs: the azurerm ID is `.../apis/<name>;rev=<revision>`, which matches this
# module's API name `<key>;rev=<revision>`, so `moved` is safe:
#
#   moved {
#     from = module.apim.azurerm_api_management_api.this["petstore"]
#     to   = module.apim.module.api["petstore"].azapi_resource.this
#   }
#
# Operations and policies: do NOT use `moved`.
# - azurerm operation IDs omit `;rev=`, but this module parents operations on
#   `module.api[...].resource_id`, which includes it, so a move plans a replace.
# - azurerm API and operation policy IDs are the parent API or operation ID, not
#   the policy ID. A move adopts the parent as the policy; the planned replace
#   then deletes the parent API or operation.
# Remove the azurerm state without destroying, then import the azapi resources:
#
#   removed {
#     from = module.apim.azurerm_api_management_api_operation.this
#     lifecycle {
#       destroy = false
#     }
#   }
#   removed {
#     from = module.apim.azurerm_api_management_api_policy.this
#     lifecycle {
#       destroy = false
#     }
#   }
#   import {
#     to = module.apim.module.operation["petstore-get"].azapi_resource.this
#     id = "<service id>/apis/petstore;rev=1/operations/get"
#   }
#   import {
#     to = module.apim.module.api_policy["petstore"].azapi_resource.this
#     id = "<service id>/apis/petstore;rev=1/policies/policy"
#   }
#
# Provider-only address moves (same cardinality, same module boundary) may still
# use `moved` inside this AVM where the IDs match (see root `moved` for
# azurerm_api_management.this -> azapi_resource.this).

module "api" {
  source   = "./modules/api"
  for_each = var.apis

  name                     = "${each.key};rev=${coalesce(each.value.revision, "1")}"
  parent_id                = azapi_resource.this.id
  path                     = each.value.path
  api_revision             = each.value.revision
  api_revision_description = each.value.revision_description
  api_type                 = each.value.api_type
  api_version              = each.value.api_version
  api_version_set_id       = each.value.api_version_set_name != null ? module.api_version_set[each.value.api_version_set_name].resource_id : null
  authentication_settings = each.value.oauth2_authorization != null || each.value.openid_authentication != null ? {
    o_auth2 = each.value.oauth2_authorization == null ? null : {
      authorization_server_id = each.value.oauth2_authorization.authorization_server_name
      scope                   = each.value.oauth2_authorization.scope
    }
    openid = each.value.openid_authentication == null ? null : {
      openid_provider_id           = each.value.openid_authentication.openid_provider_name
      bearer_token_sending_methods = each.value.openid_authentication.bearer_token_sending_methods
    }
  } : null
  contact                          = each.value.contact
  description                      = each.value.description
  display_name                     = each.value.display_name
  enable_telemetry                 = var.enable_telemetry
  format                           = try(each.value.import.content_format, null)
  ignore_body_changes              = var.ignore_body_changes.apimanagement_service_apis
  license                          = each.value.license
  protocols                        = each.value.protocols
  resource_types                   = var.resource_types.apimanagement_service_apis
  retry                            = var.retry
  service_url                      = each.value.service_url
  source_api_id                    = each.value.source_api_id
  subscription_key_parameter_names = each.value.subscription_key_parameter_names
  subscription_required            = each.value.subscription_required
  terms_of_service_url             = each.value.terms_of_service_url
  timeouts                         = var.timeouts
  value                            = try(each.value.import.content_value, null)
  wsdl_selector = try(each.value.import.wsdl_selector, null) == null ? null : {
    wsdl_endpoint_name = each.value.import.wsdl_selector.endpoint_name
    wsdl_service_name  = each.value.import.wsdl_selector.service_name
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
