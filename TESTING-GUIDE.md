# Manual Testing Guide - API Management Module

This guide provides step-by-step instructions for manually testing the comprehensive API Management Terraform module implementation, including Named Values, API Version Sets, APIs with Operations, Policies (API-level, operation-level, and service-level), Products, and Subscriptions.

## Prerequisites

Before you begin testing, ensure you have:

- [ ] Azure subscription with appropriate permissions (Contributor or Owner)
- [ ] Azure CLI installed and authenticated (`az login`)
- [ ] Terraform >= 1.9 installed
- [ ] Access to create Azure API Management instances (can create in East US region)
- [ ] Key Vault permissions for testing Named Values integration
- [ ] At least 45-60 minutes for APIM provisioning (Developer tier)

## Testing Environment Setup

### 1. Authenticate with Azure

```bash
# Login to Azure
az login

# Set your subscription
az account set --subscription "<your-subscription-id>"

# Verify your account
az account show
```

### 2. Clone and Navigate to Repository

```bash
cd /Users/pnagarajan/projects/msft/terraform-azurerm-avm-res-apimanagement-service
git checkout 35-add-core-api-management
```

## Comprehensive Example Testing

### Overview

The `examples/complete/` directory contains a comprehensive example that demonstrates all implemented features:

- ✅ **6 Named Values** (plain text, secret, Key Vault-backed)
- ✅ **2 API Version Sets** (Segment and Header versioning)
- ✅ **3 APIs** with 9 Operations total
- ✅ **4 Policies** (3 API-level + 1 operation-level + 1 service-level)
- ✅ **3 Products** (Starter, Premium, Unlimited)
- ✅ **4 Subscriptions** (product-scoped, API-scoped, all-APIs-scoped)

This single example tests the complete workflow and integration between all components.

### Test Scenario: Complete API Management Setup

**Location**: `examples/complete/`

#### Pre-Deployment Preparation

```bash
cd examples/complete/

# Review the configuration
cat main.tf

# Review variables that will be used
cat variables.tf
```

**Important Note**: The example includes Key Vault integration. For first-time deployment, you have two options:

**Option 1: Two-Step Deployment (Recommended)**
1. Comment out the Key Vault-backed named value in `main.tf` (line with `database-connection-string`)
2. Deploy APIM first
3. Grant Key Vault access
4. Uncomment the Key Vault named value
5. Deploy again

**Option 2: Pre-configure Key Vault Access**
- Manually create Key Vault access policy before deployment
- See the Key Vault Access Policy Management section in the example README

#### Steps to Deploy

```bash
cd /Users/pnagarajan/projects/msft/terraform-azurerm-avm-res-apimanagement-service/examples/complete

# Initialize Terraform
terraform init

# Review the plan (check what will be created)
terraform plan

# Apply the configuration
# Note: This will take 45-60 minutes for APIM Developer tier to provision
terraform apply

# Save important outputs
terraform output apim_gateway_url > gateway_url.txt
terraform output apim_identity_principal_id > identity_id.txt
```

**Expected Duration**: 45-60 minutes for initial deployment

#### Verify Deployment in Terminal

After deployment completes:

```bash
# Check all outputs
terraform output

# Get gateway URL (you'll need this for testing)
GATEWAY_URL=$(terraform output -raw apim_gateway_url)
echo "Gateway URL: $GATEWAY_URL"

# Get APIM identity for Key Vault access (if needed)
terraform output apim_identity_principal_id

# View created resources summary
terraform output products
terraform output product_ids
```

**Expected Outputs:**
- `apim_gateway_url` - The API gateway URL
- `named_values` - Details of all 6 named values
- `products` - Details of 3 products (Starter, Premium, Unlimited)
- `product_ids` - Map of product IDs
- `subscriptions` - Subscription details (sensitive, use `terraform output -json subscriptions`)
- `policy` - Service-level policy details

---

