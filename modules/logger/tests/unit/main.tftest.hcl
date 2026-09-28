mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  enable_telemetry = false
  name             = "gateway-appinsights"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-test"
}

run "application_insights_logger_keeps_credentials_out_of_body" {
  command = apply

  variables {
    connection_string  = "InstrumentationKey=00000000-0000-0000-0000-000000000000;IngestionEndpoint=https://example.in.applicationinsights.azure.com/"
    description        = "Gateway Application Insights."
    identity_client_id = "00000000-0000-0000-0000-000000000004"
    is_buffered        = true
    resource_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Insights/components/appi-test"
  }

  assert {
    condition = jsonencode(azapi_resource.this.body) == jsonencode({
      properties = {
        description = "Gateway Application Insights."
        isBuffered  = true
        loggerType  = "applicationInsights"
        resourceId  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Insights/components/appi-test"
      }
    })
    error_message = "The logger body must match a raw applicationInsights logger without credentials."
  }

  assert {
    condition = nonsensitive(jsonencode(local.sensitive_body)) == jsonencode({
      properties = {
        credentials = {
          connectionString = "InstrumentationKey=00000000-0000-0000-0000-000000000000;IngestionEndpoint=https://example.in.applicationinsights.azure.com/"
          identityClientId = "00000000-0000-0000-0000-000000000004"
        }
      }
    })
    error_message = "Logger credentials must be sent through the write-only sensitive body."
  }

  assert {
    condition     = azapi_resource.this.sensitive_body_version == null
    error_message = "The logger must not use sensitive_body_version, which would omit unchanged credentials from the PUT."
  }

  assert {
    condition     = output.name == "gateway-appinsights"
    error_message = "The logger output must preserve the configured name."
  }
}

run "omits_unset_optional_properties" {
  command = plan

  variables {
    connection_string = "InstrumentationKey=00000000-0000-0000-0000-000000000000"
  }

  assert {
    condition     = jsonencode(azapi_resource.this.body) == jsonencode({ properties = { loggerType = "applicationInsights" } })
    error_message = "Null optional logger properties must not be sent."
  }

  assert {
    condition     = keys(nonsensitive(local.sensitive_body).properties.credentials) == tolist(["connectionString"])
    error_message = "A null identity_client_id must not be sent."
  }
}

run "azure_monitor_logger_has_no_credentials" {
  command = plan

  variables {
    logger_type = "azureMonitor"
  }

  assert {
    condition     = local.sensitive_body == null
    error_message = "An azureMonitor logger must not send credentials."
  }
}

run "rejects_application_insights_without_connection_string" {
  command = plan

  expect_failures = [
    azapi_resource.this,
  ]
}

run "rejects_credentials_on_azure_monitor_logger" {
  command = plan

  variables {
    connection_string = "InstrumentationKey=00000000-0000-0000-0000-000000000000"
    logger_type       = "azureMonitor"
  }

  expect_failures = [
    azapi_resource.this,
  ]
}

run "rejects_event_hub_logger_type" {
  command = plan

  variables {
    logger_type = "azureEventHub"
  }

  expect_failures = [
    var.logger_type,
  ]
}

run "rejects_non_application_insights_resource_id" {
  command = plan

  variables {
    connection_string = "InstrumentationKey=00000000-0000-0000-0000-000000000000"
    resource_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.EventHub/namespaces/ehn-test"
  }

  expect_failures = [
    var.resource_id,
  ]
}
