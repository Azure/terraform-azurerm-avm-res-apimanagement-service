terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = var.location
  name     = module.naming.resource_group.name_unique
}

resource "random_string" "apim_name_suffix" {
  length  = 8
  numeric = true
  special = false
  upper   = false
}

# This is the module call
module "apim" {
  source = "../../"

  enable_telemetry    = var.enable_telemetry
  location            = azurerm_resource_group.this.location
  name                = "${module.naming.api_management.name_unique}-${random_string.apim_name_suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  publisher_email     = var.publisher_email
  publisher_name      = var.publisher_name
  sku_name            = var.sku_name

  # Basic APIs with operations
  apis = {
    # Simple REST API with basic operations
    "petstore-api" = {
      display_name          = "Petstore API"
      path                  = "petstore"
      protocols             = ["https"]
      service_url           = "https://petstore.swagger.io/v2"
      description           = "A sample Petstore API for demonstration"
      subscription_required = true
      revision              = "1"

      operations = {
        "get-pets" = {
          display_name = "Get all pets"
          method       = "GET"
          url_template = "/pets"
          description  = "Returns all pets from the system"

          responses = [
            {
              status_code = 200
              description = "Successful response"
              representations = [
                {
                  content_type = "application/json"
                  sample       = jsonencode([{ id = 1, name = "Fluffy", category = "cat" }])
                }
              ]
            }
          ]
        }

        "get-pet-by-id" = {
          display_name = "Get pet by ID"
          method       = "GET"
          url_template = "/pets/{petId}"
          description  = "Returns a single pet by ID"

          template_parameters = [
            {
              name        = "petId"
              required    = true
              type        = "string"
              description = "The ID of the pet to retrieve"
            }
          ]

          responses = [
            {
              status_code = 200
              description = "Successful response"
              representations = [
                {
                  content_type = "application/json"
                  sample       = jsonencode({ id = 1, name = "Fluffy", category = "cat" })
                }
              ]
            },
            {
              status_code = 404
              description = "Pet not found"
            }
          ]
        }

        "create-pet" = {
          display_name = "Create a new pet"
          method       = "POST"
          url_template = "/pets"
          description  = "Creates a new pet in the store"

          request = {
            description = "Pet object to be created"
            representations = [
              {
                content_type = "application/json"
                sample = jsonencode({
                  name     = "Fluffy"
                  category = "cat"
                  status   = "available"
                })
              }
            ]
          }

          responses = [
            {
              status_code = 201
              description = "Pet created successfully"
              representations = [
                {
                  content_type = "application/json"
                  sample       = jsonencode({ id = 1, name = "Fluffy", category = "cat", status = "available" })
                }
              ]
            }
          ]
        }

        "update-pet" = {
          display_name = "Update an existing pet"
          method       = "PUT"
          url_template = "/pets/{petId}"
          description  = "Updates an existing pet"

          template_parameters = [
            {
              name        = "petId"
              required    = true
              type        = "string"
              description = "The ID of the pet to update"
            }
          ]

          request = {
            description = "Updated pet object"
            representations = [
              {
                content_type = "application/json"
                sample = jsonencode({
                  name     = "Fluffy Updated"
                  category = "cat"
                  status   = "sold"
                })
              }
            ]
          }

          responses = [
            {
              status_code = 200
              description = "Pet updated successfully"
            },
            {
              status_code = 404
              description = "Pet not found"
            }
          ]
        }

        "delete-pet" = {
          display_name = "Delete a pet"
          method       = "DELETE"
          url_template = "/pets/{petId}"
          description  = "Deletes a pet from the store"

          template_parameters = [
            {
              name        = "petId"
              required    = true
              type        = "string"
              description = "The ID of the pet to delete"
            }
          ]

          responses = [
            {
              status_code = 204
              description = "Pet deleted successfully"
            },
            {
              status_code = 404
              description = "Pet not found"
            }
          ]
        }
      }
    }

    # Simple API with query parameters
    "weather-api" = {
      display_name          = "Weather API"
      path                  = "weather"
      protocols             = ["https"]
      service_url           = "https://api.weather.example.com"
      description           = "Weather information API"
      subscription_required = true

      operations = {
        "get-current-weather" = {
          display_name = "Get current weather"
          method       = "GET"
          url_template = "/current"
          description  = "Get current weather for a location"

          request = {
            query_parameters = [
              {
                name        = "city"
                required    = true
                type        = "string"
                description = "City name"
              },
              {
                name          = "units"
                required      = false
                type          = "string"
                description   = "Units of measurement"
                default_value = "metric"
                values        = ["metric", "imperial"]
              }
            ]
          }

          responses = [
            {
              status_code = 200
              description = "Successful response"
              representations = [
                {
                  content_type = "application/json"
                  sample = jsonencode({
                    city        = "Seattle"
                    temperature = 15.5
                    humidity    = 75
                    conditions  = "Partly cloudy"
                  })
                }
              ]
            }
          ]
        }
      }
    }
  }
}
