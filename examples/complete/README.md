# Complete API Management Example

This comprehensive example demonstrates all currently implemented features of the Azure API Management Terraform module, including Named Values, API Version Sets, APIs with Operations, and Policies.

## Features

### Named Values
- Plain text configuration values
- Secret values (encrypted at rest in APIM)
- Key Vault-backed secrets with managed identity integration
- Tagged values for organization and filtering

### API Version Sets
- **Segment versioning** (URL path-based: `/v1/products`)
- **Header versioning** (version in HTTP header)
- Query parameter versioning support

### APIs with Operations
- Multiple API versions demonstrating versioning strategies
- Full CRUD operations (GET, POST, PUT, DELETE)
- Request and response schemas
- Query parameters and path parameters
- Multiple APIs showing different patterns

### Policies
- **API-level policies** (applied to all operations in an API)
  - Rate limiting
  - Caching
  - Header manipulation
- **Operation-level policies** (specific to individual operations)
  - Content validation
  - Request transformation

### Security & Integration
- System-assigned managed identity
- Key Vault integration for secure secret storage
- Subscription-based API access

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

## What This Example Demonstrates

This example shows a real-world API Management setup with:

1. **Products API** (v1 and v2) using URL segment versioning
2. **Orders API** (v1) using HTTP header versioning
3. **Named Values** for configuration and secrets
4. **Rate limiting** and caching policies
5. **Content validation** on specific operations
6. **Key Vault integration** for secure secret storage

## Usage

```terraform
module "apim" {
  source = "Azure/avm-res-apimanagement-service/azurerm"

  name                = "apim-complete-example"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.this.name
  publisher_name      = "Contoso"
  publisher_email     = "admin@contoso.com"
  sku_name            = "Developer_1"

  # Named Values
  named_values = {
    "api-base-url" = {
      display_name = "API-Base-URL"
      value        = "https://api.contoso.com/v1"
    }
    "api-key" = {
      display_name = "Third-Party-API-Key"
      value        = "secret-value"
      secret       = true
    }
  }

  # API Version Sets
  api_version_sets = {
    "products-api" = {
      display_name      = "Products API"
      versioning_scheme = "Segment"
      description       = "Product management API"
    }
  }

  # APIs with Operations
  apis = {
    "products-v1" = {
      display_name         = "Products API v1"
      path                 = "products"
      protocols            = ["https"]
      api_version          = "v1"
      api_version_set_name = "products-api"
      
      policy = {
        xml_content = <<-XML
          <policies>
            <inbound>
              <rate-limit calls="100" renewal-period="60" />
            </inbound>
          </policies>
        XML
      }
      
      operations = {
        "list-products" = {
          display_name = "List Products"
          method       = "GET"
          url_template = "/"
        }
        "create-product" = {
          display_name = "Create Product"
          method       = "POST"
          url_template = "/"
        }
      }
    }
  }

  managed_identities = {
    system_assigned = true
  }
}
```

## Deployed Resources

This example creates:

- **1 API Management Service** (Developer tier)
- **2 API Version Sets** (products-api, orders-api)
- **3 APIs** (products-v1, products-v2, orders-v1)
- **9 API Operations** across all APIs
- **6 Named Values** (including 1 Key Vault-backed)
- **3 API-Level Policies**
- **1 Operation-Level Policy**
- **1 Key Vault** (for secret storage)
- **1 System-Assigned Managed Identity**

## API Structure

### Products API (Segment Versioning)

**Version 1** (`/products/v1/`)
- `GET /` - List all products
- `GET /{productId}` - Get product by ID
- `POST /` - Create new product (with content validation policy)
- `PUT /{productId}` - Update product
- `DELETE /{productId}` - Delete product

**Version 2** (`/products/v2/`)
- `GET /` - List products with pagination and filtering
- `GET /search` - Search products (new in v2)

**Policy Features:**
- Rate limiting: 100 calls/min (v1), 200 calls/min (v2)
- Response caching (v1 only)
- Content validation on POST operations

### Orders API (Header Versioning)

**Version 1** (Header: `Api-Version: v1`)
- `GET /orders` - List orders
- `POST /orders` - Create order

**Access:** Requires `Api-Version` header set to `v1`

## Testing the APIs

### Using Azure Portal

1. Navigate to your API Management instance
2. Go to "APIs" section
3. Select an API (e.g., "Products API v1")
4. Click "Test" tab
5. Try operations like "List Products"

### Using curl

```bash
# Get APIM gateway URL
GATEWAY_URL=$(terraform output -raw apim_gateway_url)

# List products (v1 - segment versioning)
curl "${GATEWAY_URL}/products/v1/" \
  -H "Ocp-Apim-Subscription-Key: YOUR_SUBSCRIPTION_KEY"

# List products (v2 with pagination)
curl "${GATEWAY_URL}/products/v2/?page=1&pageSize=10" \
  -H "Ocp-Apim-Subscription-Key: YOUR_SUBSCRIPTION_KEY"

# List orders (header versioning)
curl "${GATEWAY_URL}/orders/" \
  -H "Api-Version: v1" \
  -H "Ocp-Apim-Subscription-Key: YOUR_SUBSCRIPTION_KEY"
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
