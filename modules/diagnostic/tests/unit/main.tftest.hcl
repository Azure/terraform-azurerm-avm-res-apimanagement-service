mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  enable_telemetry = false
  logger_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-test/loggers/gateway-appinsights"
  name             = "applicationinsights"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-test"
}

run "reproduces_raw_application_insights_diagnostic" {
  command = apply

  variables {
    always_log = "allErrors"
    backend = {
      request  = { headers = [], body_bytes = 0 }
      response = { headers = [], body_bytes = 0 }
    }
    frontend = {
      request  = { headers = [], body_bytes = 0 }
      response = { headers = [], body_bytes = 0 }
    }
    http_correlation_protocol = "W3C"
    log_client_ip             = false
    metrics                   = true
    operation_name_format     = "Url"
    sampling = {
      percentage = 100
    }
    verbosity = "information"
  }

  assert {
    condition = jsonencode(azapi_resource.this.body) == jsonencode({
      properties = {
        loggerId                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-test/loggers/gateway-appinsights"
        alwaysLog               = "allErrors"
        httpCorrelationProtocol = "W3C"
        logClientIp             = false
        metrics                 = true
        operationNameFormat     = "Url"
        verbosity               = "information"
        sampling = {
          samplingType = "fixed"
          percentage   = 100
        }
        frontend = {
          request  = { headers = [], body = { bytes = 0 } }
          response = { headers = [], body = { bytes = 0 } }
        }
        backend = {
          request  = { headers = [], body = { bytes = 0 } }
          response = { headers = [], body = { bytes = 0 } }
        }
      }
    })
    error_message = "The diagnostic body must reproduce the raw applicationinsights diagnostic so a moved block has no diff."
  }

  assert {
    condition     = output.name == "applicationinsights"
    error_message = "The diagnostic output must preserve the configured name."
  }
}

run "omits_unset_optional_properties" {
  command = plan

  assert {
    condition = jsonencode(azapi_resource.this.body) == jsonencode({
      properties = {
        loggerId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-test/loggers/gateway-appinsights"
      }
    })
    error_message = "Null optional diagnostic properties must not be sent."
  }
}

run "maps_partial_pipeline_and_data_masking" {
  command = plan

  variables {
    frontend = {
      request = {
        data_masking = {
          headers = [{ mode = "Hide", value = "Authorization" }]
        }
        headers = ["x-request-id"]
      }
    }
  }

  assert {
    condition = jsonencode(azapi_resource.this.body.properties.frontend) == jsonencode({
      request = {
        dataMasking = {
          headers = [{ mode = "Hide", value = "Authorization" }]
        }
        headers = ["x-request-id"]
      }
    })
    error_message = "Only configured pipeline messages and settings may be sent."
  }

  assert {
    condition     = !contains(keys(azapi_resource.this.body.properties), "backend")
    error_message = "A null backend must not be sent."
  }
}

run "maps_large_language_model_logging" {
  command = plan

  variables {
    name      = "azuremonitor"
    logger_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-test/loggers/azuremonitor"
    large_language_model = {
      logs      = "enabled"
      responses = { max_size_in_bytes = 1024 }
    }
  }

  assert {
    condition = jsonencode(azapi_resource.this.body.properties.largeLanguageModel) == jsonencode({
      logs      = "enabled"
      responses = { maxSizeInBytes = 1024 }
    })
    error_message = "Only configured LLM log settings may be sent, so omitting requests and responses logs token usage only."
  }
}

run "rejects_logger_id_that_is_not_an_apim_logger" {
  command = plan

  variables {
    logger_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Insights/components/appi-test"
  }

  expect_failures = [
    var.logger_id,
  ]
}

run "rejects_out_of_range_sampling" {
  command = plan

  variables {
    sampling = {
      percentage = 101
    }
  }

  expect_failures = [
    var.sampling,
  ]
}

run "rejects_out_of_range_body_bytes" {
  command = plan

  variables {
    backend = {
      response = { body_bytes = 8193 }
    }
  }

  expect_failures = [
    var.backend,
  ]
}

run "rejects_invalid_data_masking_mode" {
  command = plan

  variables {
    frontend = {
      request = {
        data_masking = {
          query_params = [{ mode = "Redact", value = "key" }]
        }
      }
    }
  }

  expect_failures = [
    var.frontend,
  ]
}

run "rejects_invalid_verbosity" {
  command = plan

  variables {
    verbosity = "debug"
  }

  expect_failures = [
    var.verbosity,
  ]
}
