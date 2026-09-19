resource "azapi_resource" "this" {
  name                   = var.name
  parent_id              = var.parent_id
  type                   = var.resource_types.apimanagement_service_backends
  body                   = local.resource_body
  ignore_body_changes    = length(var.ignore_body_changes.apimanagement_service_backends) > 0 ? var.ignore_body_changes.apimanagement_service_backends : null
  response_export_values = []
  retry                  = var.retry

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
