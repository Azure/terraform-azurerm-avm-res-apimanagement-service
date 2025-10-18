output "api_ids" {
  description = "The IDs of the created APIs"
  value       = module.apim.api_ids
}

output "apis" {
  description = "Details of the imported APIs"
  value       = module.apim.apis
}

output "apim_gateway_url" {
  description = "The gateway URL of the API Management service"
  value       = module.apim.apim_gateway_url
}

output "resource_id" {
  description = "The resource ID of the API Management service"
  value       = module.apim.resource_id
}
