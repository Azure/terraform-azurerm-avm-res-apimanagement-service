output "display_name" {
  description = "The operation display name."
  value       = try(azapi_resource.this.output.properties.displayName, null)
}

output "method" {
  description = "The HTTP method of the operation."
  value       = try(azapi_resource.this.output.properties.method, null)
}

output "name" {
  description = "The operation identifier (ARM resource name)."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The resource ID of the operation."
  value       = azapi_resource.this.id
}

output "url_template" {
  description = "The URL template of the operation."
  value       = try(azapi_resource.this.output.properties.urlTemplate, null)
}
