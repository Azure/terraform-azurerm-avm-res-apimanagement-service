# Manual Testing Guide - API Management Module

This guide provides step-by-step instructions for manually testing the implemented phases of the API Management Terraform module.

## Prerequisites

Before you begin testing, ensure you have:

- [ ] Azure subscription with appropriate permissions
- [ ] Azure CLI installed and authenticated (`az login`)
- [ ] Terraform >= 1.9 installed
- [ ] Access to create Azure API Management instances
- [ ] (Optional) Key Vault for testing Named Values integration

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

## Phase 2: Named Values Testing

### Test Scenario 1: Basic Named Values

**Location**: `examples/named_values/`

#### Steps to Deploy

```bash
cd examples/named_values/

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Note: This will take 30-45 minutes for APIM to provision
```

#### What to Verify

**In Terminal:**
1. ✅ Terraform apply completes without errors
2. ✅ Named values are created successfully
3. ✅ Outputs show named value IDs and names

```bash
# Check outputs
terraform output

# Should see:
# - named_value_ids
# - named_values
# - apim_gateway_url
# - resource_id
```

**In Azure Portal:**

1. Navigate to **API Management services**
2. Open your newly created APIM instance
3. Go to **APIs** → **Named values** in the left menu

**Verify Plain Text Named Values:**
- [ ] `config-value` exists with display name "Configuration Value"
- [ ] Value is visible (not secret)
- [ ] Tags include "environment" and "config"

**Verify Secret Named Values:**
- [ ] `api-key` exists with display name "External API Key"
- [ ] Value is hidden (shows as `***`)
- [ ] Tags include "production" and "api"

**Verify Key Vault Integration:**
- [ ] `database-connection-string` exists
- [ ] Shows as Key Vault reference
- [ ] Identity is configured (check managed identity)

#### Test Key Vault Integration

```bash
# Get the Key Vault name from outputs
KV_NAME=$(terraform output -raw key_vault_name)

# Verify secret exists in Key Vault
az keyvault secret show --vault-name $KV_NAME --name db-connection-string

# Check APIM identity has access
APIM_PRINCIPAL_ID=$(terraform output -json workspace_identity | jq -r '.principal_id')
az role assignment list --assignee $APIM_PRINCIPAL_ID --scope "/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.KeyVault/vaults/$KV_NAME"
```

#### Cleanup

```bash
# Destroy resources (takes 30-45 minutes)
terraform destroy

# Or delete resource group directly
az group delete --name <resource-group-name> --yes --no-wait
```

---

## Phase 3: APIs Testing

### Test Scenario 2: Basic APIs with Operations

**Location**: `examples/apis_basic/`

#### Steps to Deploy

```bash
cd examples/apis_basic/

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

#### What to Verify

**In Terminal:**

```bash
# Check outputs
terraform output

# Get the gateway URL
GATEWAY_URL=$(terraform output -raw apim_gateway_url)
echo "Gateway URL: $GATEWAY_URL"

# Get API IDs
terraform output api_ids

# Get API operations
terraform output api_operations
```

**In Azure Portal:**

1. Navigate to your APIM instance
2. Go to **APIs** in the left menu

**Verify Petstore API:**
- [ ] API named "Petstore API" exists
- [ ] Path suffix is `/petstore`
- [ ] HTTPS protocol is enabled
- [ ] Backend URL is `https://petstore.swagger.io/v2`

**Verify Operations (under Petstore API):**
- [ ] `GET /pets` - Get all pets
- [ ] `GET /pets/{petId}` - Get pet by ID
- [ ] `POST /pets` - Create a new pet
- [ ] `PUT /pets/{petId}` - Update an existing pet
- [ ] `DELETE /pets/{petId}` - Delete a pet

**Verify Weather API:**
- [ ] API named "Weather API" exists
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
2. **Update examples** if any improvements identified
3. **Proceed to Phase 4** (Products) after validation
4. **Consider automated testing** for regression prevention

---

## Notes

- Keep APIM instances running between tests to save time
- Use `terraform state` commands to inspect resource state
- Enable APIM logging for troubleshooting
- Consider costs - APIM Developer tier costs ~$50/month (pro-rated)
- Clean up resources after testing to avoid unnecessary charges
