output "enabled" {
  description = "Whether direct tenant access is enabled."
  value       = var.enabled
}

output "resource_id" {
  description = "The resource ID of the tenant access setting."
  value       = local.resource_id
}

output "tenant_id" {
  description = "The tenant access identifier exposed as `tenant_id` by the root module."
  value       = try(azapi_update_resource.this.output.properties.id, null)
}
