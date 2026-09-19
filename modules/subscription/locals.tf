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
    for path, version in {
      "properties.primaryKey"   = var.primary_key == null ? null : sha256(var.primary_key)
      "properties.secondaryKey" = var.secondary_key == null ? null : sha256(var.secondary_key)
    } : path => version if version != null
  }
  main_location = "unknown"
}
