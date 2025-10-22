# API Management Products and Product Associations
# This file implements Products, Product-API associations, and Product-Group associations

# Products - API grouping and access control
resource "azurerm_api_management_product" "this" {
  for_each = var.products

  product_id            = each.key
  api_management_name   = azurerm_api_management.this.name
  resource_group_name   = azurerm_api_management.this.resource_group_name
  display_name          = each.value.display_name
  description           = each.value.description
  terms                 = each.value.terms
  subscription_required = each.value.subscription_required
  approval_required     = each.value.approval_required
  subscriptions_limit   = each.value.subscriptions_limit
  published             = each.value.state == "published"

  depends_on = [azurerm_api_management.this]
}

# Product-API Associations
locals {
  # Flatten product-API associations for dynamic creation
  product_api_associations = flatten([
    for product_key, product in var.products : [
      for api_name in product.api_names : {
        product_key = product_key
        api_name    = api_name
        key         = "${product_key}-${api_name}"
      }
    ]
  ])
}

resource "azurerm_api_management_product_api" "this" {
  for_each = {
    for assoc in local.product_api_associations : assoc.key => assoc
  }

  product_id          = azurerm_api_management_product.this[each.value.product_key].product_id
  api_name            = azurerm_api_management_api.this[each.value.api_name].name
  api_management_name = azurerm_api_management.this.name
  resource_group_name = azurerm_api_management.this.resource_group_name

  depends_on = [
    azurerm_api_management_product.this,
    azurerm_api_management_api.this
  ]
}

# Product-Group Associations
locals {
  # Flatten product-group associations for dynamic creation
  product_group_associations = flatten([
    for product_key, product in var.products : [
      for group_name in product.group_names : {
        product_key = product_key
        group_name  = group_name
        key         = "${product_key}-${group_name}"
      }
    ]
  ])
}

resource "azurerm_api_management_product_group" "this" {
  for_each = {
    for assoc in local.product_group_associations : assoc.key => assoc
  }

  product_id          = azurerm_api_management_product.this[each.value.product_key].product_id
  group_name          = each.value.group_name
  api_management_name = azurerm_api_management.this.name
  resource_group_name = azurerm_api_management.this.resource_group_name

  depends_on = [
    azurerm_api_management_product.this
  ]
}
