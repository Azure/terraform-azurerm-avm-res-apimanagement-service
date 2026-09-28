mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  description      = "Adds a correlation header."
  enable_telemetry = false
  name             = "correlation"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ApiManagement/service/apim-test"
  value            = "<fragment><set-header name=\"X-Correlation-ID\" exists-action=\"skip\"><value>@(context.RequestId.ToString())</value></set-header></fragment>"
}

run "creates_policy_fragment" {
  command = apply

  assert {
    condition     = local.resource_body.properties.format == "rawxml"
    error_message = "Policy fragments must default to the rawxml format."
  }

  assert {
    condition = (
      local.resource_body.properties.description == "Adds a correlation header." &&
      local.resource_body.properties.value == var.value
    )
    error_message = "Policy fragments must map the complete ARM body."
  }

  assert {
    condition     = output.name == "correlation"
    error_message = "The policy-fragment output must preserve the configured name."
  }
}

run "reads_back_in_configured_format" {
  command = plan

  assert {
    condition     = azapi_resource.this.read_query_parameters == tomap({ format = tolist(["rawxml"]) })
    error_message = "Policy fragments must be read back in the configured rawxml format."
  }
}

run "reads_back_xml_format" {
  command = plan

  variables {
    format = "xml"
    value  = "<fragment><set-header name=\"X-Test\" exists-action=\"skip\"><value>test</value></set-header></fragment>"
  }

  assert {
    condition     = azapi_resource.this.read_query_parameters == tomap({ format = tolist(["xml"]) })
    error_message = "Policy fragments must be read back in the configured xml format."
  }
}
