# Named Values for API Management Service
# These are configuration values and secrets that can be referenced in policies and API configurations

module "named_value" {
  source   = "./modules/named_value"
  for_each = var.named_values

  display_name        = each.value.display_name
  name                = each.key
  parent_id           = azapi_resource.this.id
  enable_telemetry    = var.enable_telemetry
  ignore_body_changes = var.ignore_body_changes.apimanagement_service_named_values
  key_vault = each.value.value_from_key_vault == null ? null : {
    secret_identifier  = each.value.value_from_key_vault.secret_id
    identity_client_id = each.value.value_from_key_vault.identity_client_id
  }
  resource_types = var.resource_types.apimanagement_service_named_values
  retry          = var.retry
  secret         = each.value.secret
  tags           = each.value.tags
  timeouts       = var.timeouts
  value          = each.value.value
}
