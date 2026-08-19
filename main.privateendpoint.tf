resource "azurerm_private_endpoint" "this" {
  for_each = { for k, v in var.private_endpoints : k => v if var.private_endpoints_manage_dns_zone_group }

  location                      = each.value.location != null ? each.value.location : var.location
  name                          = each.value.name != null ? each.value.name : "pe-${var.name}"
  resource_group_name           = var.resource_group_name
  subnet_id                     = each.value.subnet_resource_id
  custom_network_interface_name = each.value.network_interface_name
  tags                          = each.value.tags == null ? var.tags : each.value.tags == {} ? {} : each.value.tags

  private_service_connection {
    is_manual_connection           = false
    name                           = each.value.private_service_connection_name != null ? each.value.private_service_connection_name : "psc-${var.name}"
    private_connection_resource_id = azurerm_api_management.this.id
    subresource_names              = ["Gateway"]
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations != null ? each.value.ip_configurations : {}

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      member_name        = ip_configuration.value.member_name != null ? ip_configuration.value.member_name : "default"
      subresource_name   = ip_configuration.value.subresource_name != null ? ip_configuration.value.subresource_name : "gateway"
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
  resource_group_name           = var.resource_group_name
  subnet_id                     = each.value.subnet_resource_id
  custom_network_interface_name = each.value.network_interface_name
  tags                          = each.value.tags == null ? var.tags : each.value.tags == {} ? {} : each.value.tags

  private_service_connection {
    is_manual_connection           = false
    name                           = each.value.private_service_connection_name != null ? each.value.private_service_connection_name : "psc-${var.name}"
    private_connection_resource_id = azurerm_api_management.this.id
    subresource_names              = ["Gateway"]
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations != null ? each.value.ip_configurations : {}

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      member_name        = ip_configuration.value.member_name != null ? ip_configuration.value.member_name : "default"
      subresource_name   = ip_configuration.value.subresource_name != null ? ip_configuration.value.subresource_name : "gateway"
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

# Public network access reconciliation.
#
# APIM v2 SKUs reject `publicNetworkAccess = Disabled` at service creation
# (ActivateServiceWithPrivateEndpointAccessNotAllowed), so the azurerm resource is created with
# public access enabled whenever orchestration is required (see locals.tf). After the private
# endpoint(s) exist, this resource disables public network access to reach the desired end-state
# in a single apply. `azurerm_api_management.this` ignores changes to `public_network_access_enabled`
# so the azapi-applied value is not reverted on subsequent plans.
#
# Known limitation: a later apply that changes another azurerm-managed attribute issues a full
# PUT and can re-enable public access until this update is re-applied. This is the platform
# behaviour to raise with the APIM product group.
resource "azapi_update_resource" "public_network_access" {
  count = local.public_network_access_orchestrated ? 1 : 0

  resource_id = azurerm_api_management.this.id
  type        = "Microsoft.ApiManagement/service@2024-05-01"
  body = {
    properties = {
      publicNetworkAccess = "Disabled"
    }
  }
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  depends_on = [
    azurerm_private_endpoint.this,
    azurerm_private_endpoint.this_unmanaged_dns_zone_groups,
    azurerm_private_endpoint_application_security_group_association.this,
  ]
}
