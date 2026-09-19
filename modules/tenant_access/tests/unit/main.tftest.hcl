mock_provider "azapi" {
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
  enabled          = false
  name             = "access"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-test"
}

run "tenant_access_maps_disabled_and_exports_keys_safely" {
  command = apply

  assert {
    condition     = local.resource_body.properties.enabled == false
    error_message = "Tenant access must map enabled=false instead of treating it as unmanaged."
  }

  assert {
    condition     = local.resource_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-test/tenant/access"
    error_message = "Tenant access must use the stable singleton child resource ID."
  }

  assert {
    condition     = output.tenant_id == "tenant-access-id" && nonsensitive(output.primary_key) == "generated-primary-key" && nonsensitive(output.secondary_key) == "generated-secondary-key"
    error_message = "Tenant access keys must be exported only through the AzAPI sensitive response channel."
  }
}

run "ignored_tenant_access_is_omitted" {
  command = apply

  variables {
    ignore_body_changes = {
      apimanagement_service_tenant = ["properties.enabled"]
    }
  }

  assert {
    condition     = length(keys(local.resource_body.properties)) == 0
    error_message = "Ignored tenant access properties must be omitted from the PATCH body."
  }
}
