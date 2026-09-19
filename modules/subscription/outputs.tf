output "name" {
  description = "The name (subscription identifier) of the subscription."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The resource ID of the subscription."
  value       = azapi_resource.this.id
}
