output "name" {
  description = "The name of the operation policy resource."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The resource ID of the operation policy."
  value       = azapi_resource.this.id
}
