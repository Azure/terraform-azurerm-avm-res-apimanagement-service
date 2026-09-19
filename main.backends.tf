# API Management Backends
# This file implements backend resources for the API Management service.
# Backends define the HTTP endpoint that API operations forward requests to,
# including Azure AI Foundry endpoints, Function Apps, Logic Apps, and custom HTTP services.

module "backend" {
  source   = "./modules/backend"
  for_each = local.single_backends

  name                   = each.key
  parent_id              = azapi_resource.this.id
  protocol               = each.value.protocol
  url                    = each.value.url
  credentials            = each.value.credentials
  description            = each.value.description
  enable_telemetry       = var.enable_telemetry
  ignore_body_changes    = var.ignore_body_changes.apimanagement_service_backends
  proxy                  = each.value.proxy
  resource_id            = each.value.resource_id
  resource_types         = var.resource_types.apimanagement_service_backends
  retry                  = var.retry
  service_fabric_cluster = each.value.service_fabric_cluster
  timeouts               = var.timeouts
  title                  = each.value.title
  tls                    = each.value.tls
  type                   = each.value.type
}

module "backend_pool" {
  source   = "./modules/backend"
  for_each = local.backend_pools

  name                = each.key
  parent_id           = azapi_resource.this.id
  description         = each.value.description
  enable_telemetry    = var.enable_telemetry
  ignore_body_changes = var.ignore_body_changes.apimanagement_service_backends
  pool = {
    services = [
      for service in each.value.pool.services : {
        id       = service.backend_id != null ? service.backend_id : module.backend[service.backend_name].resource_id
        priority = service.priority
        weight   = service.weight
      }
    ]
  }
  resource_types = var.resource_types.apimanagement_service_backends
  retry          = var.retry
  timeouts       = var.timeouts
  title          = each.value.title
  type           = each.value.type

  depends_on = [module.backend]
}
