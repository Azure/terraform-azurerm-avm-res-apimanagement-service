mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      client_id       = "00000000-0000-0000-0000-000000000001"
      object_id       = "00000000-0000-0000-0000-000000000002"
      subscription_id = "00000000-0000-0000-0000-000000000000"
      tenant_id       = "00000000-0000-0000-0000-000000000003"
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
      validation_key            = sensitive("validation-key")
    }
    named_values = {
      inline_secret = {
        display_name = "Inline.Secret"
        secret       = true
        value        = sensitive("named-value-secret")
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
      all_apis = {
        display_name = "All APIs"
        primary_key  = sensitive("subscription-secret")
        scope_type   = "all_apis"
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
    target = module.tenant_access[0].azapi_update_resource.this
    values = {
      output = {
        properties = {
          id = "tenant-access-id"
        }
      }
    }
  }

  assert {
    condition     = length(output.backend_ids) == 2 && contains(keys(output.backend_pool_ids), "pool")
    error_message = "The module must return stable IDs for single backends and backend pools."
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
      nonsensitive(output.tenant_access.primary_key) == null &&
      nonsensitive(output.tenant_access.secondary_key) == null
    )
    error_message = "Day-2 singleton outputs must preserve non-secret settings without reading access keys."
  }

  assert {
    condition     = contains(keys(output.named_value_ids), "inline_secret") && contains(keys(output.policy_fragment_ids), "correlation")
    error_message = "The module must return stable named-value and policy-fragment IDs."
  }

  assert {
    condition     = contains(keys(nonsensitive(output.subscription_ids)), "all_apis")
    error_message = "The module must return stable subscription IDs."
  }

  assert {
    condition     = !contains(keys(output.named_values["inline_secret"]), "value")
    error_message = "Named-value outputs must not expose secret values."
  }

  assert {
    condition = (
      nonsensitive(output.subscription_keys["all_apis"].primary_key) == null &&
      nonsensitive(output.subscription_keys["all_apis"].secondary_key) == null
    )
    error_message = "Subscription keys must remain write-only and must not be read into Terraform state."
  }
}

run "sensitive_collection_values_do_not_taint_instance_keys" {
  command = apply

  variables {
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
      contains(keys(output.backend_ids), "secured") &&
      contains(keys(output.named_value_ids), "inline_secret") &&
      contains(keys(nonsensitive(output.subscription_ids)), "all_apis")
    )
    error_message = "Sensitive nested values must not taint module instance keys."
  }
}

run "allows_portal_settings_on_v2_sku" {
  command = plan

  variables {
    sign_in = {
      enabled = true
    }
    sku_name = "StandardV2_1"
  }
}

run "omits_client_certificate_property_for_non_consumption_skus" {
  command = plan

  variables {
    sku_name = "Developer_1"
  }

  assert {
    condition     = !contains(keys(azapi_resource.this.body.properties), "enableClientCertificate")
    error_message = "Non-Consumption APIM SKUs must omit enableClientCertificate from the ARM request body."
  }
}

run "sends_client_certificate_property_for_consumption_skus" {
  command = plan

  variables {
    client_certificate_enabled = true
    sku_name                   = "Consumption_0"
  }

  assert {
    condition     = azapi_resource.this.body.properties.enableClientCertificate
    error_message = "Consumption APIM SKUs must send enableClientCertificate when configured."
  }
}

