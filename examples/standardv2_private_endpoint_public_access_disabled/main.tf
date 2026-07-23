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

# StandardV2 has limited regional availability; pin to a supported region.
resource "azurerm_resource_group" "this" {
  location = var.location
  name     = module.naming.resource_group.name_unique
}

# Network security group for the private endpoint subnet.
# Required because compliance-bound landing zones commonly enforce the
# "Deny-Subnet-Without-Nsg" Azure Policy - the same class of policy this
# secure-by-default scenario targets.
resource "azurerm_network_security_group" "pe" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.network_security_group.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

# Virtual network to host the private endpoint.
module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.9.2"

  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  name                = module.naming.virtual_network.name_unique
  subnets = {
    pe_subnet = {
      name             = "pe_subnet"
      address_prefixes = ["10.0.2.0/24"]
      network_security_group = {
        id = azurerm_network_security_group.pe.id
      }
    }
  }
}

# Private DNS Zone for API Management so the private endpoint resolves automatically.
module "private_dns_apim" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.4.0"

  domain_name      = "privatelink.azure-api.net"
  parent_id        = azurerm_resource_group.this.id
  enable_telemetry = var.enable_telemetry
  virtual_network_links = {
    dnslink = {
      name         = "dnslink-azure-apim"
      vnetlinkname = "privatelink-azure-api-net"
      vnetid       = module.virtual_network.resource.id
    }
  }
}

# Module call: StandardV2 deployed "secure-by-default" (public network access disabled
# from the very first apply) together with a private endpoint.
#
# This scenario targets compliance-bound landing zones where Azure Policy blocks the
# creation of services with public network access enabled. The corresponding Bicep test
# uses a two-pass (enable-then-disable) workaround; this example asserts the App
# Service-style behavior of deploying the service fully closed from the start.
module "test" {
  source = "../../"

  location                      = azurerm_resource_group.this.location
  name                          = module.naming.api_management.name_unique
  publisher_email               = var.publisher_email
  publisher_name                = "Apim Example Publisher"
  resource_group_name           = azurerm_resource_group.this.name
  enable_telemetry              = var.enable_telemetry
  sku_name                      = "StandardV2_1"
  virtual_network_type          = "None"
  public_network_access_enabled = false

  private_endpoints = {
    endpoint1 = {
      name               = "pe-${module.naming.api_management.name_unique}"
      subnet_resource_id = module.virtual_network.subnets["pe_subnet"].resource_id

      private_dns_zone_resource_ids = [
        module.private_dns_apim.resource.id
      ]

      tags = {
        environment = "test"
        service     = "apim"
      }
    }
  }

  tags = {
    environment = "test"
    cost_center = "test"
  }
}