### Step-by-Step Verification in Azure Portal

#### 1. Verify Named Values

Navigate to: **API Management services** → Your APIM instance → **APIs** → **Named values**

**Plain Text Named Values:**
- [ ] `api-base-url` - Configuration value, visible
- [ ] `api-timeout` - Numeric value (30), visible
- [ ] `environment` - "development", visible

**Secret Named Values:**
- [ ] `external-api-key` - Secret value, hidden (shows `***`)
- [ ] `internal-token` - Secret value, hidden

**Key Vault-Backed Named Values:**
- [ ] `database-connection-string` - Shows Key Vault icon/reference
- [ ] Click on it to verify it references Key Vault secret

#### 2. Verify API Version Sets

Navigate to: **APIs** → **Version sets**

- [ ] `products-api` version set exists
  - Display name: "Products API"
  - Versioning scheme: Segment
- [ ] `orders-api` version set exists
  - Display name: "Orders API"
  - Versioning scheme: Header
  - Header name: "Api-Version"

#### 3. Verify APIs and Operations

Navigate to: **APIs** → **APIs** (left menu)

**Products API v1:**
- [ ] API exists with path `/products/v1`
- [ ] Linked to `products-api` version set
- [ ] Operations: GET /, GET /{productId}, POST /, PUT /{productId}, DELETE /{productId}
- [ ] POST operation has content validation policy (check in Design tab)

**Products API v2:**
- [ ] API exists with path `/products/v2`
- [ ] Linked to same version set as v1
- [ ] Operations: GET /, GET /search
- [ ] Higher rate limits than v1

**Orders API v1:**
- [ ] API exists with path `/orders`
- [ ] Uses Header versioning (requires `Api-Version: v1` header)
- [ ] Operations: GET /orders, POST /orders

#### 4. Verify Policies

**API-Level Policies:**

For Products API v1:
- [ ] Navigate to Products API v1 → **All operations** → **Design** tab → **Inbound processing**
- [ ] Rate limit: 100 calls per minute
- [ ] Cache lookup and store (3600 seconds)

For Products API v2:
- [ ] Rate limit: 200 calls per minute (higher than v1)
- [ ] No caching (different from v1)

For Orders API v1:
- [ ] Header-based API version required
- [ ] Custom policies for order processing

**Operation-Level Policy:**

For Products API v1 → POST / (Create Product):
- [ ] Navigate to the POST operation → **Design** tab
- [ ] Validate request content policy present
- [ ] JSON schema validation configured

**Service-Level Policy:**

- [ ] Navigate to **APIs** → **All APIs** → **Design** tab → **Policies**
- [ ] Global CORS policy configured
- [ ] Allowed origins: `https://contoso.com`, `https://www.contoso.com`
- [ ] Security headers: X-Content-Type-Options, X-Frame-Options
- [ ] X-Powered-By and Server headers removed

#### 5. Verify Products

Navigate to: **Products** (left menu)

- [ ] **Starter Product**
  - Display name: "Starter"
  - Published: Yes
  - Requires subscription: Yes
  - APIs: Products v1, Orders v1
  - Groups: developers
  - No approval required

- [ ] **Premium Product**
  - Display name: "Premium"
  - Published: Yes
  - Requires approval: Yes
  - Subscription limit: 10
  - APIs: Products v2, Orders v1
  - Groups: developers
  - Terms of use present

- [ ] **Unlimited Product**
  - Display name: "Unlimited"
  - Published: Yes
  - Requires approval: Yes
  - APIs: All APIs (Products v1, v2, Orders v1)
  - Groups: administrators

#### 6. Verify Subscriptions

Navigate to: **Subscriptions** (left menu)

- [ ] **developer-starter-sub**
  - Display name: "Developer Starter Subscription"
  - Scope: Product (Starter)
  - State: Active
  - Tracing: Enabled

