output "apim_gateway_url" {
  description = "The gateway URL of the API Management service."
  value       = module.apim.apim_gateway_url
}

output "apim_identity_principal_id" {
  description = "The principal ID of the APIM system-assigned managed identity."
  value       = module.apim.workspace_identity.principal_id
}

output "apim_resource_id" {
  description = "The resource ID of the API Management service."
  value       = module.apim.resource_id
}

output "named_value_ids" {
  description = "Map of named value keys to their resource IDs."
  value       = module.apim.named_value_ids
}

output "named_values" {
  description = "The named values created in the API Management service."
  value       = module.apim.named_values
}

output "policy" {
  description = "Service-level policy details."
  value       = module.apim.policy
}

output "product_ids" {
  description = "Map of product keys to their resource IDs."
  value       = module.apim.product_ids
}

output "products" {
  description = "The products created in the API Management service."
  value       = module.apim.products
}

output "subscription_keys" {
  description = "Map of subscription keys to their primary and secondary keys."
  sensitive   = true
  value       = module.apim.subscription_keys
}

output "subscriptions" {
  description = "The subscriptions created in the API Management service."
  sensitive   = true
  value       = module.apim.subscriptions
}
