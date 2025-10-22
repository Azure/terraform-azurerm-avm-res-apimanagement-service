terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "ed1f1918-2165-4549-8356-ab1736f12fe8"
  features {}
}

## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = ">= 0.3.0"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

# Key Vault for storing secrets
resource "azurerm_key_vault" "this" {
  location                   = azurerm_resource_group.this.location
  name                       = module.naming.key_vault.name_unique
  resource_group_name        = azurerm_resource_group.this.name
  sku_name                   = "standard"
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled   = false
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Purge",
    ]
  }
}

# Sample secret in Key Vault
resource "azurerm_key_vault_secret" "db_connection" {
  key_vault_id = azurerm_key_vault.this.id
  name         = "database-connection-string"
  value        = "Server=myserver.database.windows.net;Database=mydb;User Id=myuser;Password=mypassword;"
}

data "azurerm_client_config" "current" {}

# This is the module call
module "apim" {
  source = "../../"

  enable_telemetry    = var.enable_telemetry
  location            = azurerm_resource_group.this.location
  name                = module.naming.api_management.name_unique
  publisher_email     = "admin@contoso.com"
  publisher_name      = "Contoso"
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "Developer_1"

  # =================================================================
  # Named Values Configuration
  # =================================================================
  named_values = {
    # Plain text configuration value
    "api-base-url" = {
      display_name = "API-Base-URL"
      value        = "https://api.contoso.com/v1"
      tags         = ["configuration", "url"]
    }

    # Secret value (encrypted at rest in APIM)
    "api-key" = {
      display_name = "Third-Party-API-Key"
      value        = "sk_test_123456789abcdefghijklmnop"
      secret       = true
      tags         = ["secret", "api", "production"]
    }

    # Configuration value without secret
    "max-retry-attempts" = {
      display_name = "Maximum-Retry-Attempts"
      value        = "3"
      tags         = ["configuration", "retry"]
    }

    # Key Vault backed secret
    # NOTE: Requires Key Vault access to be granted to APIM system-assigned identity before deployment
    # See README.md for setup instructions
    "database-connection-string" = {
      display_name = "Database-Connection-String"
      secret       = true
      value_from_key_vault = {
        secret_id = azurerm_key_vault_secret.db_connection.versionless_id
      }
      tags = ["database", "secret", "keyvault"]
    }

    # Environment indicator
    "environment" = {
      display_name = "Environment"
      value        = "development"
      tags         = ["environment"]
    }

    # API timeout configuration
    "api-timeout-seconds" = {
      display_name = "API-Timeout-Seconds"
      value        = "30"
      tags         = ["configuration", "timeout"]
    }
  }

  # =================================================================
  # API Version Sets Configuration
  # =================================================================
  api_version_sets = {
    "products-api" = {
      display_name      = "Products API"
      versioning_scheme = "Segment" # Version in URL path (e.g., /v1/products)
      description       = "Product management API with URL path versioning"
    }
    "orders-api" = {
      display_name        = "Orders API"
      versioning_scheme   = "Header" # Version in HTTP header
      version_header_name = "Api-Version"
      description         = "Order processing API with header-based versioning"
    }
  }

