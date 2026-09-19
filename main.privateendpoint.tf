resource "azapi_resource" "private_endpoints" {
  for_each = module.avm_interfaces.private_endpoints_azapi

  location               = coalesce(try(var.private_endpoints[each.key].location, null), var.location)
  name                   = each.value.name
  parent_id              = var.parent_id
  type                   = coalesce(try(each.value.type, null), var.resource_types.network_private_endpoints)
  body                   = each.value.body
  ignore_body_changes    = length(var.ignore_body_changes.network_private_endpoints) > 0 ? var.ignore_body_changes.network_private_endpoints : null
  response_export_values = ["properties.networkInterfaces", "properties.customDnsConfigs"]
  retry                  = var.retry
  tags                   = try(each.value.tags, null)

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

resource "azapi_resource" "private_dns_zone_groups" {
  for_each = var.private_endpoints_manage_dns_zone_group ? module.avm_interfaces.private_dns_zone_groups_azapi : {}

  name                   = each.value.name
  parent_id              = azapi_resource.private_endpoints[each.key].id
  type                   = coalesce(try(each.value.type, null), var.resource_types.network_private_dns_zone_groups)
  body                   = each.value.body
  ignore_body_changes    = length(var.ignore_body_changes.network_private_dns_zone_groups) > 0 ? var.ignore_body_changes.network_private_dns_zone_groups : null
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

resource "azapi_resource" "private_endpoint_locks" {
  for_each = module.avm_interfaces.lock_private_endpoint_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.private_endpoints[each.value.pe_key].id
  type                   = each.value.type
  body                   = each.value.body
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

  depends_on = [
    azapi_resource.private_dns_zone_groups,
    azapi_resource.private_endpoint_role_assignments,
  ]
}

resource "azapi_resource" "private_endpoint_role_assignments" {
  for_each = module.avm_interfaces.role_assignments_private_endpoint_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.private_endpoints[each.value.pe_key].id
  type                   = each.value.type
  body                   = each.value.body
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
