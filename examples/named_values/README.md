# Named Values Example for API Management

This example demonstrates how to create named values in API Management, including both plain text values and Key Vault-backed secrets.

## Features

- Plain text named values
- Secret named values (encrypted at rest)
- Key Vault integration for secrets
- Named values with tags for filtering

## Important: Key Vault Access Policy Management

Following the **Azure Verified Modules (AVM) Bicep pattern**, Key Vault access policy management is the **user's responsibility**. This approach:

- ✅ Avoids Terraform circular dependency issues
- ✅ Provides flexibility in deployment strategies
- ✅ Aligns with AVM Bicep module design
- ✅ Allows proper separation of concerns

### Deployment Options

#### Option 1: Two-Step Deployment (Recommended for First-Time Setup)

**Step 1:** Deploy APIM without Key Vault-backed named values

```bash
# Comment out the 'database-connection-string' named value in main.tf
terraform init
terraform apply
```

**Step 2:** Grant Key Vault access using Azure CLI

```bash
az keyvault set-policy \
  --name $(terraform output -raw key_vault_name) \
  --object-id $(terraform output -raw apim_identity_principal_id) \
  --secret-permissions get list
```

**Step 3:** Add Key Vault-backed named values

```bash
# Uncomment the 'database-connection-string' named value in main.tf
terraform apply
```

#### Option 2: Manual Access Policy with Portal/CLI (Before Deployment)

If you prefer to grant access before deploying APIM:

```bash
# Create APIM first (you'll need the principal_id from a prior deployment or create identity separately)
# Then use Portal or CLI to grant Key Vault access
# Then run full terraform apply with all named values
```

#### Option 3: Automated with Terraform (Advanced)

Uncomment the `azurerm_key_vault_access_policy` resource in `main.tf`. This creates a dependency that Terraform can handle, but may still require the two-step deployment for initial setup.

## Usage

```terraform
module "apim_with_named_values" {
  source = "../../"

  name                = "apim-namedvalues-example"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.this.name
  publisher_name      = "Contoso"
  publisher_email     = "publisher@contoso.com"
  sku_name            = "Developer_1"

  # Named Values Configuration
  named_values = {
    # Plain text configuration value
    "api-base-url" = {
      display_name = "API Base URL"
      value        = "https://api.contoso.com"
      tags         = ["configuration", "url"]
    }

    # Secret value (encrypted at rest in APIM)
    "api-key" = {
      display_name = "Third Party API Key"
      value        = "my-secret-api-key-value"
      secret       = true
      tags         = ["secret", "api", "production"]
    }

    # Key Vault backed secret
    "database-connection-string" = {
      display_name = "Database Connection String"
      secret       = true
      value_from_key_vault = {
        secret_id = "https://myvault.vault.azure.net/secrets/db-connection/abc123"
      }
      tags = ["database", "secret"]
    }

    # Environment indicator
    "environment" = {
      display_name = "Environment"
      value        = "development"
      tags         = ["environment"]
    }
  }

  # Enable managed identity for Key Vault access
  managed_identities = {
    system_assigned = true
  }

  enable_telemetry = true
}
```

## Using Named Values in Policies

Named values can be referenced in API Management policies using the syntax: `{{named-value-key}}`

Example policy:

```xml
<policies>
  <inbound>
    <base />
    <set-variable name="apiKey" value="{{api-key}}" />
    <set-backend-service base-url="{{api-base-url}}" />
    <set-header name="Environment" exists-action="override">
      <value>{{environment}}</value>
    </set-header>
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
```

## Key Vault Integration Requirements

When using Key Vault integration:

1. **Managed Identity**: APIM must have a managed identity (system-assigned or user-assigned)
2. **Key Vault Access Policy**: Grant the identity "Get" and "List" permissions on secrets
3. **Secret ID Format**: Use versionless or versioned secret identifier

### Required Permissions

The APIM managed identity needs the following Key Vault permissions:

- **Secret Permissions**: `Get`, `List`

### Azure CLI Example

```bash
# Grant access to APIM system-assigned identity
az keyvault set-policy \
  --name <key-vault-name> \
  --object-id <apim-identity-principal-id> \
  --secret-permissions get list
```

### Terraform Example (Optional)

If you choose to manage the access policy with Terraform, uncomment this resource in `main.tf`:

```terraform
resource "azurerm_key_vault_access_policy" "apim" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = module.apim.workspace_identity.principal_id

  secret_permissions = [
    "Get",
    "List",
  ]

  depends_on = [module.apim]
}
```

**Note**: Using Terraform for access policy may require two-step deployment (see above).

## Tags and Filtering

Named values can be tagged for organizational purposes. These tags can be used to filter named values in the Azure Portal and through the API Management REST API.

Common tag patterns:

- **Environment**: `production`, `staging`, `development`
- **Type**: `configuration`, `secret`, `url`, `api-key`
- **Service**: `database`, `api`, `storage`

<!-- BEGIN_TF_DOCS -->
<!-- This section will be auto-generated by terraform-docs -->
<!-- END_TF_DOCS -->
