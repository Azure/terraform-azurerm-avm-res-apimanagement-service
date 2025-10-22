# API Management Subscriptions
# This file implements API subscriptions for access control

# Subscriptions - API access keys
resource "azurerm_api_management_subscription" "this" {
  for_each = var.subscriptions

  subscription_id     = each.key
  api_management_name = azurerm_api_management.this.name
  resource_group_name = azurerm_api_management.this.resource_group_name
  display_name        = each.value.display_name
  state               = each.value.state
  allow_tracing       = each.value.allow_tracing

  # Scope to product, API, or all APIs
  # Note: product_id and api_id are mutually exclusive
  product_id = each.value.scope_type == "product" ? azurerm_api_management_product.this[each.value.scope_identifier].id : null
  api_id     = each.value.scope_type == "api" ? azurerm_api_management_api.this[each.value.scope_identifier].id : (each.value.scope_type == "all_apis" ? "${azurerm_api_management.this.id}/apis" : null)

  # Optional user assignment
  user_id = each.value.user_id

  # Optional custom keys
  primary_key   = each.value.primary_key
  secondary_key = each.value.secondary_key

  depends_on = [
    azurerm_api_management.this,
    azurerm_api_management_product.this,
    azurerm_api_management_api.this
  ]
}
