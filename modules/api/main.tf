resource "azapi_resource" "this" {
  name                = var.name
  parent_id           = var.parent_id
  type                = var.resource_types.apimanagement_service_apis
  body                = local.resource_body
  ignore_body_changes = length(var.ignore_body_changes.apimanagement_service_apis) > 0 ? var.ignore_body_changes.apimanagement_service_apis : null
  response_export_values = [
    "properties.apiRevision",
    "properties.apiType",
    "properties.apiVersion",
    "properties.apiVersionSetId",
    "properties.displayName",
    "properties.isCurrent",
    "properties.isOnline",
    "properties.path",
    "properties.protocols",
    "properties.provisioningState",
    "properties.serviceUrl",
    "properties.subscriptionRequired",
  ]
  retry                  = var.retry
  sensitive_body         = local.sensitive_body
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
