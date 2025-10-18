output "api_ids" {
  description = "The IDs of the created APIs"
  value       = module.apim.api_ids
}

output "api_operations" {
  description = "The API operations created"
  value       = module.apim.api_operations
}

output "apim_gateway_url" {
  description = "The gateway URL of the API Management service"
  value       = module.apim.apim_gateway_url
}

output "resource_id" {
  description = "The resource ID of the API Management service"
  value       = module.apim.resource_id
}
