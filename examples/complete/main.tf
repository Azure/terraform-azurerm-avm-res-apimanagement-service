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
  subscription_id = var.subscription_id
  features {}
}

## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group, or use a specified region.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = ">= 0.3.0"
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
  version = ">= 0.3.0"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = local.azure_region
  name     = "${var.resource_group_name_prefix}-${module.naming.resource_group.name_unique}"
}

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
  # Named values are like environment variables - can be referenced in policies
  # =================================================================
  named_values = {
    # Plain text configuration value
    "backend-url" = {
      display_name = "Backend-URL"
      value        = "http://echoapi.cloudapp.net/api"
      tags         = ["configuration", "url"]
    }

    # Secret value (encrypted at rest in APIM)
    "api-key" = {
      display_name = "API-Key"
      value        = "secret-key-value-12345"
      secret       = true
      tags         = ["secret", "api"]
    }

    # Environment indicator
    "environment" = {
      display_name = "Environment"
      value        = "development"
      tags         = ["environment"]
    }
  }

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
      api_names             = ["echo-api"]  # Link API to this product
      group_names           = ["developers"]
    }

    "premium" = {
      display_name          = "Premium"
      description           = "Premium access with higher rate limits - requires approval"
      subscription_required = true
      approval_required     = true
      subscriptions_limit   = 10
      state                 = "published"
      api_names             = ["echo-api"]  # Same API, different product tier
      group_names           = ["developers", "guests"]
    }
  }

  # =================================================================
  # Subscriptions Configuration
  # Subscriptions provide access keys for consuming products/APIs
  # =================================================================
  subscriptions = {
    "starter-subscription" = {
      display_name     = "Starter Subscription"
      scope_type       = "product"
      scope_identifier = "starter"
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

  # Enable managed identity (optional - useful for accessing other Azure resources)
  managed_identities = {
    system_assigned = true
  }
}
