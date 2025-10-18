# APIs with Policies Example

This example demonstrates how to implement various API policies in Azure API Management, including rate limiting, security, caching, and transformation policies.

## Features

This example includes four APIs demonstrating different policy scenarios:

### 1. Rate Limited API
- **Rate Limiting**: 100 calls per minute
- **Quota**: 10,000 calls per week
- **CORS**: Cross-origin resource sharing configuration
- Demonstrates traffic management and quota enforcement

### 2. Secure API with JWT
- **JWT Validation**: OAuth2/OpenID Connect token validation
- **Header Manipulation**: Add/remove HTTP headers
- **Operation-Level Policy**: Additional content validation for POST operations
- Demonstrates authentication and authorization

### 3. Cached API
- **Response Caching**: Cache responses for 1 hour (API-level)
- **Operation Caching**: Cache with vary-by parameter (2 hours)
- **Find and Replace**: Transform HTTP to HTTPS in responses
- Demonstrates performance optimization

### 4. Transformation API
- **Backend URL Rewriting**: Dynamic backend service selection
- **XML to JSON**: Convert legacy XML responses to JSON
- Demonstrates protocol and format transformation

## Policy Levels

Policies can be applied at different levels:

1. **Service-Level**: Applies to all APIs (configured separately)
2. **API-Level**: Applies to all operations in an API (shown in this example)
3. **Operation-Level**: Applies to specific operations (shown in `post-secure-data`)

## Common Policy Patterns

### Rate Limiting
```xml
<rate-limit calls="100" renewal-period="60" />
<quota calls="10000" renewal-period="604800" />
```

### JWT Validation
```xml
<validate-jwt header-name="Authorization">
  <openid-config url="https://..." />
  <required-claims>
    <claim name="aud"><value>api://myapi</value></claim>
  </required-claims>
</validate-jwt>
```

### Caching
```xml
<inbound>
  <cache-lookup vary-by-developer="false" />
</inbound>
<outbound>
  <cache-store duration="3600" />
</outbound>
```

### Header Manipulation
```xml
<set-header name="X-Custom-Header" exists-action="override">
  <value>@(context.Request.IpAddress)</value>
</set-header>
```

## Policy Execution Order

Policies execute in this order:

1. **Inbound**: Before request is sent to backend
2. **Backend**: When routing to backend (can change backend URL)
3. **Outbound**: After response received from backend
4. **On-Error**: If an error occurs in any section

## Usage

```hcl
apis = {
  "my-api" = {
    display_name = "My API"
    path         = "myapi"
    
    # API-level policy
    policy = {
      xml_content = <<XML
<policies>
  <inbound>
    <rate-limit calls="100" renewal-period="60" />
  </inbound>
  <backend><base /></backend>
  <outbound><base /></outbound>
  <on-error><base /></on-error>
</policies>
XML
    }
    
    operations = {
      "my-operation" = {
        # Operation-level policy
        policy = {
          xml_content = <<XML
<policies>
  <inbound>
    <cache-lookup />
  </inbound>
  ...
</policies>
XML
        }
      }
    }
  }
}
```

## Testing Policies

```bash
GATEWAY_URL=$(terraform output -raw apim_gateway_url)

# Test rate limiting (run multiple times quickly)
for i in {1..150}; do
  curl -H "Ocp-Apim-Subscription-Key: <key>" "${GATEWAY_URL}/rate-limited/data"
done

# Test JWT validation (should fail without token)
curl -H "Ocp-Apim-Subscription-Key: <key>" "${GATEWAY_URL}/secure/data"

# Test with JWT token
curl -H "Ocp-Apim-Subscription-Key: <key>" \
     -H "Authorization: Bearer <jwt-token>" \
     "${GATEWAY_URL}/secure/data"

# Test caching (first call slow, subsequent calls fast)
curl -H "Ocp-Apim-Subscription-Key: <key>" "${GATEWAY_URL}/cached/data/123"
```

## Policy Expressions

Policies support C# expressions for dynamic behavior:

```xml
<set-header name="X-Timestamp">
  <value>@(DateTime.UtcNow.ToString("o"))</value>
</set-header>

<set-body>@{
  var body = context.Request.Body.As<JObject>();
  body["processed"] = true;
  return body.ToString();
}</set-body>
```

## Best Practices

1. Always include `<base />` to inherit parent policies
2. Use operation-level policies for operation-specific logic
3. Cache frequently accessed, rarely changing data
4. Validate JWT tokens at the gateway for security
5. Use rate limiting to protect backend services
6. Remove unnecessary headers in outbound policies
7. Test policies thoroughly in non-production environments

## Notes

- Policy XML must be well-formed and valid
- Policy expressions use C# syntax
- Caching requires Redis cache in Premium tier (or internal cache in other tiers)
- JWT validation requires network access to OpenID configuration endpoint
