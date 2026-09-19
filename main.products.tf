# API Management Products and Product Associations


module "product" {
  source   = "./modules/product"
  for_each = var.products

  display_name          = each.value.display_name
  name                  = each.key
  parent_id             = azapi_resource.this.id
  approval_required     = each.value.approval_required
  description           = each.value.description
  enable_telemetry      = var.enable_telemetry
  ignore_body_changes   = var.ignore_body_changes.apimanagement_service_products
  resource_types        = var.resource_types.apimanagement_service_products
  retry                 = var.retry
  state                 = each.value.state
  subscription_required = each.value.subscription_required
  subscriptions_limit   = each.value.subscriptions_limit
  terms                 = each.value.terms
  timeouts              = var.timeouts
}

module "product_api" {
  source   = "./modules/product_api"
  for_each = local.product_api_associations

  name                = module.api[each.value.api_name].name
  parent_id           = module.product[each.value.product_key].resource_id
  enable_telemetry    = var.enable_telemetry
  ignore_body_changes = var.ignore_body_changes.apimanagement_service_products_apis
  resource_types      = var.resource_types.apimanagement_service_products_apis
  retry               = var.retry
  timeouts            = var.timeouts

  depends_on = [module.api]
}

module "product_group" {
  source   = "./modules/product_group"
  for_each = local.product_group_associations

  name                = each.value.group_name
  parent_id           = module.product[each.value.product_key].resource_id
  enable_telemetry    = var.enable_telemetry
  ignore_body_changes = var.ignore_body_changes.apimanagement_service_products_groups
  resource_types      = var.resource_types.apimanagement_service_products_groups
  retry               = var.retry
  timeouts            = var.timeouts
}
