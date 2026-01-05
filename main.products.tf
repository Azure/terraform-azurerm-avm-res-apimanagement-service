# API Management Products and Product Associations
# This file implements Products, Product-API associations, and Product-Group associations

# Products - API grouping and access control
resource "azurerm_api_management_product" "this" {
  for_each = var.products

  api_management_name   = azurerm_api_management.this.name
  display_name          = each.value.display_name
  product_id            = each.key
  published             = each.value.state == "published"
  resource_group_name   = azurerm_api_management.this.resource_group_name
  approval_required     = each.value.approval_required
  description           = each.value.description
  subscription_required = each.value.subscription_required
  subscriptions_limit   = each.value.subscriptions_limit
  terms                 = each.value.terms

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

  api_management_name = azurerm_api_management.this.name
  api_name            = azurerm_api_management_api.this[each.value.api_name].name
  product_id          = azurerm_api_management_product.this[each.value.product_key].product_id
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

  api_management_name = azurerm_api_management.this.name
  group_name          = each.value.group_name
  product_id          = azurerm_api_management_product.this[each.value.product_key].product_id
  resource_group_name = azurerm_api_management.this.resource_group_name

  depends_on = [
    azurerm_api_management_product.this
  ]
}
