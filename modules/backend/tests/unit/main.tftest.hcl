mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  enable_telemetry = false
  name             = "backend"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-test"
}

run "single_backend_uses_write_only_credentials" {
  command = apply

  variables {
    credentials = {
      authorization = {
        parameter = "secret-token"
        scheme    = "Bearer"
      }
      certificate_ids = [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-test/certificates/client"
      ]
      header = {
        X-Test = "one,two"
      }
    }
    protocol = "http"
    proxy = {
      password = "proxy-secret"
      url      = "https://proxy.example.com"
      username = "proxy-user"
    }
    type = "Single"
    url  = "https://backend.example.com"
  }

  assert {
    condition     = !contains(keys(local.resource_body.properties), "credentials") && !contains(keys(local.resource_body.properties), "proxy")
    error_message = "Credentials and proxy settings must not be persisted in the ordinary AzAPI body."
  }

  assert {
    condition     = join(",", nonsensitive(local.credentials_body.header["X-Test"])) == "one,two"
    error_message = "Comma-separated backend header values must be converted to the ARM string-array shape."
  }

  assert {
    condition     = can(regex("^[0-9a-f]{64}$", nonsensitive(local.sensitive_body_version["properties.credentials"])))
    error_message = "Write-only backend credentials must use a string change token."
  }
}

run "plain_backend_has_no_write_only_body" {
  command = apply

  variables {
    protocol = "http"
    type     = "Single"
    url      = "https://backend.example.com"
  }

  assert {
    condition     = nonsensitive(local.sensitive_body == null && local.sensitive_body_version == null)
    error_message = "Backends without credentials or proxy settings must not create write-only body state."
  }
}

run "backend_pool_uses_resource_ids" {
  command = apply

  variables {
    pool = {
      services = [
        {
          id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-test/backends/primary"
          priority = 1
          weight   = 100
        }
      ]
    }
    type = "Pool"
  }

  assert {
    condition     = local.resource_body.properties.type == "Pool" && local.resource_body.properties.pool.services[0].weight == 100
    error_message = "Backend pools must emit the stable APIM pool body shape."
  }

  assert {
    condition     = nonsensitive(local.sensitive_body == null && local.sensitive_body_version == null)
    error_message = "Backend pools must not create empty write-only body state."
  }
}

run "rejects_single_only_fields_on_pool" {
  command = plan

  variables {
    credentials = {
      authorization = {
        parameter = "secret-token"
        scheme    = "Bearer"
      }
    }
    pool = {
      services = [
        {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-test/backends/primary"
        }
      ]
    }
    type = "Pool"
  }

  expect_failures = [
    azapi_resource.this,
  ]
}
