resource "azapi_resource" "this" {
  location            = var.location
  name                = var.name
  parent_id           = var.parent_id
  type                = var.resource_types.apimanagement_service
  body                = local.resource_body
  ignore_body_changes = length(var.ignore_body_changes.apimanagement_service) > 0 ? var.ignore_body_changes.apimanagement_service : null
  response_export_values = [
    "identity.principalId",
    "identity.tenantId",
    "properties.createdAtUtc",
    "properties.developerPortalUrl",
    "properties.gatewayRegionalUrl",
    "properties.gatewayUrl",
    "properties.managementApiUrl",
    "properties.outboundPublicIPAddresses",
    "properties.portalUrl",
    "properties.privateIPAddresses",
    "properties.provisioningState",
    "properties.publicIPAddresses",
    "properties.scmUrl",
    "properties.targetProvisioningState",
  ]
  retry                  = var.retry
  sensitive_body         = local.sensitive_body
  sensitive_body_version = local.sensitive_body_version
  tags                   = var.tags

  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }

    lifecycle {
      precondition {
        condition     = var.delegation == null
        error_message = "`delegation` is not implemented by the AzAPI migration preview. Manage `Microsoft.ApiManagement/service/delegationSettings` directly until the child submodule is migrated."
      }
      precondition {
        condition     = var.sign_in == null
        error_message = "`sign_in` is not implemented by the AzAPI migration preview. Manage `Microsoft.ApiManagement/service/portalsettings` directly until the child submodule is migrated."
      }
      precondition {
        condition     = var.sign_up == null
        error_message = "`sign_up` is not implemented by the AzAPI migration preview. Manage `Microsoft.ApiManagement/service/portalsettings` directly until the child submodule is migrated."
      }
      precondition {
        condition     = var.tenant_access == null
        error_message = "`tenant_access` is not implemented by the AzAPI migration preview. Manage `Microsoft.ApiManagement/service/tenant/access` directly until the child submodule is migrated."
      }
    }
  }
}

moved {
  from = azurerm_api_management.this
  to   = azapi_resource.this
}
