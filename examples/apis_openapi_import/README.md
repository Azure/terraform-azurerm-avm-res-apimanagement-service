# OpenAPI Import Example

This example demonstrates how to import APIs from OpenAPI and Swagger specifications into Azure API Management.

## Features

This example shows three different import methods:

1. **Inline OpenAPI JSON**: Import from an OpenAPI 3.0 specification defined inline in Terraform
2. **OpenAPI URL**: Import from a remote OpenAPI specification URL
3. **Swagger 2.0 URL**: Import from a Swagger 2.0 specification

## Supported Import Formats

The module supports the following import formats:

- `openapi` - OpenAPI 3.0 specification (YAML or JSON)
- `openapi+json` - OpenAPI 3.0 JSON specification (inline)
- `openapi-link` - OpenAPI 3.0 specification from URL
- `openapi+json-link` - OpenAPI 3.0 JSON specification from URL
- `swagger-json` - Swagger 2.0 JSON specification (inline)
- `swagger-link-json` - Swagger 2.0 JSON specification from URL
- `wadl-xml` - WADL specification
- `wadl-link-json` - WADL specification from URL
- `wsdl` - WSDL specification (for SOAP APIs)
- `wsdl-link` - WSDL specification from URL

## Usage

### Import from Inline OpenAPI JSON

```hcl
apis = {
  "my-api" = {
    display_name = "My API"
    path         = "myapi"
    
    import = {
      content_format = "openapi+json"
      content_value  = jsonencode({
        openapi = "3.0.0"
        info    = { title = "My API", version = "1.0.0" }
        paths   = { ... }
      })
    }
  }
}
```

### Import from URL

```hcl
apis = {
  "my-api" = {
    display_name = "My API"
    path         = "myapi"
    
    import = {
      content_format = "openapi-link"
      content_value  = "https://example.com/openapi.json"
    }
  }
}
```

## Benefits of OpenAPI Import

- **Automatic Operation Generation**: All operations are automatically created from the specification
- **Schema Validation**: Request/response schemas are imported and enforced
- **Documentation**: API documentation is generated from the specification
- **Consistency**: Backend API contract matches the APIM gateway contract

## Testing

After deployment, access the imported APIs:

```bash
# Get gateway URL
GATEWAY_URL=$(terraform output -raw apim_gateway_url)

# Test the inline OpenAPI import
curl -H "Ocp-Apim-Subscription-Key: <your-key>" \
  "${GATEWAY_URL}/petstore-inline/pet/1"

# Test the URL-based OpenAPI import
curl -H "Ocp-Apim-Subscription-Key: <your-key>" \
  "${GATEWAY_URL}/petstore-url/pet/1"
```

## Notes

- Operations are automatically created when importing from OpenAPI/Swagger
- The import process validates the specification syntax
- Imported APIs can be modified after creation
- Re-importing updates the API definition
