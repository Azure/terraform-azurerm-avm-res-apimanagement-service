resource "azapi_resource" "this" {
  name                   = var.name
  parent_id              = var.parent_id
  type                   = var.resource_types.apimanagement_service_backends
  body                   = local.resource_body
  ignore_body_changes    = length(var.ignore_body_changes.apimanagement_service_backends) > 0 ? var.ignore_body_changes.apimanagement_service_backends : null
  response_export_values = []
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

  lifecycle {
    precondition {
      condition     = var.type != "Single" || (var.protocol != null && var.url != null && var.pool == null)
      error_message = "Single backends require `protocol` and `url` and cannot set `pool`."
    }
    precondition {
      condition     = var.type != "Pool" || (var.protocol == null && var.url == null && var.pool != null && length(var.pool.services) > 0)
      error_message = "Pool backends require non-empty `pool.services` and cannot set `protocol` or `url`."
    }
    precondition {
      condition     = var.type != "Pool" || (var.credentials == null && var.proxy == null && var.resource_id == null && var.service_fabric_cluster == null && var.tls == null)
      error_message = "Pool backends cannot set `credentials`, `proxy`, `resource_id`, `service_fabric_cluster`, or `tls`."
    }
  }
}
