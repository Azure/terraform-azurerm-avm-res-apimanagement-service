mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  enable_telemetry = false
  name             = "policy"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-test"
  value            = "<policies><inbound><base /></inbound><backend><base /></backend><outbound><base /></outbound><on-error><base /></on-error></policies>"
}

run "reads_back_in_default_format" {
  command = plan

  assert {
    condition     = azapi_resource.this.body.properties.format == "xml"
    error_message = "The policy must default to the xml format."
  }

  assert {
    condition     = azapi_resource.this.read_query_parameters == tomap({ format = tolist(["xml"]) })
    error_message = "The policy must be read back in the xml format it is written in."
  }
}

run "reads_back_in_rawxml_format" {
  command = plan

  variables {
    format = "rawxml"
  }

  assert {
    condition     = azapi_resource.this.read_query_parameters == tomap({ format = tolist(["rawxml"]) })
    error_message = "The policy must be read back in the configured rawxml format."
  }
}

run "reads_link_formats_back_inline" {
  command = plan

  variables {
    format = "xml-link"
    value  = "https://example.com/policy.xml"
  }

  assert {
    condition     = azapi_resource.this.read_query_parameters == tomap({ format = tolist(["xml"]) })
    error_message = "Link formats must be read back with the matching inline format."
  }
}

run "rejects_unknown_format" {
  command = plan

  variables {
    format = "json"
  }

  expect_failures = [
    var.format,
  ]
}
