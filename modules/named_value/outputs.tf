output "display_name" {
  description = "The display name of the named value."
  value       = var.display_name
}

output "key_vault_last_status" {
  description = "Last time sync and refresh status of secret from key vault."
  value       = try(azapi_resource.this.output.properties.keyVault.lastStatus, null)
}

output "name" {
  description = "The name of the named value."
  value       = azapi_resource.this.name
}

output "provisioning_state" {
  description = "The provisioning state of the named value."
  value       = try(azapi_resource.this.output.properties.provisioningState, null)
}

output "resource_id" {
  description = "The resource ID of the named value."
  value       = azapi_resource.this.id
}

output "secret" {
  description = "Whether the named value is marked as a secret."
  value       = var.secret
}
