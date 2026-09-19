mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      client_id       = "00000000-0000-0000-0000-000000000001"
      object_id       = "00000000-0000-0000-0000-000000000002"
      subscription_id = "00000000-0000-0000-0000-000000000000"
      tenant_id       = "00000000-0000-0000-0000-000000000003"
    }
  }

  mock_data "azapi_resource_action" {
    defaults = {
      output = {
        id = "tenant-access-id"
      }
      sensitive_output = {
        primaryKey   = "generated-primary-key"
        secondaryKey = "generated-secondary-key"
      }
    }
  }
}

mock_provider "modtm" {}
mock_provider "random" {}

variables {
  enable_telemetry = false
  location         = "eastus"
  name             = "apim-preview-test"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
  publisher_email  = "admin@example.com"
  publisher_name   = "Example"
}

run "day2_settings_default_to_unmanaged" {
  command = apply

  override_resource {
    target = azapi_resource.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-preview-test"
    }
  }

  assert {
    condition = (
      output.delegation == null &&
      output.delegation_id == null &&
      output.sign_in == null &&
      output.sign_in_id == null &&
      output.sign_up == null &&
      output.sign_up_id == null &&
      output.tenant_access_id == null
    )
    error_message = "Null day-2 settings must remain unmanaged."
  }
}

run "preview_contract" {
  command = apply

  variables {
    apis = {
      echo = {
        display_name = "Echo API"
        path         = "echo"
      }
    }
    backends = {
      primary = {
        protocol = "http"
        url      = "https://primary.example.com"
      }
      pool = {
        type = "Pool"
        pool = {
          services = [
            {
              backend_name = "primary"
              priority     = 1
              weight       = 100
            }
          ]
        }
      }
    }
    delegation = {
      subscriptions_enabled     = true
      url                       = "https://example.com/delegation"
      user_registration_enabled = true
      validation_key            = "validation-key"
    }
    named_values = {
      vault_secret = {
        display_name = "Vault.Secret"
        secret       = true
        value_from_key_vault = {
          secret_id = "https://example.vault.azure.net/secrets/example"
        }
      }
    }
    policy = {
      xml_content = "<policies><inbound><include-fragment fragment-id=\"correlation\" /></inbound><backend><base /></backend><outbound><base /></outbound><on-error><base /></on-error></policies>"
    }
    policy_fragments = {
      correlation = {
        value = "<fragment><set-header name=\"X-Correlation-ID\" exists-action=\"skip\"><value>@(context.RequestId.ToString())</value></set-header></fragment>"
      }
    }
    private_endpoints = {
      gateway = {
        resource_group_name = "network-rg"
        subnet_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/private-endpoints"
      }
    }
    products = {
      starter = {
        display_name          = "Starter"
        subscription_required = true
      }
    }
    sign_in = {
      enabled = false
    }
    sign_up = {
      enabled = true
      terms_of_service = {
        consent_required = true
        enabled          = true
        text             = "Example terms"
      }
    }
    subscriptions = {
      consumer = {
        display_name     = "Consumer"
        primary_key      = "primary-test-key"
        scope_identifier = "starter"
        scope_type       = "product"
        secondary_key    = "secondary-test-key"
      }
    }
    tenant_access = {
      enabled = false
    }
  }

  override_resource {
    target = azapi_resource.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-preview-test"
    }
  }

  override_resource {
    target = module.backend["primary"].azapi_resource.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-preview-test/backends/primary"
    }
  }

  override_resource {
    target = azapi_resource.private_endpoints["gateway"]
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/privateEndpoints/gateway"
    }
  }

  assert {
    condition     = length(output.backend_ids) == 2 && contains(keys(output.backend_pool_ids), "pool")
    error_message = "The module must return stable IDs for both single backends and backend pools."
  }

  assert {
    condition = (
      output.delegation_id == "${output.resource_id}/portalsettings/delegation" &&
      output.sign_in_id == "${output.resource_id}/portalsettings/signin" &&
      output.sign_up_id == "${output.resource_id}/portalsettings/signup" &&
      output.tenant_access_id == "${output.resource_id}/tenant/access"
    )
    error_message = "Day-2 singleton settings must expose stable child resource IDs."
  }

  assert {
    condition = (
      output.delegation.subscriptions_enabled &&
      output.sign_in.enabled == false &&
      output.sign_up.terms_of_service.consent_required &&
      nonsensitive(output.tenant_access.tenant_id) == "tenant-access-id" &&
      nonsensitive(output.tenant_access.primary_key) == "generated-primary-key"
    )
    error_message = "Day-2 singleton settings must preserve the public input and output contracts."
  }

  assert {
    condition     = contains(keys(output.api_ids), "echo") && contains(keys(output.product_ids), "starter")
    error_message = "The module must return stable API and product IDs."
  }

  assert {
    condition     = contains(keys(output.named_value_ids), "vault_secret") && contains(keys(output.policy_fragment_ids), "correlation")
    error_message = "The module must return stable named-value and policy-fragment IDs."
  }

  assert {
    condition     = contains(keys(output.subscription_ids), "consumer")
    error_message = "The module must return stable subscription IDs."
  }

  assert {
    condition     = azapi_resource.private_endpoints["gateway"].parent_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg"
    error_message = "Private endpoints must honor their configured resource group."
  }

  assert {
    condition     = !contains(keys(output.named_values["vault_secret"]), "value")
    error_message = "Named-value outputs must not expose secret values."
  }

  assert {
    condition     = output.subscription_keys["consumer"].primary_key == null && output.subscription_keys["consumer"].secondary_key == null
    error_message = "Subscription keys must not be exported from AzAPI write-only inputs."
  }
}

