resource "azapi_update_resource" "this" {
  resource_id            = local.resource_id
  type                   = var.resource_types.apimanagement_service_portalsettings
  body                   = local.resource_body
  response_export_values = ["properties.enabled", "properties.subscriptions", "properties.termsOfService", "properties.url", "properties.userRegistration"]
  retry                  = var.retry
  sensitive_body         = local.validation_key_write_only_body
  sensitive_body_version = local.validation_key_is_managed ? {
    "properties.validationKey" = local.validation_key_version
  } : null
  update_headers = {
    "If-Match" = "*"
  }

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
      condition = (
        var.name == "delegation" ?
        var.enabled == null && var.terms_of_service == null && var.subscriptions_enabled != null && var.user_registration_enabled != null :
        var.name == "signin" ?
        var.enabled != null && var.terms_of_service == null && var.subscriptions_enabled == null && var.user_registration_enabled == null && var.url == null && var.validation_key == null :
        var.enabled != null && var.terms_of_service != null && var.subscriptions_enabled == null && var.user_registration_enabled == null && var.url == null && var.validation_key == null
      )
      error_message = "Portal setting inputs must match the selected name: delegation accepts delegation fields, signin accepts enabled, and signup accepts enabled plus terms_of_service."
    }
  }
}
