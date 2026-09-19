locals {
  ignored_paths = toset(var.ignore_body_changes.apimanagement_service_portalsettings)
  delegation_properties = {
    for key, value in {
      subscriptions = {
        enabled = var.subscriptions_enabled
      }
      url = var.url
      userRegistration = {
        enabled = var.user_registration_enabled
      }
    } : key => value
    if !contains(local.ignored_paths, "properties") &&
    !contains(local.ignored_paths, "properties.${key}") &&
    !(key == "subscriptions" && contains(local.ignored_paths, "properties.subscriptions.enabled")) &&
    !(key == "userRegistration" && contains(local.ignored_paths, "properties.userRegistration.enabled"))
  }
  main_location = ""
  signin_properties = {
    for key, value in {
      enabled = var.enabled
    } : key => value
    if !contains(local.ignored_paths, "properties") && !contains(local.ignored_paths, "properties.${key}")
  }
  signup_terms_of_service = {
    for key, value in {
      consentRequired = try(var.terms_of_service.consent_required, null)
      enabled         = try(var.terms_of_service.enabled, null)
      text            = try(var.terms_of_service.text, null)
    } : key => value
    if !contains(local.ignored_paths, "properties") &&
    !contains(local.ignored_paths, "properties.termsOfService") &&
    !contains(local.ignored_paths, "properties.termsOfService.${key}")
  }
  signup_properties = {
    for key, value in {
      enabled        = var.enabled
      termsOfService = local.signup_terms_of_service
    } : key => value
    if !contains(local.ignored_paths, "properties") && !contains(local.ignored_paths, "properties.${key}")
  }
  resource_body = jsondecode(
    var.name == "delegation" ? jsonencode({ properties = local.delegation_properties }) :
    var.name == "signin" ? jsonencode({ properties = local.signin_properties }) :
    jsonencode({ properties = local.signup_properties })
  )
  resource_id               = "${var.parent_id}/portalsettings/${var.name}"
  validation_key_is_managed = var.name == "delegation" && var.validation_key != null && !contains(local.ignored_paths, "properties") && !contains(local.ignored_paths, "properties.validationKey")
  validation_key_version    = local.validation_key_is_managed ? sha256(jsonencode(var.validation_key)) : null
  validation_key_write_only_body = local.validation_key_is_managed ? {
    properties = {
      validationKey = var.validation_key
    }
  } : null
}
