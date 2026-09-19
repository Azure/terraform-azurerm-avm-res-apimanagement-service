output "name" {
  description = "The name (API name) of the product-API association."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The resource ID of the product-API association."
  value       = azapi_resource.this.id
}
