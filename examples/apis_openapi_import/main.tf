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

# Sample OpenAPI specification (Petstore API)
locals {
  petstore_openapi = jsonencode({
    openapi = "3.0.0"
    info = {
      title       = "Petstore API"
      description = "A sample Petstore API"
      version     = "1.0.0"
    }
    servers = [
      {
        url         = "https://petstore.swagger.io/v2"
        description = "Production server"
      }
    ]
    paths = {
      "/pet" = {
        post = {
          summary     = "Add a new pet"
          operationId = "addPet"
          requestBody = {
            required = true
            content = {
              "application/json" = {
                schema = {
                  type = "object"
                  properties = {
                    id   = { type = "integer", format = "int64" }
                    name = { type = "string" }
                    status = {
                      type = "string"
                      enum = ["available", "pending", "sold"]
                    }
                  }
                  required = ["name"]
                }
              }
            }
          }
          responses = {
            "201" = {
              description = "Created"
              content = {
                "application/json" = {
                  schema = {
                    type = "object"
                    properties = {
                      id     = { type = "integer" }
                      name   = { type = "string" }
                      status = { type = "string" }
                    }
                  }
                }
              }
            }
          }
        }
      }
      "/pet/{petId}" = {
        get = {
          summary     = "Find pet by ID"
          operationId = "getPetById"
          parameters = [
            {
              name     = "petId"
              in       = "path"
              required = true
              schema   = { type = "integer", format = "int64" }
            }
          ]
          responses = {
            "200" = {
              description = "Successful operation"
              content = {
                "application/json" = {
                  schema = {
                    type = "object"
                    properties = {
                      id     = { type = "integer" }
                      name   = { type = "string" }
                      status = { type = "string" }
                    }
                  }
                }
              }
            }
            "404" = {
              description = "Pet not found"
            }
          }
        }
      }
    }
  })
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

  # APIs imported from OpenAPI specifications
  apis = {
    # Import from inline OpenAPI JSON
    "petstore-openapi-inline" = {
      display_name          = "Petstore API (OpenAPI Inline)"
      path                  = "petstore-inline"
      protocols             = ["https"]
      subscription_required = true
      description           = "Imported from inline OpenAPI 3.0 specification"

      import = {
        content_format = "openapi+json"
        content_value  = local.petstore_openapi
      }
    }

    # Import from OpenAPI URL
    "petstore-openapi-url" = {
      display_name          = "Petstore API (OpenAPI URL)"
      path                  = "petstore-url"
      protocols             = ["https"]
      subscription_required = true
      description           = "Imported from OpenAPI specification URL"

      import = {
        content_format = "openapi-link"
        content_value  = "https://petstore.swagger.io/v2/swagger.json"
      }
    }

    # Import Swagger 2.0 specification
    "swagger-petstore" = {
      display_name          = "Petstore API (Swagger 2.0)"
      path                  = "swagger-petstore"
      protocols             = ["https"]
      subscription_required = true
      description           = "Imported from Swagger 2.0 specification"

      import = {
        content_format = "swagger-link-json"
        content_value  = "https://petstore.swagger.io/v2/swagger.json"
      }
    }
  }
}
