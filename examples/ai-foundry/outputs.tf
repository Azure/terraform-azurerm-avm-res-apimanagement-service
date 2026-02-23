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

output "backend_ids" {
  description = "Map of backend names to their resource IDs."
  value       = module.apim.backend_ids
}

output "backends" {
  description = "The backends created in the API Management service."
  value       = module.apim.backends
}
