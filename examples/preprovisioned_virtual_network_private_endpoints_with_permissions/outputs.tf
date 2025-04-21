output "apim_gateway_url" {
  description = "The gateway URL of the API Management service."
  value       = module.test.apim_gateway_url
}

output "apim_management_url" {
  description = "The management URL of the API Management service."
  value       = module.test.apim_management_url
}

output "id" {
  description = "The ID of the API Management service."
  value       = module.test.id
}

output "name" {
  description = "The name of the API Management service."
  value       = module.test.name
}

output "private_endpoint_subnet_id" {
  description = "The private endpoint created for the API Management service."
  value       = module.test.private_endpoints
}

output "private_endpoint_name" {
  description = "The name of the private endpoint created for the API Management service."
  value       = "pe-${module.naming.api_management.name_unique}"
}

output "private_endpoint_subnet_id" {
  description = "The ID of the subnet used for private endpoints."
  value       = azurerm_subnet.private_endpoints.id
}

output "private_ip_addresses" {
  description = "The private IP addresses of the private endpoints created by this module"
  value       = module.test.private_ip_addresses
}

output "resource_group_name" {
  description = "The name of the resource group where the API Management service is deployed."
  value       = azurerm_resource_group.this.name
}

output "virtual_network_name" {
  description = "The name of the virtual network used for the deployment."
  value       = azurerm_virtual_network.this.name
}

output "workspace_identity" {
  description = "The identity for the created workspace."
  value       = module.test.workspace_identity
}
