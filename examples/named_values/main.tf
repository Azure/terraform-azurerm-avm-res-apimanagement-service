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

  # Named Values Configuration
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

  # Enable managed identity for Key Vault access
  managed_identities = {
    system_assigned = true
  }

  depends_on = [
    azurerm_key_vault_secret.db_connection
  ]
}

# Grant APIM access to Key Vault
resource "azurerm_key_vault_access_policy" "apim" {
  key_vault_id = azurerm_key_vault.this.id
  object_id    = module.apim.workspace_identity.principal_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions = [
    "Get",
    "List",
  ]

  depends_on = [module.apim]
}
