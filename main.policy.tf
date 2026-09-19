# API Management Service-Level Policy
# This file implements the service-level (global) policy

module "policy" {
  source = "./modules/policy"
  count  = var.policy != null ? 1 : 0

  name                = "policy"
  parent_id           = azapi_resource.this.id
  value               = var.policy != null ? var.policy.xml_content : ""
  enable_telemetry    = var.enable_telemetry
  format              = "xml"
  ignore_body_changes = var.ignore_body_changes.apimanagement_service_policies
  resource_types      = var.resource_types.apimanagement_service_policies
  retry               = var.retry
  timeouts            = var.timeouts

  depends_on = [
    azapi_resource.this,
    module.backend,
  ]
}
