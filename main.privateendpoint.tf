resource "azurerm_private_endpoint" "this" {
  for_each = { for k, v in var.private_endpoints : k => v if var.private_endpoints_manage_dns_zone_group }

  location                      = each.value.location != null ? each.value.location : var.location
  name                          = each.value.name != null ? each.value.name : "pe-${var.name}"
  resource_group_name           = coalesce(each.value.resource_group_name, var.resource_group_name)
  subnet_id                     = each.value.subnet_resource_id
  custom_network_interface_name = each.value.network_interface_name
  tags                          = each.value.tags == null ? var.tags : each.value.tags == {} ? {} : each.value.tags

  private_service_connection {
    is_manual_connection           = false
    name                           = each.value.private_service_connection_name != null ? each.value.private_service_connection_name : "psc-${var.name}"
    private_connection_resource_id = azurerm_api_management.this.id
    subresource_names              = [coalesce(each.value.subresource_name, "Gateway")]
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations != null ? each.value.ip_configurations : {}

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      member_name        = ip_configuration.value.member_name != null ? ip_configuration.value.member_name : "default"
      subresource_name   = coalesce(each.value.subresource_name, "gateway")
    }
  }

  dynamic "private_dns_zone_group" {
    for_each = length(coalesce(each.value.private_dns_zone_resource_ids, [])) > 0 ? ["this"] : []

    content {
      name                 = each.value.private_dns_zone_group_name != null ? each.value.private_dns_zone_group_name : "default"
      private_dns_zone_ids = each.value.private_dns_zone_resource_ids
    }
  }
}

resource "azurerm_private_endpoint" "this_unmanaged_dns_zone_groups" {
  for_each = { for k, v in var.private_endpoints : k => v if !var.private_endpoints_manage_dns_zone_group }

  location                      = each.value.location != null ? each.value.location : var.location
  name                          = each.value.name != null ? each.value.name : "pe-${var.name}"
  resource_group_name           = coalesce(each.value.resource_group_name, var.resource_group_name)
  subnet_id                     = each.value.subnet_resource_id
  custom_network_interface_name = each.value.network_interface_name
  tags                          = each.value.tags == null ? var.tags : each.value.tags == {} ? {} : each.value.tags

  private_service_connection {
    is_manual_connection           = false
    name                           = each.value.private_service_connection_name != null ? each.value.private_service_connection_name : "psc-${var.name}"
    private_connection_resource_id = azurerm_api_management.this.id
    subresource_names              = [coalesce(each.value.subresource_name, "Gateway")]
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations != null ? each.value.ip_configurations : {}

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      member_name        = ip_configuration.value.member_name != null ? ip_configuration.value.member_name : "default"
      subresource_name   = coalesce(each.value.subresource_name, "gateway")
    }
  }

  lifecycle {
    ignore_changes = [private_dns_zone_group]
  }
}

resource "azurerm_private_endpoint_application_security_group_association" "this" {
  for_each = local.private_endpoint_application_security_group_associations

  application_security_group_id = each.value.asg_resource_id
  private_endpoint_id           = var.private_endpoints_manage_dns_zone_group ? azurerm_private_endpoint.this[each.value.pe_key].id : azurerm_private_endpoint.this_unmanaged_dns_zone_groups[each.value.pe_key].id
}

module "avm_interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "0.6.0"

  enable_telemetry                 = var.enable_telemetry
  private_endpoints                = var.private_endpoints
  private_endpoints_scope          = azurerm_api_management.this.id
  role_assignment_definition_scope = azurerm_api_management.this.id
}

resource "azapi_resource" "private_endpoint_role_assignments" {
  for_each = module.avm_interfaces.role_assignments_private_endpoint_azapi

  name                   = each.value.name
  parent_id              = var.private_endpoints_manage_dns_zone_group ? azurerm_private_endpoint.this[each.value.pe_key].id : azurerm_private_endpoint.this_unmanaged_dns_zone_groups[each.value.pe_key].id
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

resource "azapi_resource" "private_endpoint_locks" {
  for_each = { for key, endpoint in var.private_endpoints : key => endpoint.lock if endpoint.lock != null }

  name      = coalesce(each.value.name, "lock-${each.value.kind}")
  parent_id = var.private_endpoints_manage_dns_zone_group ? azurerm_private_endpoint.this[each.key].id : azurerm_private_endpoint.this_unmanaged_dns_zone_groups[each.key].id
  type      = var.resource_types.authorization_locks
  body = {
    properties = {
      level = each.value.kind
      notes = each.value.notes != null ? each.value.notes : each.value.kind == "CanNotDelete" ? "Cannot delete resource or child resources." : "Cannot modify the resource or its children."
    }
  }
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

  depends_on = [
    azapi_resource.private_endpoint_role_assignments,
    azurerm_private_endpoint_application_security_group_association.this,
  ]
}