- [ ] **developer-premium-sub**
  - Display name: "Developer Premium Subscription"
  - Scope: Product (Premium)
  - State: Submitted (awaiting approval)
  - Tracing: Enabled

- [ ] **api-specific-sub**
  - Display name: "Products v1 API Subscription"
  - Scope: API (Products v1 only)
  - State: Active
  - Tracing: Disabled

- [ ] **all-apis-sub**
  - Display name: "All APIs Access"
  - Scope: All APIs
  - State: Active
  - Tracing: Enabled

---

### Functional Testing with curl

Now let's test the APIs functionally using curl commands.

#### Get Subscription Keys

```bash
# In Azure Portal, navigate to: Subscriptions
# Click on "developer-starter-sub" → Show/hide keys
# Copy the Primary key

# Or use built-in all-access subscription for testing
# Subscriptions → Built-in all-access subscription
```

Set your subscription key:
```bash
GATEWAY_URL=$(terraform output -raw apim_gateway_url)
SUBSCRIPTION_KEY="<your-subscription-key>"

echo "Gateway: $GATEWAY_URL"
echo "Key: $SUBSCRIPTION_KEY"
```

#### Test Products API v1 (Segment Versioning)

```bash
# List all products (should hit cache)
curl -i -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
     "${GATEWAY_URL}/products/v1/"

# Expected: HTTP 200, products list
# Check headers for X-Content-Type-Options, X-Frame-Options (from service policy)

# Get specific product
curl -i -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
     "${GATEWAY_URL}/products/v1/123"

# Create a product (has content validation)
curl -i -X POST \
     -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
     -H "Content-Type: application/json" \
     -d '{"name":"Test Product","price":99.99}' \
     "${GATEWAY_URL}/products/v1/"

# Expected: HTTP 200 or 201, product created
# Validation policy should check the JSON structure
```

#### Test Products API v2 (Higher Rate Limits)

```bash
# List products with pagination
curl -i -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
     "${GATEWAY_URL}/products/v2/?page=1&pageSize=10"

# Search products (new in v2)
curl -i -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
     "${GATEWAY_URL}/products/v2/search?q=laptop"

# Expected: HTTP 200, search results
```

#### Test Orders API v1 (Header Versioning)

```bash
# List orders (requires Api-Version header)
curl -i -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
     -H "Api-Version: v1" \
     "${GATEWAY_URL}/orders/orders"

# Expected: HTTP 200, orders list

# Without version header (should fail)
curl -i -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
     "${GATEWAY_URL}/orders/orders"

# Expected: HTTP 400 or error about missing version
```

#### Test Rate Limiting

```bash
# Send 150 requests rapidly to Products v1 (limit: 100/min)
echo "Testing rate limit (100 calls/min)..."
for i in {1..150}; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
           -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
           "${GATEWAY_URL}/products/v1/")
  echo "Request $i: HTTP $STATUS"

  if [ "$STATUS" == "429" ]; then
    echo "✅ Rate limit hit at request $i"
    break
  fi

  sleep 0.1
done

# Expected: First ~100 requests succeed, then HTTP 429 (Too Many Requests)
```

#### Test Caching

```bash
# First request (cache miss - slower, goes to backend)
echo "First request (cache miss):"
time curl -s -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
     "${GATEWAY_URL}/products/v1/" > /dev/null

# Second request (cache hit - faster)
echo "Second request (cache hit):"
time curl -s -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
     "${GATEWAY_URL}/products/v1/" > /dev/null

# Third request (cache hit - faster)
echo "Third request (cache hit):"
time curl -s -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
     "${GATEWAY_URL}/products/v1/" > /dev/null

# Expected: First request slower, subsequent requests much faster
```

#### Test CORS (Service-Level Policy)

```bash
# Test CORS preflight
curl -i -X OPTIONS \
     -H "Origin: https://contoso.com" \
     -H "Access-Control-Request-Method: GET" \
     "${GATEWAY_URL}/products/v1/"

# Expected: HTTP 200 with CORS headers
# - Access-Control-Allow-Origin: https://contoso.com
# - Access-Control-Allow-Methods: GET, POST, PUT, DELETE
```