  # =================================================================
  # APIs with Operations Configuration
  # =================================================================
  apis = {
    # Products API - Version 1
    "products-v1" = {
      display_name          = "Products API v1"
      path                  = "products"
      protocols             = ["https"]
      revision              = "1"
      api_version           = "v1"
      api_version_set_name  = "products-api"
      description           = "Version 1 of the Products API - supports basic CRUD operations"
      subscription_required = true
      service_url           = "https://backend.contoso.com/products"

      # API-Level Policy (applied to all operations in this API)
      policy = {
        xml_content = <<-XML
          <policies>
            <inbound>
              <base />
              <rate-limit calls="100" renewal-period="60" />
              <set-header name="X-API-Version" exists-action="override">
                <value>v1</value>
              </set-header>
              <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" />
            </inbound>
            <backend>
              <base />
            </backend>
            <outbound>
              <base />
              <cache-store duration="60" />
            </outbound>
            <on-error>
              <base />
            </on-error>
          </policies>
        XML
      }

      # Operations for Products V1
      operations = {
        "list-products" = {
          display_name = "List Products"
          method       = "GET"
          url_template = "/"
          description  = "Retrieve a list of all products"

          responses = [
            {
              status_code = 200
              description = "Success - returns list of products"
              representations = [
                {
                  content_type = "application/json"
                }
              ]
            }
          ]
        }

        "get-product" = {
          display_name = "Get Product by ID"
          method       = "GET"
          url_template = "/{productId}"
          description  = "Retrieve a single product by ID"

          template_parameters = [
            {
              name        = "productId"
              required    = true
              type        = "string"
              description = "The unique identifier of the product"
            }
          ]

          responses = [
            {
              status_code = 200
              description = "Success"
            },
            {
              status_code = 404
              description = "Product not found"
            }
          ]
        }

        "create-product" = {
          display_name = "Create Product"
          method       = "POST"
          url_template = "/"
          description  = "Create a new product"

          request = {
            description = "Product creation request"
            representations = [
              {
                content_type = "application/json"
              }
            ]
          }

          responses = [
            {
              status_code = 201
              description = "Created - product created successfully"
            },
            {
              status_code = 400
              description = "Bad Request - invalid product data"
            }
          ]

          # Operation-Level Policy (specific to this operation)
          policy = {
            xml_content = <<-XML
              <policies>
                <inbound>
                  <base />
                  <validate-content unspecified-content-type-action="prevent" max-size="102400" size-exceeded-action="prevent" errors-variable-name="requestBodyValidation">
                    <content type="application/json" validate-as="json" action="prevent" />
                  </validate-content>
                </inbound>
                <backend>
                  <base />
                </backend>
                <outbound>
                  <base />
                </outbound>
                <on-error>
                  <base />
                </on-error>
              </policies>
            XML
          }
        }

        "update-product" = {
          display_name = "Update Product"
          method       = "PUT"
          url_template = "/{productId}"
          description  = "Update an existing product"

          template_parameters = [
            {
              name        = "productId"
              required    = true
              type        = "string"
              description = "The unique identifier of the product"
            }
          ]

          request = {
            representations = [
              {
                content_type = "application/json"
              }
            ]
          }

          responses = [
            {
              status_code = 200
              description = "Success - product updated"
            },
            {
              status_code = 404
              description = "Product not found"
            }
          ]
        }

        "delete-product" = {
          display_name = "Delete Product"
          method       = "DELETE"
          url_template = "/{productId}"
          description  = "Delete a product"

          template_parameters = [
            {
              name        = "productId"
              required    = true
              type        = "string"
              description = "The unique identifier of the product"
            }
          ]

          responses = [
            {
              status_code = 204
              description = "No Content - product deleted successfully"
            },
            {
              status_code = 404
              description = "Product not found"
            }
          ]
        }
      }
    }

    # Products API - Version 2
    "products-v2" = {
      display_name          = "Products API v2"
      path                  = "products"
      protocols             = ["https"]
      revision              = "1"
      api_version           = "v2"
      api_version_set_name  = "products-api"
      description           = "Version 2 of the Products API - includes enhanced features"
      subscription_required = true
      service_url           = "https://backend.contoso.com/products/v2"

      # API-Level Policy for v2
      policy = {
        xml_content = <<-XML
          <policies>
            <inbound>
              <base />
              <rate-limit calls="200" renewal-period="60" />
              <set-header name="X-API-Version" exists-action="override">
                <value>v2</value>
              </set-header>
            </inbound>
            <backend>
              <base />
            </backend>
            <outbound>
              <base />
            </outbound>
            <on-error>
              <base />
            </on-error>
          </policies>
        XML
      }

      operations = {
        "list-products-v2" = {
          display_name = "List Products (Enhanced)"
          method       = "GET"
          url_template = "/"
          description  = "Retrieve a paginated list of products with filtering"

          request = {
            query_parameters = [
              {
                name        = "page"
                type        = "integer"
                required    = false
                description = "Page number for pagination"
              },
              {
                name        = "pageSize"
                type        = "integer"
                required    = false
                description = "Number of items per page"
              },
              {
                name        = "category"
                type        = "string"
                required    = false
                description = "Filter by product category"
              }
            ]
          }

          responses = [
            {
              status_code = 200
              description = "Success - returns paginated list of products"
            }
          ]
        }

        "search-products" = {
          display_name = "Search Products"
          method       = "GET"
          url_template = "/search"
          description  = "Search products by keyword (new in v2)"

          request = {
            query_parameters = [
              {
                name        = "q"
                type        = "string"
                required    = true
                description = "Search query"
              }
            ]
          }

          responses = [
            {
              status_code = 200
              description = "Success - returns matching products"
            }
          ]
        }
      }
    }

    # Orders API - Version 1 (Header-based versioning)
    "orders-v1" = {
      display_name          = "Orders API v1"
      path                  = "orders"
      protocols             = ["https"]
      revision              = "1"
      api_version           = "v1"
      api_version_set_name  = "orders-api"
      description           = "Order processing API - version specified via header"
      subscription_required = true
      service_url           = "https://backend.contoso.com/orders"

      operations = {
        "list-orders" = {
          display_name = "List Orders"
          method       = "GET"
          url_template = "/"
          description  = "Retrieve list of orders"

          responses = [
            {
              status_code = 200
              description = "Success"
            }
          ]
        }

        "create-order" = {
          display_name = "Create Order"
          method       = "POST"
          url_template = "/"
          description  = "Create a new order"

          request = {
            representations = [
              {
                content_type = "application/json"
              }
            ]
          }

          responses = [
            {
              status_code = 201
              description = "Created"
            }
          ]
        }
      }
    }
  }

