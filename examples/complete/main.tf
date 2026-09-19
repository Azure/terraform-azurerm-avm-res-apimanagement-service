terraform {
  required_version = ">= 1.9"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0, < 4.0.0"
    }
  }
}

provider "azapi" {}

provider "azurerm" {
  features {}
}

## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group, or use a specified region.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = "0.8.1"
}

# Use specified region or random one if not provided
locals {
  azure_region = var.azure_region != null ? var.azure_region : module.regions.regions[random_integer.region_index.result].name
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
  version = "0.4.2"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = local.azure_region
  name     = module.naming.resource_group.name_unique
}

# This is the module call
module "apim" {
  source = "../../"

  location        = azurerm_resource_group.this.location
  name            = module.naming.api_management.name_unique
  parent_id       = azurerm_resource_group.this.id
  publisher_email = "admin@contoso.com"
  # =================================================================
  # APIs with Operations Configuration
  # =================================================================
  apis = {
    # Simple Echo API for testing
    "echo-api" = {
      display_name          = "Echo API"
      path                  = "echo"
      protocols             = ["https"]
      revision              = "1"
      description           = "Simple echo API for testing - returns request information"
      subscription_required = true
      service_url           = "http://echoapi.cloudapp.net/api"

      # API-Level Policy - applies to all operations in this API
      policy = {
        xml_content = <<-XML
<policies>
  <inbound>
    <base />
    <include-fragment fragment-id="correlation-header" />
    <rate-limit calls="100" renewal-period="60" />
    <set-header name="X-API-Name" exists-action="override">
      <value>Echo API</value>
    </set-header>
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
    <set-header name="X-Powered-By" exists-action="delete" />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
XML
      }

      # Single operation to demonstrate API operation creation
      operations = {
        "get-resource" = {
          display_name = "Get Resource"
          method       = "GET"
          url_template = "/resource"
          description  = "Echo back request information"

          responses = [
            {
              status_code = 200
              description = "Success - returns request echo"
              representations = [
                {
                  content_type = "application/json"
                }
              ]
            }
          ]
        }
      }
    }
  }
  # =================================================================
  # Backends Configuration
  # =================================================================
  backends = {
    # Simple HTTP backend for the Echo API
    "echo-backend" = {
      protocol    = "http"
      url         = "https://echoapi.cloudapp.net/api"
      description = "Echo API backend service"
      title       = "Echo Backend"
      tls = {
        validate_certificate_chain = true
        validate_certificate_name  = true
      }
    }
    "echo-backend-secondary" = {
      protocol    = "http"
      url         = "https://echoapi.cloudapp.net/api"
      description = "Secondary echo backend"
      title       = "Echo Backend Secondary"
    }
    "echo-pool" = {
      type        = "Pool"
      description = "Weighted echo backend pool"
      pool = {
        services = [
          {
            backend_name = "echo-backend"
            priority     = 1
            weight       = 80
          },
          {
            backend_name = "echo-backend-secondary"
            priority     = 1
            weight       = 20
          },
        ]
      }
    }
  }
  delegation = {
    subscriptions_enabled     = false
    user_registration_enabled = false
  }
  enable_telemetry = var.enable_telemetry
  # Enable managed identity (optional - useful for accessing other Azure resources)
  managed_identities = {
    system_assigned = true
  }
  # =================================================================
  # Named Values Configuration
  # Named values are like environment variables - can be referenced in policies
  # =================================================================
  named_values = merge(
    {
      # Plain text configuration value
      "backend-url" = {
        display_name = "Backend-URL"
        value        = "https://echoapi.cloudapp.net/api"
        tags         = ["configuration", "url"]
      }

      # Environment indicator
      "environment" = {
        display_name = "Environment"
        value        = "development"
        tags         = ["environment"]
      }
    },
    var.named_value_secret == null ? {} : {
      "api-key" = {
        display_name = "API-Key"
        value        = var.named_value_secret
        secret       = true
        tags         = ["secret", "api"]
      }
    },
    var.key_vault_secret_identifier == null ? {} : {
      "key-vault-secret" = {
        display_name = "Key-Vault-Secret"
        secret       = true
        value_from_key_vault = {
          secret_id = var.key_vault_secret_identifier
        }
      }
    },
  )
  policy_fragments = {
    "correlation-header" = {
      description = "Adds a stable correlation header when one is not supplied."
      value       = "<fragment><set-header name=\"X-Correlation-ID\" exists-action=\"skip\"><value>@(context.RequestId.ToString())</value></set-header></fragment>"
    }
  }
  # =================================================================
  # Products Configuration
  # Products package APIs with policies and access control
  # =================================================================
  products = {
    "starter" = {
      display_name          = "Starter"
      description           = "Basic API access for developers"
      subscription_required = true
      approval_required     = false
      state                 = "published"
      terms                 = "By subscribing to this product, you agree to our terms of service."
      api_names             = ["echo-api"] # Link API to this product
      group_names           = ["developers"]
    }

    "premium" = {
      display_name          = "Premium"
      description           = "Premium access with higher rate limits - requires approval"
      subscription_required = true
      approval_required     = true
      subscriptions_limit   = 10
      state                 = "published"
      api_names             = ["echo-api"] # Same API, different product tier
      group_names           = ["developers", "guests"]
    }
  }
  publisher_name = "Contoso"
  sign_in = {
    enabled = true
  }
  sign_up = {
    enabled = true
    terms_of_service = {
      consent_required = true
      enabled          = true
      text             = "By signing up, you agree to the developer portal terms of service."
    }
  }
  sku_name = "Premium_3"
  # =================================================================
  # Subscriptions Configuration
  # Subscriptions provide access keys for consuming products/APIs
  # =================================================================
  subscriptions = {
    "starter-subscription" = {
      display_name     = "Starter Subscription"
      primary_key      = var.subscription_primary_key
      scope_type       = "product"
      scope_identifier = "starter"
      secondary_key    = var.subscription_secondary_key
      state            = "active"
      allow_tracing    = true
    }

    "premium-subscription" = {
      display_name     = "Premium Subscription"
      scope_type       = "product"
      scope_identifier = "premium"
      state            = "submitted" # Awaiting approval (because premium requires approval)
      allow_tracing    = true
    }
  }
  tenant_access = {
    enabled = false
  }
  zones = ["1", "2", "3"]
}
