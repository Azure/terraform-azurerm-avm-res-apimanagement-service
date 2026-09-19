output "name" {
  description = "The name of the API version set."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The resource ID of the API version set."
  value       = azapi_resource.this.id
}
