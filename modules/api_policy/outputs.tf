output "name" {
  description = "The name of the API policy resource."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The resource ID of the API policy."
  value       = azapi_resource.this.id
}
