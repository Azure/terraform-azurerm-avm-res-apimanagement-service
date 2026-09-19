output "enabled" {
  description = "Whether direct tenant access is enabled."
  value       = var.enabled
}

output "primary_key" {
  description = "The primary tenant access key."
  sensitive   = true
  value       = data.azapi_resource_action.secrets.sensitive_output.primaryKey
}

output "resource_id" {
  description = "The resource ID of the tenant access setting."
  value       = local.resource_id
}

output "secondary_key" {
  description = "The secondary tenant access key."
  sensitive   = true
  value       = data.azapi_resource_action.secrets.sensitive_output.secondaryKey
}

output "tenant_id" {
  description = "The tenant access identifier exposed as `tenant_id` by the root module."
  value       = try(data.azapi_resource_action.secrets.output.id, null)
}
