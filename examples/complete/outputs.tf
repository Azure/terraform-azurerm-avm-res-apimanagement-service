output "apim_gateway_url" {
  description = "The gateway URL of the API Management service."
  value       = module.apim.apim_gateway_url
}

output "apim_resource_id" {
  description = "The resource ID of the API Management service."
  value       = module.apim.resource_id
}

output "named_values" {
  description = "The named values created in the API Management service."
  value       = module.apim.named_values
}

output "named_value_ids" {
  description = "Map of named value keys to their resource IDs."
  value       = module.apim.named_value_ids
}

output "apim_identity_principal_id" {
  description = "The principal ID of the APIM system-assigned managed identity (needed for Key Vault access policy)."
  value       = module.apim.workspace_identity.principal_id
}

output "key_vault_name" {
  description = "The name of the Key Vault (needed for setting access policy)."
  value       = azurerm_key_vault.this.name
}

output "key_vault_id" {
  description = "The resource ID of the Key Vault."
  value       = azurerm_key_vault.this.id
}

output "products" {
  description = "The products created in the API Management service."
  value       = module.apim.products
}

output "product_ids" {
  description = "Map of product keys to their resource IDs."
  value       = module.apim.product_ids
}

output "subscriptions" {
  description = "The subscriptions created in the API Management service."
  value       = module.apim.subscriptions
  sensitive   = true
}

output "subscription_keys" {
  description = "Map of subscription keys to their primary and secondary keys."
  value       = module.apim.subscription_keys
  sensitive   = true
}

output "policy" {
  description = "Service-level policy details."
  value       = module.apim.policy
}
