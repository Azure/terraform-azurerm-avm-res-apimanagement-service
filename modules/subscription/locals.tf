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
  main_location = "unknown"
}
