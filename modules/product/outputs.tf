output "name" {
  description = "The name (product identifier) of the product."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The resource ID of the product."
  value       = azapi_resource.this.id
}
