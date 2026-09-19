module "policy_fragment" {
  source   = "./modules/policy_fragment"
  for_each = var.policy_fragments

  name                = each.key
  parent_id           = azapi_resource.this.id
  value               = each.value.value
  description         = each.value.description
  enable_telemetry    = var.enable_telemetry
  format              = each.value.format
  ignore_body_changes = var.ignore_body_changes.apimanagement_service_policy_fragments
  resource_types      = var.resource_types.apimanagement_service_policy_fragments
  retry               = var.retry
  timeouts            = var.timeouts
}
