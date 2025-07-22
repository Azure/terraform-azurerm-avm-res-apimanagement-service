terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
  }
}

provider "azurerm" {

  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

  }
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = var.location
  name     = module.naming.resource_group.name_unique
}

# This is the module call
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = module.naming.api_management.name_unique
  publisher_email     = var.publisher_email
  resource_group_name = azurerm_resource_group.this.name
  enable_telemetry    = var.enable_telemetry
  managed_identities = {
    system_assigned = true
  }
  publisher_name = "Apim Example Publisher"
  security = {
    enable_backend_ssl30                           = true
    tls_rsa_with_aes128_gcm_sha256_ciphers_enabled = true
  }
  sku_name = "Premium_3"
  # sku_name = "Developer_1"
  tags = {
    environment = "test"
    cost_center = "test"
  }
  zones = ["1", "2", "3"] # For compliance with WAF
}
