mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  enable_telemetry = false
  name             = "delegation"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-test"
}

run "delegation_uses_write_only_validation_key" {
  command = apply

  variables {
    subscriptions_enabled     = true
    url                       = "https://example.com/delegation"
    user_registration_enabled = true
    validation_key            = "validation-key"
  }

  assert {
    condition = (
      local.resource_body.properties.url == "https://example.com/delegation" &&
      local.resource_body.properties.subscriptions.enabled &&
      local.resource_body.properties.userRegistration.enabled
    )
    error_message = "Delegation settings must use the stable APIM portal setting body shape."
  }

  assert {
    condition     = local.resource_body.properties.validationKey == null && can(regex("^[0-9a-f]{64}$", nonsensitive(local.validation_key_version)))
    error_message = "The delegation validation key must use an AzAPI write-only body and a string change token."
  }
}

run "signin_maps_enabled" {
  command = apply

  variables {
    enabled = false
    name    = "signin"
  }

  assert {
    condition     = local.resource_body.properties.enabled == false
    error_message = "Sign-in must map enabled=false instead of treating it as unmanaged."
  }
}

run "signup_maps_terms" {
  command = apply

  variables {
    enabled = true
    name    = "signup"
    terms_of_service = {
      consent_required = true
      enabled          = true
      text             = "Example terms"
    }
  }

  assert {
    condition = (
      local.resource_body.properties.enabled &&
      local.resource_body.properties.termsOfService.consentRequired &&
      local.resource_body.properties.termsOfService.enabled &&
      local.resource_body.properties.termsOfService.text == "Example terms"
    )
    error_message = "Sign-up must map the complete terms-of-service contract."
  }
}

run "ignored_portal_fields_are_omitted" {
  command = apply

  variables {
    enabled = true
    ignore_body_changes = {
      apimanagement_service_portalsettings = ["properties.termsOfService.text"]
    }
    name = "signup"
    terms_of_service = {
      consent_required = true
      enabled          = true
      text             = "Externally managed terms"
    }
  }

  assert {
    condition     = !contains(keys(local.resource_body.properties.termsOfService), "text")
    error_message = "Ignored singleton properties must be omitted from the PATCH body."
  }
}
