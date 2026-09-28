# API Management loggers and service-level diagnostics (gateway request telemetry).
# These are distinct from Azure Monitor diagnostic settings in main.interfaces.tf.

module "logger" {
  source   = "./modules/logger"
  for_each = toset(nonsensitive(keys(var.loggers)))

  name                = each.key
  parent_id           = azapi_resource.this.id
  connection_string   = var.loggers[each.key].connection_string
  description         = nonsensitive(var.loggers[each.key].description)
  enable_telemetry    = var.enable_telemetry
  identity_client_id  = var.loggers[each.key].identity_client_id
  ignore_body_changes = var.ignore_body_changes.apimanagement_service_loggers
  is_buffered         = nonsensitive(var.loggers[each.key].is_buffered)
  logger_type         = nonsensitive(var.loggers[each.key].logger_type)
  resource_id         = nonsensitive(var.loggers[each.key].resource_id)
  resource_types      = var.resource_types.apimanagement_service_loggers
  retry               = var.retry
  timeouts            = var.timeouts
}

module "diagnostic" {
  source   = "./modules/diagnostic"
  for_each = var.diagnostics

  logger_id                 = each.value.logger_id != null ? each.value.logger_id : module.logger[each.value.logger_name].resource_id
  name                      = each.key
  parent_id                 = azapi_resource.this.id
  always_log                = each.value.always_log
  backend                   = each.value.backend
  enable_telemetry          = var.enable_telemetry
  frontend                  = each.value.frontend
  http_correlation_protocol = each.value.http_correlation_protocol
  ignore_body_changes       = var.ignore_body_changes.apimanagement_service_diagnostics
  log_client_ip             = each.value.log_client_ip
  metrics                   = each.value.metrics
  operation_name_format     = each.value.operation_name_format
  resource_types            = var.resource_types.apimanagement_service_diagnostics
  retry                     = var.retry
  sampling                  = each.value.sampling
  timeouts                  = var.timeouts
  verbosity                 = each.value.verbosity
}
