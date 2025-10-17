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
