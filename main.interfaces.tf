module "avm_interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "0.7.0"

  diagnostic_settings_v2                    = local.diagnostic_settings_v2
  enable_telemetry                          = var.enable_telemetry
  lock                                      = var.lock
  private_endpoints                         = local.private_endpoints_for_interfaces
  private_endpoints_manage_dns_zone_group   = var.private_endpoints_manage_dns_zone_group
  private_endpoints_scope                   = length(var.private_endpoints) > 0 ? azapi_resource.this.id : null
  role_assignment_definition_lookup_enabled = var.role_assignment_definition_lookup_enabled
  role_assignment_definition_scope          = coalesce(var.role_assignment_definition_scope, var.parent_id)
  role_assignments                          = var.role_assignments
}

resource "azapi_resource" "lock" {
  count = module.avm_interfaces.lock_azapi != null ? 1 : 0

  name                   = coalesce(module.avm_interfaces.lock_azapi.name, "lock-${var.name}")
  parent_id              = azapi_resource.this.id
  type                   = var.resource_types.authorization_locks
  body                   = module.avm_interfaces.lock_azapi.body
  ignore_body_changes    = length(var.ignore_body_changes.authorization_locks) > 0 ? var.ignore_body_changes.authorization_locks : null
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azapi_resource" "role_assignments" {
  for_each = module.avm_interfaces.role_assignments_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.this.id
  type                   = var.resource_types.authorization_role_assignments
  body                   = each.value.body
  ignore_body_changes    = length(var.ignore_body_changes.authorization_role_assignments) > 0 ? var.ignore_body_changes.authorization_role_assignments : null
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azapi_resource" "diagnostic_settings" {
  for_each = module.avm_interfaces.diagnostic_settings_azapi_v2

  name                   = each.value.name
  parent_id              = azapi_resource.this.id
  type                   = var.resource_types.insights_diagnostic_settings
  body                   = each.value.body
  ignore_body_changes    = length(var.ignore_body_changes.insights_diagnostic_settings) > 0 ? var.ignore_body_changes.insights_diagnostic_settings : null
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}
