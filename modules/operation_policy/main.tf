resource "azapi_resource" "this" {
  name                 = var.name
  parent_id            = var.parent_id
  type                 = var.resource_types.apimanagement_service_apis_operations_policies
  body                 = local.resource_body
  ignore_null_property = true
  ignore_body_changes  = length(var.ignore_body_changes.apimanagement_service_apis_operations_policies) > 0 ? var.ignore_body_changes.apimanagement_service_apis_operations_policies : null
  # Read back in the written format; the default GET returns `xml`, which re-escapes
  # rawxml content and reports a different `format`, so rawxml policies would drift.
  read_query_parameters = {
    format = [local.read_format]
  }
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
