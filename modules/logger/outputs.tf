output "name" {
  description = "The name of the logger."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The resource ID of the logger. Use it as a diagnostic `logger_id`."
  value       = azapi_resource.this.id
}
