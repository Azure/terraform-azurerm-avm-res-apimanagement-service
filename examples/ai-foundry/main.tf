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
  storage_use_azuread = true

  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_client_config" "current" {}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.3.0"
}

# =================================================================
# Resource Group
# =================================================================
resource "azurerm_resource_group" "this" {
  location = var.location
  name     = module.naming.resource_group.name_unique
}

# =================================================================
# AI Foundry Prerequisites: Key Vault, Storage Account, AI Services
# =================================================================

resource "azurerm_key_vault" "this" {
  location                 = azurerm_resource_group.this.location
  name                     = module.naming.key_vault.name_unique
  resource_group_name      = azurerm_resource_group.this.name
  sku_name                 = "standard"
  tenant_id                = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled = true
}

resource "azurerm_key_vault_access_policy" "deployer" {
  key_vault_id = azurerm_key_vault.this.id
  object_id    = data.azurerm_client_config.current.object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  key_permissions = [
    "Create",
    "Get",
    "Delete",
    "Purge",
    "GetRotationPolicy",
  ]
}

resource "azurerm_storage_account" "this" {
  account_replication_type        = "LRS"
  account_tier                    = "Standard"
  location                        = azurerm_resource_group.this.location
  name                            = module.naming.storage_account.name_unique
  resource_group_name             = azurerm_resource_group.this.name
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
}

resource "azurerm_ai_services" "this" {
  location            = azurerm_resource_group.this.location
  name                = "${module.naming.cognitive_account.name_unique}-ais"
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "S0"
}

# =================================================================
# AI Foundry Hub
# =================================================================
resource "azurerm_ai_foundry" "this" {
  key_vault_id        = azurerm_key_vault.this.id
  location            = azurerm_resource_group.this.location
  name                = "${module.naming.cognitive_account.name_unique}-hub"
  resource_group_name = azurerm_resource_group.this.name
  storage_account_id  = azurerm_storage_account.this.id

  identity {
    type = "SystemAssigned"
  }
}

# =================================================================
# AI Foundry Project
# =================================================================
resource "azurerm_ai_foundry_project" "this" {
  ai_services_hub_id = azurerm_ai_foundry.this.id
  location           = azurerm_ai_foundry.this.location
  name               = "${module.naming.cognitive_account.name_unique}-project"

  identity {
    type = "SystemAssigned"
  }
}

# =================================================================
# Grant APIM managed identity "Cognitive Services OpenAI User" role
# on the AI Services account for managed identity authentication
# =================================================================
resource "azurerm_role_assignment" "apim_cognitive_services" {
  principal_id         = module.apim.workspace_identity.principal_id
  scope                = azurerm_ai_services.this.id
  role_definition_name = "Cognitive Services OpenAI User"
}

# =================================================================
# API Management Module with AI Foundry Backend
# =================================================================
module "apim" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = module.naming.api_management.name_unique
  publisher_email     = var.publisher_email
  resource_group_name = azurerm_resource_group.this.name
  # =================================================================
  # APIs Configuration
  # An API that proxies to the AI Foundry backend with managed identity auth
  # =================================================================
  apis = {
    "ai-foundry-api" = {
      display_name          = "AI Foundry API"
      path                  = "ai"
      protocols             = ["https"]
      revision              = "1"
      description           = "Azure AI Foundry API with managed identity authentication"
      subscription_required = true

      # Policy routes to the AI Foundry backend and authenticates with managed identity
      policy = {
        xml_content = <<-XML
<policies>
  <inbound>
    <base />
    <set-backend-service backend-id="ai-foundry-backend" />
    <authentication-managed-identity resource="https://cognitiveservices.azure.com/" />
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
        # Chat Completions endpoint (Azure OpenAI compatible)
        "chat-completions" = {
          display_name = "Chat Completions"
          method       = "POST"
          url_template = "/deployments/{deployment-id}/chat/completions"
          description  = "Creates a chat completion for the given deployment"

          template_parameters = [
            {
              name        = "deployment-id"
              required    = true
              type        = "string"
              description = "The deployment name of the model"
            }
          ]

          request = {
            description = "Chat completion request body"
            representations = [
              {
                content_type = "application/json"
              }
            ]
          }

          responses = [
            {
              status_code = 200
              description = "Successful chat completion response"
              representations = [
                {
                  content_type = "application/json"
                }
              ]
            }
          ]
        }

        # Completions endpoint
        "completions" = {
          display_name = "Completions"
          method       = "POST"
          url_template = "/deployments/{deployment-id}/completions"
          description  = "Creates a completion for the given deployment"

          template_parameters = [
            {
              name        = "deployment-id"
              required    = true
              type        = "string"
              description = "The deployment name of the model"
            }
          ]

          request = {
            description = "Completion request body"
            representations = [
              {
                content_type = "application/json"
              }
            ]
          }

          responses = [
            {
              status_code = 200
              description = "Successful completion response"
              representations = [
                {
                  content_type = "application/json"
                }
              ]
            }
          ]
        }

        # Embeddings endpoint
        "embeddings" = {
          display_name = "Embeddings"
          method       = "POST"
          url_template = "/deployments/{deployment-id}/embeddings"
          description  = "Creates embeddings for the given deployment"

          template_parameters = [
            {
              name        = "deployment-id"
              required    = true
              type        = "string"
              description = "The deployment name of the model"
            }
          ]

          request = {
            description = "Embeddings request body"
            representations = [
              {
                content_type = "application/json"
              }
            ]
          }

          responses = [
            {
              status_code = 200
              description = "Successful embeddings response"
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
    # Azure AI Foundry / Azure OpenAI backend
    # Routes through the AI Services endpoint; resource_id links APIM to the AI service
    "ai-foundry-backend" = {
      protocol    = "http"
      url         = "${azurerm_ai_services.this.endpoint}openai"
      description = "Azure AI Foundry backend via AI Services"
      title       = "AI Foundry"
      resource_id = "https://management.azure.com${azurerm_ai_services.this.id}"
    }
  }
  enable_telemetry = var.enable_telemetry
  # Enable system-assigned managed identity for backend authentication
  managed_identities = {
    system_assigned = true
  }
  # =================================================================
  # Products Configuration
  # =================================================================
  products = {
    "ai-product" = {
      display_name          = "AI Services"
      description           = "AI Foundry API access"
      subscription_required = true
      approval_required     = false
      state                 = "published"
      api_names             = ["ai-foundry-api"]
      group_names           = ["developers"]
    }
  }
  publisher_name = "Contoso"
  sku_name       = "Developer_1"
  # =================================================================
  # Subscriptions Configuration
  # =================================================================
  subscriptions = {
    "ai-subscription" = {
      display_name     = "AI Services Subscription"
      scope_type       = "product"
      scope_identifier = "ai-product"
      state            = "active"
      allow_tracing    = true
    }
  }
}
