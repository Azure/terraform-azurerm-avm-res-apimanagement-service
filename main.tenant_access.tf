module "tenant_access" {
  source = "./modules/tenant_access"
  count  = var.tenant_access == null ? 0 : 1

  enabled             = var.tenant_access.enabled
  name                = "access"
  parent_id           = azapi_resource.this.id
  enable_telemetry    = var.enable_telemetry
  ignore_body_changes = var.ignore_body_changes.apimanagement_service_tenant
  resource_types      = var.resource_types.apimanagement_service_tenant
  retry               = var.retry
  timeouts            = var.timeouts
}
