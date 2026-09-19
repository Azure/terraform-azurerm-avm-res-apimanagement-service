mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
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
    condition     = output.name == "correlation"
    error_message = "The policy-fragment output must preserve the configured name."
  }
}
