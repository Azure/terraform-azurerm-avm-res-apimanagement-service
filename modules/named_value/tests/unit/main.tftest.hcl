mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  display_name     = "Example.Secret"
  enable_telemetry = false
  name             = "example-secret"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-test"
}

run "value_can_be_managed_outside_terraform" {
  command = apply

  assert {
    condition     = local.resource_body.properties.value == null && local.resource_body.properties.keyVault == null
    error_message = "A named value may omit both value sources so its value can be managed separately."
  }
}

run "key_vault_reference_stores_metadata_only" {
  command = apply

  variables {
    key_vault = {
      secret_identifier = "https://example.vault.azure.net/secrets/example"
    }
    secret = true
  }

  assert {
    condition     = local.resource_body.properties.keyVault.secretIdentifier == "https://example.vault.azure.net/secrets/example"
    error_message = "The named value must pass the Key Vault secret identifier to APIM."
  }

  assert {
    condition     = local.resource_body.properties.value == null && local.sensitive_body_version == null
    error_message = "Key Vault references must not resolve or persist secret material in Terraform."
  }
}

run "secret_value_uses_write_only_body" {
  command = apply

  variables {
    secret = true
    value  = "secret-value"
  }

  assert {
    condition     = local.resource_body.properties.value == null
    error_message = "Secret named values must not be stored in the ordinary AzAPI body."
  }

  assert {
    condition     = can(regex("^[0-9a-f]{64}$", nonsensitive(local.sensitive_body_version["properties.value"])))
    error_message = "Secret named values must use a string change token."
  }
}

run "rejects_key_vault_reference_without_secret_flag" {
  command = plan

  variables {
    key_vault = {
      secret_identifier = "https://example.vault.azure.net/secrets/example"
    }
    secret = false
  }

  expect_failures = [
    azapi_resource.this,
  ]
}
