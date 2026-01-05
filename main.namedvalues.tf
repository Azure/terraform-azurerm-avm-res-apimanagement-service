# Named Values for API Management Service
# These are configuration values and secrets that can be referenced in policies and API configurations

resource "azurerm_api_management_named_value" "this" {
  for_each = var.named_values

  api_management_name = azurerm_api_management.this.name
  display_name        = each.value.display_name
  name                = each.key
  resource_group_name = var.resource_group_name
  secret              = each.value.secret
  tags                = each.value.tags
  value               = each.value.value

  # Key Vault integration for secret values
  dynamic "value_from_key_vault" {
    for_each = each.value.value_from_key_vault != null ? [each.value.value_from_key_vault] : []

    content {
      secret_id          = value_from_key_vault.value.secret_id
      identity_client_id = value_from_key_vault.value.identity_client_id
    }
  }

  depends_on = [azurerm_api_management.this]
}
