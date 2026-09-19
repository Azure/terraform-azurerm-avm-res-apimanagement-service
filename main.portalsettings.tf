module "delegation" {
  source = "./modules/portal_setting"
  count  = var.delegation == null ? 0 : 1

  name                      = "delegation"
  parent_id                 = azapi_resource.this.id
  enable_telemetry          = var.enable_telemetry
  ignore_body_changes       = var.ignore_body_changes.apimanagement_service_portalsettings
  resource_types            = var.resource_types.apimanagement_service_portalsettings
  retry                     = var.retry
  subscriptions_enabled     = var.delegation.subscriptions_enabled
  timeouts                  = var.timeouts
  url                       = var.delegation.url
  user_registration_enabled = var.delegation.user_registration_enabled
  validation_key            = var.delegation.validation_key
}

module "sign_in" {
  source = "./modules/portal_setting"
  count  = var.sign_in == null ? 0 : 1

  name                = "signin"
  parent_id           = azapi_resource.this.id
  enable_telemetry    = var.enable_telemetry
  enabled             = var.sign_in.enabled
  ignore_body_changes = var.ignore_body_changes.apimanagement_service_portalsettings
  resource_types      = var.resource_types.apimanagement_service_portalsettings
  retry               = var.retry
  timeouts            = var.timeouts
}

module "sign_up" {
  source = "./modules/portal_setting"
  count  = var.sign_up == null ? 0 : 1

  name                = "signup"
  parent_id           = azapi_resource.this.id
  enable_telemetry    = var.enable_telemetry
  enabled             = var.sign_up.enabled
  ignore_body_changes = var.ignore_body_changes.apimanagement_service_portalsettings
  resource_types      = var.resource_types.apimanagement_service_portalsettings
  retry               = var.retry
  terms_of_service    = var.sign_up.terms_of_service
  timeouts            = var.timeouts
}
