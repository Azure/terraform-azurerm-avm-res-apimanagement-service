locals {
  resource_body = {
    properties = {
      allowTracing = var.allow_tracing
      displayName  = var.display_name
      ownerId      = var.owner_id
      scope        = var.scope
      state        = var.state
    }
  }

  sensitive_body = (var.primary_key != null || var.secondary_key != null) ? {
    properties = merge(
      var.primary_key != null ? { primaryKey = var.primary_key } : {},
      var.secondary_key != null ? { secondaryKey = var.secondary_key } : {}
    )
  } : null

  sensitive_body_version = local.sensitive_body == null ? null : {
    "properties.primaryKey"   = var.primary_key == null ? null : parseint(substr(sha256(var.primary_key), 0, 8), 16)
    "properties.secondaryKey" = var.secondary_key == null ? null : parseint(substr(sha256(var.secondary_key), 0, 8), 16)
  }
  main_location = "unknown"
}