#### Test Without Subscription Key

```bash
# Should fail with 401 Unauthorized
curl -i "${GATEWAY_URL}/products/v1/"

# Expected: HTTP 401 Unauthorized
# Message about missing subscription key
```

#### Test Product Subscriptions

If you have product-scoped subscriptions:

```bash
# Get subscription key for "developer-starter-sub" from Portal
STARTER_KEY="<starter-subscription-key>"

# Test with starter subscription (should work for Products v1 and Orders v1)
curl -i -H "Ocp-Apim-Subscription-Key: $STARTER_KEY" \
     "${GATEWAY_URL}/products/v1/"

# Try to access Products v2 (not included in Starter product - should fail)
curl -i -H "Ocp-Apim-Subscription-Key: $STARTER_KEY" \
     "${GATEWAY_URL}/products/v2/"

# Expected: Access denied or 403 Forbidden
```

---

### Key Vault Integration Testing

If you deployed with Key Vault integration:

```bash
# Get Key Vault name
KV_NAME=$(terraform output -raw key_vault_name)

# Verify secret exists
az keyvault secret show --vault-name $KV_NAME --name db-connection-string

# Check APIM managed identity has access
APIM_PRINCIPAL_ID=$(terraform output -raw apim_identity_principal_id)
echo "APIM Principal ID: $APIM_PRINCIPAL_ID"

# Check Key Vault access policies
az keyvault show --name $KV_NAME --query properties.accessPolicies

# Verify the named value in APIM references Key Vault
# Portal: Named values → database-connection-string → Should show Key Vault icon
```

---

### Advanced Testing

#### Test Policy Traces

1. In Azure Portal: **APIs** → Select an API → Select an operation
2. Go to **Test** tab
3. Add required headers (subscription key, etc.)
4. Click **Trace**
5. Click **Send**
6. View the **Trace** tab to see:
   - [ ] Inbound policies execution
   - [ ] Service-level policy execution
   - [ ] API-level policy execution
   - [ ] Operation-level policy execution (if applicable)
   - [ ] Backend call
   - [ ] Outbound policies execution
   - [ ] Response

#### Test Named Values in Policies

1. Edit one of the API policies to reference a named value
2. Add: `<set-header name="X-Environment" exists-action="override"><value>{{environment}}</value></set-header>`
3. Save policy
4. Test the API
5. Check response headers for `X-Environment: development`

#### Test Subscription Approval Workflow

1. Portal: **Products** → **Premium** → **Subscriptions**
2. Find "developer-premium-sub" with state "Submitted"
3. Click on it → **Approve** or **Reject**
4. Test API access with the subscription key before and after approval

---

### Cleanup

After testing is complete:

```bash
# Destroy all resources (takes 30-45 minutes)
cd /Users/pnagarajan/projects/msft/terraform-azurerm-avm-res-apimanagement-service/examples/complete

terraform destroy -auto-approve

# Or for faster cleanup, delete the resource group directly
RESOURCE_GROUP=$(terraform output -raw resource_group_name 2>/dev/null || echo "rg-complete-example")
az group delete --name $RESOURCE_GROUP --yes --no-wait

echo "Cleanup initiated. Resources will be deleted in background."
```

---

## Validation Checklist

Before considering testing complete, verify all features:

### Named Values
- [ ] Plain text named values visible in portal
- [ ] Secret named values encrypted (hidden)
- [ ] Key Vault integration works with managed identity
- [ ] Named values can be referenced in policies using `{{key}}`

### API Version Sets
- [ ] Segment versioning works (different URL paths)
- [ ] Header versioning works (requires Api-Version header)
- [ ] APIs correctly linked to version sets

