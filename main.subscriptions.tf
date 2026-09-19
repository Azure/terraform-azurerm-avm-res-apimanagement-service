# API Management Subscriptions
# This file implements API subscriptions for access control


module "subscription" {
  source   = "./modules/subscription"
  for_each = toset(nonsensitive(keys(var.subscriptions)))

  display_name        = nonsensitive(var.subscriptions[each.key].display_name)
  name                = each.key
  parent_id           = azapi_resource.this.id
  scope               = local.subscription_scopes[each.key]
  allow_tracing       = nonsensitive(var.subscriptions[each.key].allow_tracing)
  enable_telemetry    = var.enable_telemetry
  ignore_body_changes = var.ignore_body_changes.apimanagement_service_subscriptions
  owner_id            = nonsensitive(var.subscriptions[each.key].user_id)
  primary_key         = var.subscriptions[each.key].primary_key
  resource_types      = var.resource_types.apimanagement_service_subscriptions
  retry               = var.retry
  secondary_key       = var.subscriptions[each.key].secondary_key
  state               = nonsensitive(var.subscriptions[each.key].state)
  timeouts            = var.timeouts

  depends_on = [
    azapi_resource.this,
    module.product,
    module.api,
  ]
}
