# File: tests/unit/unit.tftest.hcl

# Mock the azurerm provider to prevent real deployments
mock_provider "azurerm" {}
mock_provider "modtm" {}
mock_provider "azapi" {}

run "validate_empty_api_path" {
  command = plan

  # This should succeed if an empty api path is supported

  variables {
    name                = "test-apim-service"
    resource_group_name = "test-rg"
    location            = "eastus"
    publisher_email     = "admin@example.com"
    publisher_name      = "Example Publisher"
    sku_name            = "Developer_1"
    
    # Configure an API input with an empty path string to test validation behavior
    apis = {
      test_empty_path = {
        display_name = "Test Empty Path API"
        path         = ""
        protocols    = ["https"]
      }
    }
  }
}

run "expect_bad_api_path" {
  command = plan

  # This should succeed if an empty api path is supported

  variables {
    name                = "test-apim-service"
    resource_group_name = "test-rg"
    location            = "eastus"
    publisher_email     = "admin@example.com"
    publisher_name      = "Example Publisher"
    sku_name            = "Developer_1"
    
    # Configure an API input with an empty path string to test validation behavior
    apis = {
      test_empty_path = {
        display_name = "Test Empty Path API"
        path         = "^*#&+:<>?"
        protocols    = ["https"]
      }
    }
  }

  # Expect the plan or validation to catch the path name restrictions
  expect_failures = [
    var.apis
  ]
}