### APIs and Operations
- [ ] All 3 APIs accessible via gateway URL
- [ ] 9 operations total across all APIs
- [ ] Template parameters work ({id}, {name}, etc.)
- [ ] Query parameters validated correctly

### Policies
- [ ] API-level policies apply to all operations
- [ ] Operation-level policies override API-level correctly
- [ ] Service-level policy applies globally (CORS, security headers)
- [ ] Rate limiting works as configured
- [ ] Caching improves response time
- [ ] Policy execution order correct (service → API → operation)

### Products
- [ ] 3 products created (Starter, Premium, Unlimited)
- [ ] Products linked to correct APIs
- [ ] Products linked to correct groups
- [ ] Approval workflow configured correctly

### Subscriptions
- [ ] Product-scoped subscriptions work
- [ ] API-scoped subscriptions work
- [ ] All-APIs subscriptions work
- [ ] Subscription keys provide access correctly
- [ ] Subscription states managed properly

### Integration
- [ ] Multiple features work together without conflicts
- [ ] Named values resolve in policies
- [ ] Subscription keys work across all scoped resources
- [ ] Security headers applied to all responses

---

## Common Issues and Troubleshooting

```bash

- [ ] Path suffix is `/weather`
- [ ] Operation: `GET /current` with query parameters

#### Test API Calls

```bash
# Get a subscription key
# Portal: APIs → Subscriptions → Built-in all-access subscription → Show/hide keys
SUBSCRIPTION_KEY="<your-subscription-key>"

# Test Petstore API - List pets
curl -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
     "${GATEWAY_URL}/petstore/pets"

# Test Petstore API - Get pet by ID
curl -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
     "${GATEWAY_URL}/petstore/pets/1"

# Test Weather API
curl -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
     "${GATEWAY_URL}/weather/current?city=Seattle&units=metric"

# Test without subscription key (should fail with 401)
curl -i "${GATEWAY_URL}/petstore/pets"
```

**Expected Results:**
- ✅ With subscription key: HTTP 200 (or backend-specific response)
- ✅ Without subscription key: HTTP 401 Unauthorized
- ✅ Invalid path: HTTP 404 Not Found

#### Inspect Operation Details in Portal

For each operation:
1. Click on the operation (e.g., `GET /pets`)
2. Go to **Test** tab
   - [ ] Can send test requests
   - [ ] Parameters are shown correctly
3. Go to **Design** tab
   - [ ] Request parameters are defined
   - [ ] Response codes are documented (200, 404, etc.)

#### Cleanup

```bash
terraform destroy
```

---

### Test Scenario 3: OpenAPI Import

**Location**: `examples/apis_openapi_import/`

#### Steps to Deploy

```bash
cd examples/apis_openapi_import/

terraform init
terraform plan
terraform apply
```

#### What to Verify

**In Azure Portal:**

**Verify Inline OpenAPI Import:**
- [ ] API "Petstore API (OpenAPI Inline)" exists at `/petstore-inline`
- [ ] Operations are auto-generated from spec:
  - [ ] `POST /pet` - Add a new pet
  - [ ] `GET /pet/{petId}` - Find pet by ID
- [ ] Request/response schemas are imported
- [ ] Path parameters are defined

**Verify URL-based OpenAPI Import:**
- [ ] API "Petstore API (OpenAPI URL)" exists at `/petstore-url`
- [ ] Operations match the remote specification
- [ ] Backend URL is configured

**Verify Swagger 2.0 Import:**
- [ ] API "Petstore API (Swagger 2.0)" exists at `/swagger-petstore`
- [ ] All operations are imported correctly

#### Test Imported APIs

```bash
GATEWAY_URL=$(terraform output -raw apim_gateway_url)
SUBSCRIPTION_KEY="<your-subscription-key>"

# Test inline import
curl -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
     "${GATEWAY_URL}/petstore-inline/pet/1"

# Test URL import
curl -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
     "${GATEWAY_URL}/petstore-url/pet/1"

