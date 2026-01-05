# API Management Subscriptions
# This file implements API subscriptions for access control

# Subscriptions - API access keys
resource "azurerm_api_management_subscription" "this" {
  for_each = var.subscriptions

  api_management_name = azurerm_api_management.this.name
  display_name        = each.value.display_name
  resource_group_name = azurerm_api_management.this.resource_group_name
  allow_tracing       = each.value.allow_tracing
  api_id              = each.value.scope_type == "api" ? azurerm_api_management_api.this[each.value.scope_identifier].id : null
  # Optional custom keys
  primary_key = each.value.primary_key
  # Scope to product, API, or all APIs
  # Note: product_id and api_id are mutually exclusive
  # For all_apis scope, both should be null
  product_id      = each.value.scope_type == "product" ? azurerm_api_management_product.this[each.value.scope_identifier].id : null
  secondary_key   = each.value.secondary_key
  state           = each.value.state
  subscription_id = each.key
  # Optional user assignment
  user_id = each.value.user_id

  depends_on = [
    azurerm_api_management.this,
    azurerm_api_management_product.this,
    azurerm_api_management_api.this
  ]
}
