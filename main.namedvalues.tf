# Named Values for API Management Service
# These are configuration values and secrets that can be referenced in policies and API configurations

module "named_value" {
  source   = "./modules/named_value"
  for_each = toset(nonsensitive(keys(var.named_values)))

  display_name        = nonsensitive(var.named_values[each.key].display_name)
  name                = each.key
  parent_id           = azapi_resource.this.id
  enable_telemetry    = var.enable_telemetry
  ignore_body_changes = var.ignore_body_changes.apimanagement_service_named_values
  key_vault = nonsensitive(var.named_values[each.key].value_from_key_vault) == null ? null : {
    secret_identifier  = nonsensitive(var.named_values[each.key].value_from_key_vault.secret_id)
    identity_client_id = nonsensitive(var.named_values[each.key].value_from_key_vault.identity_client_id)
  }
  named_value_tags = nonsensitive(var.named_values[each.key].tags)
  resource_types   = var.resource_types.apimanagement_service_named_values
  retry            = var.retry
  secret           = nonsensitive(var.named_values[each.key].secret)
  timeouts         = var.timeouts
  value            = var.named_values[each.key].value
}
