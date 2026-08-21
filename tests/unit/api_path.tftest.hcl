# Mock the azurerm provider to prevent real deployments
mock_provider "azurerm" {}
mock_provider "modtm" {}
mock_provider "azapi" {}

# Common variables for all runs
variables {
  name                = "test-apim-service"
  resource_group_name = "test-rg"
  location            = "eastus"
  publisher_email     = "admin@example.com"
  publisher_name      = "Example Publisher"
  sku_name            = "Developer_1"
}

run "validate_empty_api_path" {
  command = plan

  # This should succeed if an empty api path is supported

  variables {    
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

run "validate_api_folder_path" {
  command = plan

  # This should succeed if an api path with folder name is supported

  variables {    
    # Configure an API input with an empty path string to test validation behavior
    apis = {
      test_empty_path = {
        display_name = "Test API path with folder"
        path         = "newpath/newfolder"
        protocols    = ["https"]
      }
    }
  }
}


# The next 8 tests look at all the invalid values that validation should catch for apis.path

run "expect_bad_api_path_1" {
  command = plan

  # This should expect to fail if an invalid api path is passed in

  variables {    
    # Configure an API input with an invalid path string to test validation behavior
    apis = {
      test_empty_path = {
        display_name = "Test Invalid API Path"
        path         = "new*path"
        protocols    = ["https"]
      }
    }
  }

  # Expect the plan or validation to catch the path name restrictions
  expect_failures = [
    var.apis
  ]
}

run "expect_bad_api_path_2" {
  command = plan

  # This should expect to fail if an invalid api path is passed in

  variables {
    # Configure an API input with an invalid path string to test validation behavior
    apis = {
      test_empty_path = {
        display_name = "Test Invalid API Path"
        path         = "new#path"
        protocols    = ["https"]
      }
    }
  }

  # Expect the plan or validation to catch the path name restrictions
  expect_failures = [
    var.apis
  ]
}

run "expect_bad_api_path_3" {
  command = plan

  # This should expect to fail if an invalid api path is passed in

  variables {
    # Configure an API input with an invalid path string to test validation behavior
    apis = {
      test_empty_path = {
        display_name = "Test Invalid API Path"
        path         = "new&path"
        protocols    = ["https"]
      }
    }
  }

  # Expect the plan or validation to catch the path name restrictions
  expect_failures = [
    var.apis
  ]
}

run "expect_bad_api_path_4" {
  command = plan

  # This should expect to fail if an invalid api path is passed in

  variables {
    # Configure an API input with an invalid path string to test validation behavior
    apis = {
      test_empty_path = {
        display_name = "Test Invalid API Path"
        path         = "new+path"
        protocols    = ["https"]
      }
    }
  }

  # Expect the plan or validation to catch the path name restrictions
  expect_failures = [
    var.apis
  ]
}

run "expect_bad_api_path_5" {
  command = plan

  # This should expect to fail if an invalid api path is passed in

  variables {
    # Configure an API input with an invalid path string to test validation behavior
    apis = {
      test_empty_path = {
        display_name = "Test Invalid API Path"
        path         = "new:path"
        protocols    = ["https"]
      }
    }
  }

  # Expect the plan or validation to catch the path name restrictions
  expect_failures = [
    var.apis
  ]
}

run "expect_bad_api_path_6" {
  command = plan

  # This should expect to fail if an invalid api path is passed in

  variables {
    # Configure an API input with an invalid path string to test validation behavior
    apis = {
      test_empty_path = {
        display_name = "Test Invalid API Path"
        path         = "new<path"
        protocols    = ["https"]
      }
    }
  }

  # Expect the plan or validation to catch the path name restrictions
  expect_failures = [
    var.apis
  ]
}

run "expect_bad_api_path_7" {
  command = plan

  # This should expect to fail if an invalid api path is passed in

  variables {
    name                = "test-apim-service"
    resource_group_name = "test-rg"
    location            = "eastus"
    publisher_email     = "admin@example.com"
    publisher_name      = "Example Publisher"
    sku_name            = "Developer_1"
    
    # Configure an API input with an invalid path string to test validation behavior
    apis = {
      test_empty_path = {
        display_name = "Test Invalid API Path"
        path         = "new>path"
        protocols    = ["https"]
      }
    }
  }

  # Expect the plan or validation to catch the path name restrictions
  expect_failures = [
    var.apis
  ]
}

run "expect_bad_api_path_8" {
  command = plan

  # This should expect to fail if an invalid api path is passed in

  variables {    
    # Configure an API input with an invalid path string to test validation behavior
    apis = {
      test_empty_path = {
        display_name = "Test Invalid API Path"
        path         = "new?path"
        protocols    = ["https"]
      }
    }
  }

  # Expect the plan or validation to catch the path name restrictions
  expect_failures = [
    var.apis
  ]
}
