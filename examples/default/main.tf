terraform {
  required_version = "~> 1.12"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azapi" {}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.3.0"
}

data "azapi_client_config" "current" {}

resource "azapi_resource" "rg" {
  location  = var.location
  name      = module.naming.resource_group.name_unique
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  type      = "Microsoft.Resources/resourceGroups@2024-03-01"
}

module "test" {
  source = "../../"

  location         = var.location
  name             = module.naming.api_management.name_unique
  parent_id        = azapi_resource.rg.id
  publisher_email  = var.publisher_email
  enable_telemetry = var.enable_telemetry
  publisher_name   = "Apim Example Publisher"
  sku_name         = "Premium_3"
  tags = {
    environment = "test"
    cost_center = "test"
  }
  zones = ["1", "2", "3"]
}
