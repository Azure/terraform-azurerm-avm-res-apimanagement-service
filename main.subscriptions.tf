# API Management Subscriptions
# This file implements API subscriptions for access control


module "subscription" {
  source   = "./modules/subscription"
  for_each = var.subscriptions

  display_name        = each.value.display_name
  name                = each.key
  parent_id           = azapi_resource.this.id
  scope               = local.subscription_scopes[each.key]
  allow_tracing       = each.value.allow_tracing
  enable_telemetry    = var.enable_telemetry
  ignore_body_changes = var.ignore_body_changes.apimanagement_service_subscriptions
  owner_id            = each.value.user_id
  primary_key         = each.value.primary_key
  resource_types      = var.resource_types.apimanagement_service_subscriptions
  retry               = var.retry
  secondary_key       = each.value.secondary_key
  state               = each.value.state
  timeouts            = var.timeouts

  depends_on = [
    azapi_resource.this,
    module.product,
    module.api,
  ]
}
