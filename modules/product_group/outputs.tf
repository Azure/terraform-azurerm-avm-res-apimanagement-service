output "name" {
  description = "The name (group name) of the product-group association."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The resource ID of the product-group association."
  value       = azapi_resource.this.id
}