  # =================================================================
  # Products Configuration
  # =================================================================
  products = {
    "starter" = {
      display_name          = "Starter"
      description           = "Starter product for developers - includes basic APIs with rate limiting"
      subscription_required = true
      approval_required     = false
      state                 = "published"
      terms                 = "By subscribing to this product, you agree to our terms of service and acceptable use policy."
      api_names             = ["products-v1", "orders-v1"]
      group_names           = ["developers"]
    }

    "premium" = {
      display_name          = "Premium"
      description           = "Premium product with enhanced features and higher rate limits"
      subscription_required = true
      approval_required     = true # Requires approval for premium access
      subscriptions_limit   = 10
      state                 = "published"
      api_names             = ["products-v2", "orders-v1"]
      group_names           = ["developers", "guests"]
    }

    "unlimited" = {
      display_name          = "Unlimited"
      description           = "Unlimited access for enterprise customers"
      subscription_required = true
      approval_required     = true
      state                 = "published"
      api_names             = ["products-v1", "products-v2", "orders-v1"]
      group_names           = ["administrators"]
    }
  }

  # =================================================================
  # Subscriptions Configuration
  # =================================================================
  subscriptions = {
    "developer-starter-sub" = {
      display_name     = "Developer Starter Subscription"
      scope_type       = "product"
      scope_identifier = "starter"
      state            = "active"
      allow_tracing    = true
    }

    "developer-premium-sub" = {
      display_name     = "Developer Premium Subscription"
      scope_type       = "product"
      scope_identifier = "premium"
      state            = "submitted" # Awaiting approval
      allow_tracing    = true
    }

    "api-specific-sub" = {
      display_name     = "Products API v1 Subscription"
      scope_type       = "api"
      scope_identifier = "products-v1"
      state            = "active"
      allow_tracing    = false
    }

    "all-apis-sub" = {
      display_name  = "All APIs Access"
      scope_type    = "all_apis"
      state         = "active"
      allow_tracing = true
    }
  }

  # Enable managed identity for Key Vault access
  managed_identities = {
    system_assigned = true
  }

  depends_on = [
    azurerm_key_vault_secret.db_connection
  ]
}

# IMPORTANT: Key Vault Access Policy Management
# ============================================
# Following the Bicep AVM pattern, Key Vault access policy management is the user's responsibility.
# This allows flexibility in deployment strategies and avoids Terraform circular dependencies.
#
# Two deployment options:
#
# Option 1: Two-step deployment (Recommended for first-time setup)
# ----------------------------------------------------------------
# Step 1: Comment out the database-connection-string named value above, then:
#         terraform apply
#         (This creates APIM with system-assigned identity)
#
# Step 2: Grant Key Vault access using Azure CLI:
#         az keyvault set-policy \
#           --name $(terraform output -raw key_vault_name) \
#           --object-id $(terraform output -raw apim_identity_principal_id) \
#           --secret-permissions get list
#
# Step 3: Uncomment the database-connection-string named value above, then:
#         terraform apply
#         (This adds the Key Vault-backed named value)
#
# Option 2: Automated with separate access policy resource (shown below)
# -----------------------------------------------------------------------
# Uncomment the azurerm_key_vault_access_policy resource below for automated deployment.
# Note: This creates a circular dependency that Terraform handles, but may require
# commenting out the KV named value for first apply, then uncommenting for second apply.

# Uncomment to automate Key Vault access policy creation:
# resource "azurerm_key_vault_access_policy" "apim" {
#   key_vault_id = azurerm_key_vault.this.id
#   object_id    = module.apim.workspace_identity.principal_id
#   tenant_id    = data.azurerm_client_config.current.tenant_id
#
#   secret_permissions = [
#     "Get",
#     "List",
#   ]
#
#   depends_on = [module.apim]
# }