# Test Swagger import
curl -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
     "${GATEWAY_URL}/swagger-petstore/pet/1"
```

**Compare APIs:**
- [ ] All three APIs have similar operations
- [ ] Schema definitions are present
- [ ] Documentation is generated from spec

#### Cleanup

```bash
terraform destroy
```

---

### Test Scenario 4: APIs with Policies

**Location**: `examples/apis_with_policies/`

#### Steps to Deploy

```bash
cd examples/apis_with_policies/

terraform init
terraform plan
terraform apply
```

#### What to Verify in Portal

**Rate Limited API:**
1. Navigate to API "Rate Limited API"
2. Click **All operations** → **Design** tab → **Policies**
3. **Verify Inbound Policy:**
   - [ ] `<rate-limit calls="100" renewal-period="60" />` present
   - [ ] `<quota calls="10000" renewal-period="604800" />` present
   - [ ] CORS configuration present

**Secure API:**
1. Navigate to "Secure API with JWT"
2. Check API-level policy:
   - [ ] `<validate-jwt>` section present
   - [ ] OpenID configuration URL specified
   - [ ] Header manipulation policies (`set-header`, `delete-header`)
3. Navigate to `POST /data` operation
4. Check operation-level policy:
   - [ ] Additional `<validate-content>` policy
   - [ ] Body transformation with timestamp

**Cached API:**
1. Navigate to "Cached API"
2. Check API-level policy:
   - [ ] `<cache-lookup>` in inbound
   - [ ] `<cache-store duration="3600">` in outbound
3. Check operation `GET /data/{id}`:
   - [ ] Operation-specific caching with vary-by parameter
   - [ ] Duration is 7200 seconds (2 hours)

**Transformation API:**
1. Navigate to "Transformation API"
2. Check policy:
   - [ ] `<xml-to-json>` in outbound section
   - [ ] Backend URL rewriting

#### Test Policies

**Test Rate Limiting:**

```bash
GATEWAY_URL=$(terraform output -raw apim_gateway_url)
SUBSCRIPTION_KEY="<your-subscription-key>"

# Send 150 requests rapidly (should hit rate limit at 100)
for i in {1..150}; do
  echo "Request $i"
  curl -s -w "\nHTTP Status: %{http_code}\n" \
       -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
       "${GATEWAY_URL}/rate-limited/data"
  sleep 0.1
done

# After ~100 requests, you should see HTTP 429 (Too Many Requests)
```

**Expected Results:**
- ✅ First ~100 requests: HTTP 200 (or backend status)
- ✅ After 100 requests: HTTP 429 with rate limit error message

**Test Caching:**

```bash
# First request (cache miss - slower)
time curl -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
          "${GATEWAY_URL}/cached/data/123"

# Second request (cache hit - faster)
time curl -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
          "${GATEWAY_URL}/cached/data/123"

# Different parameter (cache miss)
time curl -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
          "${GATEWAY_URL}/cached/data/456"
```

**Expected Results:**
- ✅ First request: Slower (goes to backend)
- ✅ Second request: Faster (served from cache)
- ✅ Check response headers for cache indicators

**Test JWT Validation (will fail without token):**

```bash
# Without JWT token (should fail with 401)
curl -i -H "Ocp-Apim-Subscription-Key: $SUBSCRIPTION_KEY" \
     "${GATEWAY_URL}/secure/data"

# Expected: HTTP 401 Unauthorized with JWT validation error
```

**Test in Portal - Policy Tester:**
1. Go to API → Operation → **Test** tab
2. Click **Send**
3. View **Trace** to see policy execution
4. **Verify:**
   - [ ] Inbound policies executed
   - [ ] Backend request made
   - [ ] Outbound policies executed
   - [ ] Response returned

#### Cleanup

```bash
terraform destroy
```

---

## Cross-Phase Integration Testing

### Test Complete Workflow

This tests multiple features working together.

#### Create Test Configuration

Create `test-integration/main.tf`:

```hcl
module "apim_integration_test" {
  source = "../../"

