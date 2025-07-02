# The identities are not needs to deploy into a vent, but are showcasing how to mix and use
# the different features of the AVM
terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
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
  version = "0.3.0"
}
data "azurerm_client_config" "current" {}


resource "azurerm_resource_group" "this" {
  location = var.location
  name     = module.naming.resource_group.name_unique
}



# Create Virtual Network and Subnets
resource "azurerm_virtual_network" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
  tags = {
    environment = "test"
    cost_center = "test"
  }
}

resource "azurerm_subnet" "private_endpoints" {
  address_prefixes     = ["10.0.1.0/24"]
  name                 = "private_endpoints"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_subnet" "apim_subnet" {
  address_prefixes     = ["10.0.2.0/24"]
  name                 = "apim_subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_subnet" "default" {
  address_prefixes     = ["10.0.3.0/24"]
  name                 = "default"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

# Private DNS Zone for API Management
module "private_dns_apim" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "~> 0.2"

  domain_name         = "privatelink.azure-api.net"
  resource_group_name = azurerm_resource_group.this.name
  enable_telemetry    = var.enable_telemetry
  virtual_network_links = {
    dnslink = {
      vnetlinkname = "privatelink-azure-api-net"
      vnetid       = azurerm_virtual_network.this.id
    }
  }
}

resource "azurerm_user_assigned_identity" "cmk" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

# This is the module call
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"

  # Remove the hardcoded location and use the resource group location
  location            = azurerm_resource_group.this.location
  name                = module.naming.api_management.name_unique
  publisher_email     = var.publisher_email
  resource_group_name = azurerm_resource_group.this.name
  enable_telemetry    = var.enable_telemetry
  # Add private endpoint configuration
  private_endpoints = {
    endpoint1 = {
      name               = "pe-${module.naming.api_management.name_unique}"
      subnet_resource_id = azurerm_subnet.private_endpoints.id

      # Link to the private DNS zone we created
      private_dns_zone_resource_ids = [
        module.private_dns_apim.resource.id
      ]

      tags = {
        environment = "test"
        service     = "apim"
      }
    }
  }
  publisher_name = "Apim Example Publisher"
  role_assignments = {
    deployment_user_secrets = {
      role_definition_id_or_name = "/providers/Microsoft.Authorization/roleDefinitions/00482a5a-887f-4fb3-b363-3b7fe8e74483" # Key Vault Administrator
      principal_id               = data.azurerm_client_config.current.object_id
    }

    cosmos_db = {
      role_definition_id_or_name       = "/providers/Microsoft.Authorization/roleDefinitions/e147488a-f6f5-4113-8e2d-b22465e65bf6" # Key Vault Crypto Service Encryption User
      principal_id                     = "a232010e-820c-4083-83bb-3ace5fc29d0b"                                                    # CosmosDB **FOR AZURE GOV** use "57506a73-e302-42a9-b869-6f12d9ec29e9"
      skip_service_principal_aad_check = true                                                                                      # because it isn't a traditional SP
    }

    uai = {
      role_definition_id_or_name = "/providers/Microsoft.Authorization/roleDefinitions/14b46e9e-c2b7-41b4-b07b-48a6ebf60603" # Key Vault Crypto Officer
      principal_id               = azurerm_user_assigned_identity.cmk.principal_id
    }
  }
  sku_name = "Developer_1"
  tags = {
    environment = "test"
    cost_center = "test"
  }
}
