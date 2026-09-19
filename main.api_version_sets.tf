# API Version Sets (required for versioned APIs)

module "api_version_set" {
  source   = "./modules/api_version_set"
  for_each = var.api_version_sets

  display_name        = each.value.display_name
  name                = each.key
  parent_id           = azapi_resource.this.id
  versioning_scheme   = each.value.versioning_scheme
  description         = each.value.description
  enable_telemetry    = var.enable_telemetry
  ignore_body_changes = var.ignore_body_changes.apimanagement_service_api_version_sets
  resource_types      = var.resource_types.apimanagement_service_api_version_sets
  retry               = var.retry
  timeouts            = var.timeouts
  version_header_name = each.value.version_header_name
  version_query_name  = each.value.version_query_name
}