  location            = "East US"
  name                = "apim-integration-test"
  resource_group_name = azurerm_resource_group.test.name
  publisher_email     = "admin@example.com"
  publisher_name      = "Integration Test"
  sku_name            = "Developer_1"

  # Named values
  named_values = {
    "backend-url" = {
      display_name = "Backend URL"
      value        = "https://httpbin.org"
    }
    "api-version" = {
      display_name = "API Version"
      value        = "v1"
      tags         = ["config"]
    }
  }

  # API Version Set
  api_version_sets = {
    "test-api-versions" = {
      display_name        = "Test API Versions"
      versioning_scheme   = "Header"
      version_header_name = "Api-Version"
    }
  }

  # API with operations and policy
  apis = {
    "integration-api" = {
      display_name          = "Integration Test API"
      path                  = "test"
      api_version           = "v1"
      api_version_set_name  = "test-api-versions"
      subscription_required = true

      operations = {
        "test-get" = {
          display_name = "Test GET"
          method       = "GET"
          url_template = "/get"
        }
      }

      policy = {
        xml_content = <<XML
<policies>
  <inbound>
    <set-backend-service base-url="{{backend-url}}" />
    <rate-limit calls="10" renewal-period="60" />
  </inbound>
  <backend><base /></backend>
  <outbound><base /></outbound>
  <on-error><base /></on-error>
</policies>
XML
      }
    }
  }
}
```

#### Verify Integration

1. Deploy the integration test
2. **Verify Named Values are referenced in policy:**
   - Portal → API → Policy → Check `{{backend-url}}` is replaced
3. **Verify API Version Set:**
   - Portal → APIs → Version sets → Check "Test API Versions" exists
4. **Test API with versioning:**
   ```bash
   # With version header
   curl -H "Ocp-Apim-Subscription-Key: $KEY" \
        -H "Api-Version: v1" \
        "${GATEWAY_URL}/test/get"

   # Without version header (should fail or use default)
   curl -i -H "Ocp-Apim-Subscription-Key: $KEY" \
        "${GATEWAY_URL}/test/get"
   ```

---

## Common Issues and Troubleshooting

### Issue 1: Terraform Apply Fails with Authorization Error

**Error:** `Error: authorization failed`

**Solution:**
```bash
# Re-authenticate
az login
az account set --subscription "<your-subscription-id>"

# Check permissions
az role assignment list --assignee $(az account show --query user.name -o tsv)
```

### Issue 2: APIM Takes Too Long to Provision

**Expected:** 30-45 minutes for initial provisioning

**Workaround:**
- Use `Developer_1` SKU for faster testing (still ~20-30 min)
- Consider using `Consumption` tier (much faster, but limited features)
- Keep a persistent APIM instance and only update configurations

### Issue 3: Subscription Key Not Working

**Solution:**
1. Portal → Subscriptions → Check subscription state
2. Use built-in "all-access" subscription for testing
3. Verify key is copied correctly (no extra spaces)

### Issue 4: Named Values Not Resolving in Policies

**Solution:**
1. Check Named Value exists: Portal → Named values
2. Verify syntax: `{{named-value-key}}` (double curly braces)
3. Named value keys are case-sensitive

### Issue 5: Key Vault Integration Fails

**Solution:**
```bash
# Check managed identity
az apim show -n <apim-name> -g <rg> --query identity

# Verify Key Vault permissions
az keyvault show -n <kv-name> --query properties.accessPolicies

# Check secret ID format
# Should be: https://<vault>.vault.azure.net/secrets/<secret>/<version>
```

---

## Performance Testing

### Load Testing Rate Limits

Use Apache Bench or similar tool:

```bash
# Install Apache Bench
brew install httpd  # macOS

