output "name" {
  description = "The name (API name) of the product-API association."
  value       = var.name
}

output "resource_id" {
  description = "The resource ID of the product-API association."
  value       = azapi_resource_action.associate.id
}
