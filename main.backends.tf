# API Management Backends
# This file implements backend resources for the API Management service.
# Backends define the HTTP endpoint that API operations forward requests to,
# including Azure AI Foundry endpoints, Function Apps, Logic Apps, and custom HTTP services.

module "backend" {
  source   = "./modules/backend"
  for_each = var.backends

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
}