# Test rate limiting
ab -n 200 -c 10 \
   -H "Ocp-Apim-Subscription-Key: $KEY" \
   "${GATEWAY_URL}/rate-limited/data"

# Check how many requests succeeded vs rate limited
```

### Caching Performance

```bash
# Script to measure cache performance
for i in {1..10}; do
  echo "Request $i:"
  time curl -s -H "Ocp-Apim-Subscription-Key: $KEY" \
       "${GATEWAY_URL}/cached/data/123" > /dev/null
done

# First request should be slower, subsequent requests faster
```

---

## Validation Checklist

Before considering testing complete, verify:

### Phase 2: Named Values
- [ ] Plain text named values created successfully
- [ ] Secret named values are encrypted (hidden in portal)
- [ ] Key Vault integration works with managed identity
- [ ] Tags are applied correctly
- [ ] Named values appear in autocomplete when editing policies

### Phase 3: APIs
- [ ] APIs created with correct paths and protocols
- [ ] API operations are accessible via gateway URL
- [ ] OpenAPI import generates operations automatically
- [ ] Swagger 2.0 import works correctly
- [ ] Template parameters in URLs work ({id}, {name}, etc.)
- [ ] Query parameters are validated
- [ ] API-level policies are applied
- [ ] Operation-level policies override API-level policies correctly
- [ ] Rate limiting works as configured
- [ ] Caching improves response time
- [ ] JWT validation rejects unauthorized requests
- [ ] API versioning works with Header/Query/Segment schemes

### Integration
- [ ] Named values can be referenced in policies using `{{key}}`
- [ ] API Version Sets enable versioned APIs
- [ ] Multiple APIs coexist without conflicts
- [ ] Subscription keys work across all APIs
- [ ] Policies at different levels (service/API/operation) execute in correct order

---

## Documentation Links

- [Azure APIM Documentation](https://docs.microsoft.com/azure/api-management/)
- [APIM Policies Reference](https://docs.microsoft.com/azure/api-management/api-management-policies)
- [APIM Policy Expressions](https://docs.microsoft.com/azure/api-management/api-management-policy-expressions)
- [OpenAPI Specification](https://swagger.io/specification/)
- [Terraform azurerm Provider - APIM](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management)

---

## Next Steps After Testing

Once manual testing is complete:

1. **Document any issues found** in GitHub issues
2. **Proceed to Phase 8 (PR Preparation)** - Run AVM validation
3. **Update examples** if any improvements identified based on testing
4. **Consider automated testing** for regression prevention

---

## Testing Summary

This guide focused on the `examples/complete/` comprehensive example which demonstrates:

✅ **All 7 Completed Phases** tested in one deployment:
- Phase 1: Foundation & Planning
- Phase 2: Named Values (6 total: plain, secret, Key Vault-backed)
- Phase 2.5: API Version Sets (2 total: Segment and Header versioning)
- Phase 3: APIs with Operations (3 APIs, 9 operations, 4 policies)
- Phase 4: Products (3 products with different tiers)
- Phase 5: Subscriptions (4 subscriptions with different scopes)
- Phase 6: Service-Level Policy (global CORS and security headers)

✅ **Integration Testing** - All features work together:
- Named values referenced in policies
- APIs linked to version sets
- Products linked to APIs and groups
- Subscriptions scoped to products, APIs, or all APIs
- Policies applied at service, API, and operation levels

---

## Notes

- **Deployment Time**: 45-60 minutes for initial APIM provisioning (Developer tier)
- **Costs**: APIM Developer tier ~$50/month (pro-rated hourly)
- **Testing Duration**: Plan 2-3 hours for complete manual testing
- **Key Vault**: May require two-step deployment for first-time setup
- **Cleanup**: Always destroy resources after testing to avoid charges
- **Portal Access**: Azure Portal is essential for visual verification
- **Subscription Keys**: Can be found in Portal under Subscriptions section
