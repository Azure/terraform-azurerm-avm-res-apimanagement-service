locals {
  # Flatten API operations into a single map for resource creation
  api_operations = merge([
    for api_key, api in var.apis : {
      for operation_key, operation in api.operations : "${api_key}-${operation_key}" => merge(operation, {
        api_key = api_key
      })
    }
  ]...)
  managed_identities = {
    system_assigned_user_assigned = (var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0) ? {
      this = {
        type                       = var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" : "SystemAssigned"
        user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
      }
    } : {}
    system_assigned = var.managed_identities.system_assigned ? {
      this = {
        type = "SystemAssigned"
      }
    } : {}
    user_assigned = length(var.managed_identities.user_assigned_resource_ids) > 0 ? {
      this = {
        type                       = "UserAssigned"
        user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
      }
    } : {}
  }
  # Flatten operation-level policies into a single map
  operation_policies = merge([
    for api_key, api in var.apis : {
      for operation_key, operation in api.operations : "${api_key}-${operation_key}" => {
        api_key     = api_key
        xml_content = operation.policy != null ? operation.policy.xml_content : null
        xml_link    = operation.policy != null ? operation.policy.xml_link : null
      } if operation.policy != null
    }
  ]...)
  # Private endpoint application security group associations.
  # We merge the nested maps from private endpoints and application security group associations into a single map.
  private_endpoint_application_security_group_associations = { for assoc in flatten([
    for pe_k, pe_v in var.private_endpoints : [
      for asg_k, asg_v in pe_v.application_security_group_associations : {
        asg_key         = asg_k
        pe_key          = pe_k
        asg_resource_id = asg_v
      }
    ]
  ]) : "${assoc.pe_key}-${assoc.asg_key}" => assoc }
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
  # APIM v2 SKUs (BasicV2/StandardV2/PremiumV2) reject `publicNetworkAccess = Disabled` at
  # creation time (error: ActivateServiceWithPrivateEndpointAccessNotAllowed). To support a
  # "secure-by-default" deployment - where the service is reachable only through a private
  # endpoint and public network access is disabled from the first apply - the module creates
  # the service with public access enabled and then disables it through an ordered post-creation
  # update (azapi_update_resource.public_network_access) that depends on the private endpoints.
  public_network_access_orchestrated = !var.public_network_access_enabled && length(var.private_endpoints) > 0
  # Value applied to the azurerm resource at creation. When orchestration is required we must
  # create with public access enabled; the azapi update then reconciles to the desired end-state.
  public_network_access_enabled_at_create = local.public_network_access_orchestrated ? true : var.public_network_access_enabled
}