run "replaces_service_for_immutable_properties" {
  command = plan

  assert {
    condition = azapi_resource.this.replace_triggers_refs == tolist([
      "properties.virtualNetworkConfiguration",
      "properties.virtualNetworkType",
      "sku.name",
    ])
    error_message = "APIM service SKU type and virtual network changes must replace the service."
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

run "omits_api_version_constraint_by_default_on_v2_sku" {
  command = plan

  variables {
    sku_name = "BasicV2_1"
  }

  assert {
    condition     = azapi_resource.this.body.properties.apiVersionConstraint == null
    error_message = "A null min_api_version must not send apiVersionConstraint."
  }

  assert {
    condition = jsonencode(azapi_resource.this.body) == jsonencode({
      properties = {
        additionalLocations         = null
        apiVersionConstraint        = null
        certificates                = null
        customProperties            = null
        hostnameConfigurations      = null
        notificationSenderEmail     = null
        publicIpAddressId           = null
        publicNetworkAccess         = "Enabled"
        publisherEmail              = "admin@example.com"
        publisherName               = "Example"
        virtualNetworkConfiguration = null
        virtualNetworkType          = "None"
      }
      sku = {
        capacity = 1
        name     = "BasicV2"
      }
      zones = null
    })
    error_message = "The default v2 service body must remain unchanged."
  }
}

run "sends_min_api_version_on_classic_skus" {
  command = plan

  variables {
    min_api_version = "2021-08-01"
    sku_name        = "Developer_1"
  }

  assert {
    condition     = azapi_resource.this.body.properties.apiVersionConstraint.minApiVersion == "2021-08-01"
    error_message = "Classic APIM SKUs must send the configured minimum API version."
  }
}

run "rejects_min_api_version_on_basic_v2" {
  command = plan

  variables {
    min_api_version = "2021-08-01"
    sku_name        = "BasicV2_1"
  }

  expect_failures = [
    var.min_api_version,
  ]
}

run "rejects_min_api_version_on_standard_v2" {
  command = plan

  variables {
    min_api_version = "2021-08-01"
    sku_name        = "StandardV2_1"
  }

  expect_failures = [
    var.min_api_version,
  ]
}

run "rejects_min_api_version_on_premium_v2" {
  command = plan

  variables {
    min_api_version = "2021-08-01"
    sku_name        = "PremiumV2_1"
  }

  expect_failures = [
    var.min_api_version,
  ]
}

run "omits_gateway_disabled_by_default" {
  command = plan

  variables {
    additional_location = [
      {
        location = "westus"
      },
      {
        gateway_disabled = true
        location         = "centralus"
      },
    ]
    sku_name = "Premium_1"
  }

  assert {
    condition     = !contains(keys(azapi_resource.this.body.properties), "disableGateway")
    error_message = "A null gateway_disabled must not send disableGateway."
  }

  assert {
    condition = (
      !contains(keys(azapi_resource.this.body.properties.additionalLocations[0]), "disableGateway") &&
      azapi_resource.this.body.properties.additionalLocations[1].disableGateway == true
    )
    error_message = "Additional locations must send disableGateway only when gateway_disabled is set."
  }
}

run "sends_gateway_disabled_on_classic_multi_region" {
  command = plan

  variables {
    additional_location = [
      {
        location = "westus"
      },
    ]
    gateway_disabled = true
    sku_name         = "Premium_1"
  }

  assert {
    condition     = azapi_resource.this.body.properties.disableGateway == true
    error_message = "Classic multi-region services must send the configured disableGateway value."
  }
}

run "rejects_gateway_disabled_without_additional_location" {
  command = plan

  variables {
    gateway_disabled = true
    sku_name         = "Premium_1"
  }

  expect_failures = [
    var.gateway_disabled,
  ]
}

run "rejects_gateway_disabled_on_basic_v2" {
  command = plan

  variables {
    gateway_disabled = false
    sku_name         = "BasicV2_1"
  }

  expect_failures = [
    var.gateway_disabled,
  ]
}

run "rejects_gateway_disabled_on_standard_v2" {
  command = plan

  variables {
    gateway_disabled = false
    sku_name         = "StandardV2_1"
  }

  expect_failures = [
    var.gateway_disabled,
  ]
}

run "rejects_gateway_disabled_on_premium_v2" {
  command = plan

  variables {
    gateway_disabled = false
    sku_name         = "PremiumV2_1"
  }

  expect_failures = [
    var.gateway_disabled,
  ]
}

run "omits_developer_portal_status_by_default" {
  command = plan

  variables {
    sku_name = "BasicV2_1"
  }

  assert {
    condition     = !contains(keys(azapi_resource.this.body.properties), "developerPortalStatus")
    error_message = "A null developer_portal_status must not send developerPortalStatus."
  }
}

run "sends_developer_portal_status_on_v2_sku" {
  command = plan

  variables {
    developer_portal_status = "Disabled"
    sku_name                = "BasicV2_1"
  }

  assert {
    condition     = azapi_resource.this.body.properties.developerPortalStatus == "Disabled"
    error_message = "The configured developer portal status must be sent."
  }
}

run "rejects_invalid_developer_portal_status" {
  command = plan

  variables {
    developer_portal_status = "Off"
    sku_name                = "BasicV2_1"
  }

  expect_failures = [
    var.developer_portal_status,
  ]
}

run "rejects_developer_portal_status_on_consumption" {
  command = plan

  variables {
    developer_portal_status = "Disabled"
    sku_name                = "Consumption_0"
  }

  expect_failures = [
    var.developer_portal_status,
  ]
}

run "creates_no_loggers_or_diagnostics_by_default" {
  command = plan

  assert {
    condition     = length(output.logger_ids) == 0 && length(output.diagnostic_ids) == 0
    error_message = "Loggers and service diagnostics must not be created unless configured."
  }
}

run "wires_service_diagnostic_to_managed_logger" {
  command = apply

  variables {
    loggers = {
      gateway-appinsights = {
        connection_string  = "InstrumentationKey=00000000-0000-0000-0000-000000000000;IngestionEndpoint=https://example.invalid/"
        description        = "Gateway Application Insights"
        identity_client_id = "00000000-0000-0000-0000-000000000004"
        is_buffered        = true
        resource_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Insights/components/appi-test"
      }
    }
    diagnostics = {
      applicationinsights = {
        logger_name               = "gateway-appinsights"
        always_log                = "allErrors"
        http_correlation_protocol = "W3C"
        log_client_ip             = false
        metrics                   = true
        operation_name_format     = "Url"
        sampling                  = { percentage = 100 }
        verbosity                 = "information"
      }
    }
  }

  override_resource {
    target = azapi_resource.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-preview-test"
    }
  }

  # The diagnostic submodule validates logger_id as an APIM logger ID, so this
  # apply only succeeds when logger_name resolves to the managed logger.
  override_resource {
    target = module.logger["gateway-appinsights"].azapi_resource.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-preview-test/loggers/gateway-appinsights"
    }
  }

  override_resource {
    target = module.diagnostic["applicationinsights"].azapi_resource.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-preview-test/diagnostics/applicationinsights"
    }
  }

  assert {
    condition     = output.logger_ids["gateway-appinsights"] == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-preview-test/loggers/gateway-appinsights"
    error_message = "Logger IDs must be keyed by logger name without a sensitive mark from the connection string."
  }

  assert {
    condition     = output.diagnostic_ids["applicationinsights"] == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-preview-test/diagnostics/applicationinsights"
    error_message = "Diagnostic IDs must be keyed by diagnostic name."
  }
}

run "accepts_diagnostic_with_existing_logger_id" {
  command = plan

  variables {
    diagnostics = {
      azuremonitor = {
        logger_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-preview-test/loggers/azuremonitor"
      }
    }
  }

  assert {
    condition     = length(output.logger_ids) == 0 && contains(keys(output.diagnostic_ids), "azuremonitor")
    error_message = "A diagnostic must be able to target an existing logger without creating one."
  }
}

run "rejects_diagnostic_with_unknown_logger_name" {
  command = plan

  variables {
    diagnostics = {
      applicationinsights = {
        logger_name = "missing"
      }
    }
  }

  expect_failures = [
    var.diagnostics,
  ]
}

run "rejects_diagnostic_with_both_logger_references" {
  command = plan

  variables {
    loggers = {
      gateway-appinsights = {
        connection_string = "InstrumentationKey=00000000-0000-0000-0000-000000000000"
      }
    }
    diagnostics = {
      applicationinsights = {
        logger_name = "gateway-appinsights"
        logger_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-preview-test/loggers/gateway-appinsights"
      }
    }
  }

  expect_failures = [
    var.diagnostics,
  ]
}
