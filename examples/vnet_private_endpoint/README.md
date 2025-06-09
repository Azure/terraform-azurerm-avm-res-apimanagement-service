<!-- BEGIN_TF_DOCS -->
# Default example

This deploys the module in its simplest form.

```hcl
terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
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

  }
}


## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = "~> 0.3"
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
  version = "~> 0.3"
}


# Create a virtual network for testing if needed
module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.8.0"

  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  name                = module.naming.virtual_network.name_unique
  subnets = {
    default_subnet = {
      name             = "default_subnet"
      address_prefixes = ["10.0.1.0/24"]
      # delegations       = {}
    }
    pe_subnet = {
      name              = "pe_subnet"
      address_prefixes  = ["10.0.2.0/24"]
      service_endpoints = []
      # delegations       = {}
    }
  }
}


# Create a Private DNS Zone for API Management
module "private_dns_apim" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "~> 0.2"

  domain_name         = "privatelink.azure-api.net"
  resource_group_name = azurerm_resource_group.this.name
  # tags             = var.tags
  enable_telemetry = var.enable_telemetry
  virtual_network_links = {
    dnslink = {
      vnetlinkname = "privatelink-azure-api-net"
      vnetid       = module.virtual_network.resource.id
    }
  }
}


# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = module.naming.api_management.name_unique
  publisher_email     = var.publisher_email
  resource_group_name = azurerm_resource_group.this.name
  enable_telemetry    = var.enable_telemetry
  # private endpoints
  # Add private endpoint configuration
  private_endpoints = {
    endpoint1 = {
      name               = "pe-${module.naming.api_management.name_unique}"
      subnet_resource_id = module.virtual_network.subnets["pe_subnet"].resource_id

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
  sku_name       = "Developer_1"
  tags = {
    environment = "test"
    cost_center = "test"
  }
  virtual_network_type = "None"
}

```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (3.6.2)

## Resources

The following resources are used by this module:

- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/3.6.2/docs/resources/integer) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_publisher_email"></a> [publisher\_email](#input\_publisher\_email)

Description: The email address of the publisher.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: ~> 0.3

### <a name="module_private_dns_apim"></a> [private\_dns\_apim](#module\_private\_dns\_apim)

Source: Azure/avm-res-network-privatednszone/azurerm

Version: ~> 0.2

### <a name="module_regions"></a> [regions](#module\_regions)

Source: Azure/regions/azurerm

Version: ~> 0.3

### <a name="module_test"></a> [test](#module\_test)

Source: ../../

Version:

### <a name="module_virtual_network"></a> [virtual\_network](#module\_virtual\_network)

Source: Azure/avm-res-network-virtualnetwork/azurerm

Version: ~> 0.8.0

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->