mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  display_name     = "Consumer"
  enable_telemetry = false
  name             = "consumer"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-test"
  scope            = "/apis"
}

run "custom_keys_use_write_only_body" {
  command = apply

  variables {
    primary_key   = "primary-test-key"
    secondary_key = "secondary-test-key"
  }

  assert {
    condition     = !contains(keys(local.resource_body.properties), "primaryKey") && !contains(keys(local.resource_body.properties), "secondaryKey")
    error_message = "Custom subscription keys must not be persisted in the ordinary AzAPI body."
  }

  assert {
    condition = alltrue([
      for version in nonsensitive(values(local.sensitive_body_version)) :
      can(regex("^[0-9a-f]{64}$", version))
    ])
    error_message = "Custom subscription keys must use string change tokens."
  }
}
