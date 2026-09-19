# API Management Backends
# This file implements backend resources for the API Management service.
# Backends define the HTTP endpoint that API operations forward requests to,
# including Azure AI Foundry endpoints, Function Apps, Logic Apps, and custom HTTP services.

module "backend" {
  source   = "./modules/backend"
  for_each = local.single_backend_keys

  name                   = each.key
  parent_id              = azapi_resource.this.id
  credentials            = var.backends[each.key].credentials
  description            = nonsensitive(var.backends[each.key].description)
  enable_telemetry       = var.enable_telemetry
  ignore_body_changes    = var.ignore_body_changes.apimanagement_service_backends
  protocol               = nonsensitive(var.backends[each.key].protocol)
  proxy                  = var.backends[each.key].proxy
  resource_id            = nonsensitive(var.backends[each.key].resource_id)
  resource_types         = var.resource_types.apimanagement_service_backends
  retry                  = var.retry
  service_fabric_cluster = nonsensitive(var.backends[each.key].service_fabric_cluster)
  timeouts               = var.timeouts
  title                  = nonsensitive(var.backends[each.key].title)
  tls                    = nonsensitive(var.backends[each.key].tls)
  type                   = nonsensitive(var.backends[each.key].type)
  url                    = nonsensitive(var.backends[each.key].url)
}

module "backend_pool" {
  source   = "./modules/backend"
  for_each = local.backend_pool_keys

  name                = each.key
  parent_id           = azapi_resource.this.id
  description         = nonsensitive(var.backends[each.key].description)
  enable_telemetry    = var.enable_telemetry
  ignore_body_changes = var.ignore_body_changes.apimanagement_service_backends
  pool = {
    services = [
      for service in nonsensitive(var.backends[each.key].pool.services) : {
        id       = service.backend_id != null ? service.backend_id : module.backend[service.backend_name].resource_id
        priority = service.priority
        weight   = service.weight
      }
    ]
  }
  resource_types = var.resource_types.apimanagement_service_backends
  retry          = var.retry
  timeouts       = var.timeouts
  title          = nonsensitive(var.backends[each.key].title)
  type           = nonsensitive(var.backends[each.key].type)

  depends_on = [module.backend]
}
