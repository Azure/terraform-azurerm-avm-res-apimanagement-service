resource "azapi_resource" "this" {
  name                = var.name
  parent_id           = var.parent_id
  type                = var.resource_types.apimanagement_service_named_values
  body                = local.resource_body
  ignore_body_changes = length(var.ignore_body_changes.apimanagement_service_named_values) > 0 ? var.ignore_body_changes.apimanagement_service_named_values : null
  response_export_values = [
    "properties.keyVault.lastStatus",
    "properties.provisioningState",
  ]
  retry = var.retry
  sensitive_body = local.use_sensitive_value ? {
    properties = {
      value = var.value
    }
  } : null
  sensitive_body_version = local.sensitive_body_version

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}
