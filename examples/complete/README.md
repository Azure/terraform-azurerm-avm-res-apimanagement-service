# Complete API Management Example

This example demonstrates the core features of the Azure API Management Terraform module in a simple, easy-to-understand configuration.

## What This Example Shows

- **APIs with Operations** - Single Echo API with one GET operation
- **Products** - Two product tiers (Starter, Premium) demonstrating access control
- **Subscriptions** - Subscription management for product access with keys
- **Named Values** - Configuration and secret management
- **API Policies** - Rate limiting and header manipulation

## Key Concepts

### APIs

The example includes a simple **Echo API** (`/echo/resource`) that demonstrates:

- Basic API creation with a single operation
- Subscription requirement enforcement
- Connection to a backend service

### Products
Products are API packages with different access tiers:

| Product | Approval Required | Subscription Limit | Description |
|---------|------------------|-------------------|-------------|
| **Starter** | No | Unlimited | Basic API access for developers |
| **Premium** | Yes | 10 | Premium access with higher rate limits |

Both products include the same Echo API but allow different access policies.

### Subscriptions

Subscriptions provide access keys to consume products:

1. **Starter Subscription** - Active, ready-to-use
2. **Premium Subscription** - Submitted state, awaiting approval

Subscriptions link to products, allowing controlled API access.

### Named Values

Secure configuration storage (like environment variables):

- `backend-url` - Plain text configuration value
- `api-key` - Secret value (encrypted at rest)
- `environment` - Environment indicator

Named values can be referenced in policies using `{{named-value-key}}` syntax.

### Policies

The Echo API includes a simple policy demonstrating:

```xml
<policies>
  <inbound>
    <rate-limit calls="100" renewal-period="60" />
    <set-header name="X-API-Name" exists-action="override">
      <value>Echo API</value>
    </set-header>
  </inbound>
  <outbound>
    <set-header name="X-Powered-By" exists-action="delete" />
  </outbound>
</policies>
```

This shows rate limiting and header manipulation.

## Deployed Resources

- 1 API Management Service (Developer_1 tier)
- 1 API with 1 operation
- 2 Products
- 2 Subscriptions
- 3 Named Values
- 1 API-level policy
- System-assigned managed identity

## Configuration

### Required Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `subscription_id` | Required | Azure subscription ID |
| `enable_telemetry` | `true` | Enable AVM telemetry collection |

### Using terraform.tfvars

```hcl
subscription_id = "your-subscription-id"
enable_telemetry = true
```

## Testing the API

### Get the Gateway URL

```bash
terraform output apim_gateway_url
```

### Test with curl

```bash
# Get subscription key from Azure Portal
SUBSCRIPTION_KEY="your-subscription-key"
GATEWAY_URL=$(terraform output -raw apim_gateway_url)

# Call the Echo API
curl "${GATEWAY_URL}/echo/resource" \
  -H "Ocp-Apim-Subscription-Key: ${SUBSCRIPTION_KEY}"
```

### Using Azure Portal

1. Go to your API Management instance
2. Select "APIs" → "Echo API"
3. Click "Test" tab
4. Select "Get Resource" operation
5. Click "Send"

## Getting Subscription Keys

1. Navigate to your APIM instance in Azure Portal
2. Go to "Products" section
3. Select "Starter" or "Premium"
4. Click "Subscriptions" tab
5. Copy the Primary or Secondary key

For Premium subscriptions, you may need to approve the subscription first in the "Subscriptions" section.

## Understanding Products vs Subscriptions

### Products Explained

**What**: API packages with policies and access control

**How**: Group APIs together with specific configurations

**In Example**: Starter (basic) and Premium (approval required) tiers

### Subscriptions Explained

**What**: Access keys to consume a product

**How**: User/app subscribes to a product to get API keys

**In Example**: Each product has a subscription that generates keys

**Flow**: User subscribes to Product → Gets Subscription Key → Uses key to call APIs in that product

## API Response Example

The Echo API returns request information:

```json
{
  "url": "https://apim-xxxx.azure-api.net/echo/resource",
  "method": "GET",
  "headers": {
    "Host": "apim-xxxx.azure-api.net",
    "Ocp-Apim-Subscription-Key": "xxxxx",
    "User-Agent": "curl/7.x.x"
  },
  "query": {}
}
```

## Expanding This Example

### Adding More Operations

Add more entries under `operations` in the Echo API definition:

```hcl
operations = {
  "get-resource" = { ... }
  "post-resource" = {
    display_name = "Post Resource"
    method       = "POST"
    url_template = "/resource"
  }
}
```

### Adding More APIs

Add new API entries under the `apis` block:

```hcl
apis = {
  "echo-api" = { ... }
  "another-api" = {
    display_name = "Another API"
    path         = "another"
    ...
  }
}
```

### Adding API Versioning

This can be demonstrated in a separate example using API version sets.

## Backend Service

The example uses the Azure APIM Echo API service (`http://echoapi.cloudapp.net/api`) as the backend. This is a test service provided by Microsoft for development and testing purposes.

## Notes

- **Developer Tier**: Uses the Developer tier which is suitable for development/testing but not for production
- **Random Region**: The resource group is deployed to a random Azure region for variety
- **Naming**: Uses Azure CAF (Cloud Adoption Framework) compliant naming conventions
- **Identity**: System-assigned managed identity is enabled for future integrations

## Next Steps

1. Deploy the module: `terraform apply`
2. Get the gateway URL: `terraform output apim_gateway_url`
3. Get subscription keys from the Azure Portal
4. Test APIs using the gateway URL and subscription keys
5. Explore the APIM Portal to manage APIs, products, and subscriptions

## References

- [Azure API Management Documentation](https://learn.microsoft.com/azure/api-management/)
- [APIM Policies](https://learn.microsoft.com/azure/api-management/api-management-policies)
- [Terraform Azure Provider - APIM](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management)
