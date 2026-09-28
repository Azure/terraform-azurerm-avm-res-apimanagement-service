mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  display_name     = "Example API"
  enable_telemetry = false
  name             = "example"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-test"
  path             = "example"
  protocols        = ["https"]
}

run "replaces_api_for_revision_changes" {
  command = plan

  assert {
    condition = azapi_resource.this.replace_triggers_refs == tolist([
      "properties.apiRevision",
    ])
    error_message = "API revision changes must replace the API."
  }
}

run "serializes_api_type_as_api_type" {
  command = plan

  assert {
    condition = (
      azapi_resource.this.body.properties.apiType == "http" &&
      !contains(keys(azapi_resource.this.body.properties), "type")
    )
    error_message = "API type must be serialized as the ARM apiType property without the legacy type property."
  }
}

run "defaults_api_revision_to_one" {
  command = plan

  assert {
    condition     = azapi_resource.this.body.properties.apiRevision == "1"
    error_message = "api_revision must default to the revision Azure assigns, so a refreshed apiRevision does not trigger replacement."
  }
}

run "accepts_matching_revision_suffix" {
  command = plan

  variables {
    api_revision = "2"
    name         = "example;rev=2"
  }

  assert {
    condition     = azapi_resource.this.body.properties.apiRevision == "2"
    error_message = "api_revision must be sent when it matches the name suffix."
  }
}

run "rejects_mismatched_revision_suffix" {
  command = plan

  variables {
    name = "example;rev=2"
  }

  expect_failures = [
    var.api_revision,
  ]
}
