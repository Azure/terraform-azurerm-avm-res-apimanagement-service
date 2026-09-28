resource "azapi_resource" "this" {
  name                   = var.name
  parent_id              = var.parent_id
  type                   = var.resource_types.apimanagement_service_loggers
  body                   = local.resource_body
  ignore_null_property   = true
  ignore_body_changes    = length(var.ignore_body_changes.apimanagement_service_loggers) > 0 ? var.ignore_body_changes.apimanagement_service_loggers : null
  response_export_values = []
  retry                  = var.retry
  # No sensitive_body_version: with a version map AzAPI sends only the changed paths, and the
  # logger PUT replaces the whole resource, so credentials must accompany every write. AzAPI
  # detects credential changes from a hash in private state instead.
  sensitive_body = local.sensitive_body

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    precondition {
      condition     = var.logger_type != "applicationInsights" || nonsensitive(var.connection_string != null)
      error_message = "`connection_string` is required when `logger_type` is `applicationInsights`."
    }
    precondition {
      condition     = var.logger_type != "azureMonitor" || (nonsensitive(var.connection_string == null) && var.identity_client_id == null && var.resource_id == null)
      error_message = "`connection_string`, `identity_client_id` and `resource_id` must be null when `logger_type` is `azureMonitor`."
    }
  }
}
