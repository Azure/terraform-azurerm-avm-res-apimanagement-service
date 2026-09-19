resource "azapi_update_resource" "this" {
  resource_id            = local.resource_id
  type                   = var.resource_types.apimanagement_service_tenant
  body                   = local.resource_body
  response_export_values = ["properties.enabled", "properties.id", "properties.principalId"]
  retry                  = var.retry
  update_headers = {
    "If-Match" = "*"
  }

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

data "azapi_resource_action" "secrets" {
  action                           = "listSecrets"
  method                           = "POST"
  resource_id                      = local.resource_id
  type                             = var.resource_types.apimanagement_service_tenant
  response_export_values           = ["id"]
  retry                            = var.retry
  sensitive_response_export_values = ["primaryKey", "secondaryKey"]

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      read = timeouts.value.read
    }
  }

  depends_on = [azapi_update_resource.this]
}
