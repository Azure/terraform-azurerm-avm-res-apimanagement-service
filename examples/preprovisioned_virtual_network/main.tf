terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    modtm = {
      source  = "Azure/modtm"
      version = "0.3.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
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
    #     api_management {
    # purge_soft_delete_on_destroy = false
    #     min_api_version = "2024-10-01-preview"
    #     }
  }
}

# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.3.0"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.3.0"
}

resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name_unique
  location = module.regions.regions[random_integer.region_index.result].name
}



# Create Virtual Network and Subnets
resource "azurerm_virtual_network" "this" {
  name                = module.naming.virtual_network.name_unique
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  tags = {
    environment = "test"
    cost_center = "test"
  }
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "private_endpoints"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
  # private_endpoint_network_policies = "Enabled"
}

resource "azurerm_subnet" "apim_subnet" {
  name                 = "apim_subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Private DNS Zone for API Management
module "private_dns_apim" {
  source              = "Azure/avm-res-network-privatednszone/azurerm"
  version             = "~> 0.2"
  domain_name         = "privatelink.azure-api.net"
  resource_group_name = azurerm_resource_group.this.name
  virtual_network_links = {
    dnslink = {
      vnetlinkname = "privatelink-azure-api-net"
      vnetid       = azurerm_virtual_network.this.id
    }
  }
  enable_telemetry = var.enable_telemetry
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"
  # Remove the hardcoded location and use the resource group location
  location            = azurerm_resource_group.this.location
  name                = module.naming.api_management.name_unique
  resource_group_name = azurerm_resource_group.this.name
  publisher_email     = var.publisher_email # see variables.tf
  publisher_name      = "Apim Example Publisher"
  sku_name            = "Developer_1"
  tags = {
    environment = "test"
    cost_center = "test"
  }
  enable_telemetry = var.enable_telemetry

  # Use the newly created subnet for API Management
  virtual_network_type      = "External"
  virtual_network_subnet_id = azurerm_subnet.apim_subnet.id

}
