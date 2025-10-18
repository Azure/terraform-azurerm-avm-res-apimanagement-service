# Basic APIs Example

This example demonstrates how to create basic APIs with operations in Azure API Management using the AVM Terraform module.

## Features

This example includes:

- **Petstore API**: A comprehensive REST API with full CRUD operations
  - GET /pets - List all pets
  - GET /pets/{petId} - Get a specific pet by ID
  - POST /pets - Create a new pet
  - PUT /pets/{petId} - Update an existing pet
  - DELETE /pets/{petId} - Delete a pet
- **Weather API**: A simple API demonstrating query parameters
  - GET /current - Get current weather with city and units parameters

## API Operations Features

The example demonstrates:

1. **URL Templates**: Path-based routing with parameters
2. **HTTP Methods**: GET, POST, PUT, DELETE operations
3. **Template Parameters**: Path parameters like `{petId}`
4. **Query Parameters**: Optional and required query string parameters with validation
5. **Request/Response Definitions**: Structured request and response schemas
6. **Response Status Codes**: Multiple status codes per operation (200, 201, 204, 404)
7. **Content Types**: JSON request and response representations
8. **Sample Data**: Example request/response payloads

## Usage

```hcl
module "apim" {
  source = "Azure/avm-res-apimanagement-service/azurerm"
  
  apis = {
    "petstore-api" = {
      display_name = "Petstore API"
      path         = "petstore"
      protocols    = ["https"]
      service_url  = "https://petstore.swagger.io/v2"
      
      operations = {
        "get-pets" = {
          display_name = "Get all pets"
          method       = "GET"
          url_template = "/pets"
        }
      }
    }
  }
}
```

## Accessing the APIs

After deployment, you can access the APIs at:

```
https://<apim-name>.azure-api.net/petstore/pets
https://<apim-name>.azure-api.net/weather/current?city=Seattle&units=metric
```

## Testing with curl

```bash
# Get gateway URL
GATEWAY_URL=$(terraform output -raw apim_gateway_url)

# List all pets
curl -H "Ocp-Apim-Subscription-Key: <your-subscription-key>" \
  "${GATEWAY_URL}/petstore/pets"

# Get a specific pet
curl -H "Ocp-Apim-Subscription-Key: <your-subscription-key>" \
  "${GATEWAY_URL}/petstore/pets/1"

# Get current weather
curl -H "Ocp-Apim-Subscription-Key: <your-subscription-key>" \
  "${GATEWAY_URL}/weather/current?city=Seattle&units=metric"
```

## Notes

- All APIs require a subscription key by default
- The backend service URLs point to example services
- Response samples are provided for documentation purposes