run "sensitive_collection_values_do_not_taint_instance_keys" {
  command = apply

  variables {
    apis = {
      imported = {
        display_name = "Imported API"
        path         = "imported"
        import = {
          content_format = "openapi+json"
          content_value  = sensitive("{\"openapi\":\"3.0.1\",\"info\":{\"title\":\"Imported\",\"version\":\"1.0.0\"},\"paths\":{}}")
        }
      }
    }
    backends = {
      secured = {
        credentials = {
          header = {
            X-Backend-Key = sensitive("backend-secret")
          }
        }
        protocol = "http"
        url      = "https://secured.example.com"
      }
    }
    named_values = {
      inline_secret = {
        display_name = "Inline.Secret"
        secret       = true
        value        = sensitive("named-value-secret")
      }
    }
    subscriptions = {
      all_apis = {
        display_name = "All APIs"
        primary_key  = sensitive("subscription-secret")
        scope_type   = "all_apis"
      }
    }
  }

  override_resource {
    target = azapi_resource.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-preview-test"
    }
  }

  assert {
    condition = (
      contains(keys(output.api_ids), "imported") &&
      contains(keys(output.backend_ids), "secured") &&
      contains(keys(output.named_value_ids), "inline_secret") &&
      contains(keys(output.subscription_ids), "all_apis")
    )
    error_message = "Sensitive nested values must not taint module instance keys."
  }
}

run "rejects_invalid_backend_pool" {
  command = plan

  variables {
    backends = {
      invalid = {
        protocol = "http"
        type     = "Pool"
        url      = "https://invalid.example.com"
      }
    }
  }

  expect_failures = [
    var.backends,
  ]
}

run "rejects_key_vault_reference_without_secret_flag" {
  command = plan

  variables {
    named_values = {
      invalid = {
        display_name = "Invalid"
        value_from_key_vault = {
          secret_id = "https://example.vault.azure.net/secrets/example"
        }
      }
    }
  }

  expect_failures = [
    var.named_values,
  ]
}

run "rejects_day2_settings_on_v2_sku" {
  command = plan

  variables {
    sign_in = {
      enabled = true
    }
    sku_name = "StandardV2_1"
  }

  expect_failures = [
    var.sign_in,
  ]
}
