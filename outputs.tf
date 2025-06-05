output "additional_locations" {
  description = "Information about additional locations for the API Management Service."
  value = [
    for location in azurerm_api_management.this.additional_location : {
      gateway_regional_url = location.gateway_regional_url
      public_ip_addresses  = location.public_ip_addresses
      private_ip_addresses = location.private_ip_addresses
    }
  ]
}

output "apim_gateway_url" {
  description = "The gateway URL of the API Management service."
  value       = azurerm_api_management.this.gateway_url
}

output "apim_management_url" {
  description = "The management URL of the API Management service."
  value       = azurerm_api_management.this.management_api_url
}

output "certificates" {
  description = "Certificate information for the API Management Service."
  value = [
    for cert in azurerm_api_management.this.certificate : {
      expiry     = cert.expiry
      thumbprint = cert.thumbprint
      subject    = cert.subject
    }
  ]
}

output "developer_portal_url" {
  description = "The publisher URL of the API Management service."
  value       = azurerm_api_management.this.developer_portal_url
}

output "gateway_regional_url" {
  description = "The Region URL for the Gateway of the API Management Service."
  value       = azurerm_api_management.this.gateway_regional_url
}

output "hostname_configuration" {
  description = "The hostname configuration for the API Management Service."
  value = {
    proxy = [
      for proxy in try(azurerm_api_management.this.hostname_configuration[0].proxy, []) : {
        certificate_source = proxy.certificate_source
        certificate_status = proxy.certificate_status
      }
    ]
  }
}

output "name" {
  description = "The name of the API Management service."
  value       = azurerm_api_management.this.name
}

output "portal_url" {
  description = "The URL for the Publisher Portal associated with this API Management service."
  value       = azurerm_api_management.this.portal_url
}

output "private_endpoints" {
  description = "A map of the private endpoints created."
  value       = var.private_endpoints_manage_dns_zone_group ? azurerm_private_endpoint.this : azurerm_private_endpoint.this_unmanaged_dns_zone_groups
}

output "private_ip_addresses" {
  description = "The private IP addresses of the private endpoints created by this module"
  value       = azurerm_api_management.this.private_ip_addresses
}

output "public_ip_addresses" {
  description = "The Public IP addresses of the API Management Service."
  value       = azurerm_api_management.this.public_ip_addresses
}

# Module owners should include the full resource via a 'resource' output
# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tffr2---category-outputs---additional-terraform-outputs
# To include the full resource, uncomment the following block which is a sensitive output
output "resource" {
  description = "The API Management service resource."
  sensitive   = true
  value       = azurerm_api_management.this
}

output "resource_id" {
  description = "The ID of the API Management service."
  value       = azurerm_api_management.this.id
}

output "scm_url" {
  description = "The URL for the SCM (Source Code Management) Endpoint associated with this API Management service."
  value       = azurerm_api_management.this.scm_url
}

output "tenant_access" {
  description = "The tenant access information for the API Management Service."
  sensitive   = true
  value = {
    tenant_id     = try(azurerm_api_management.this.tenant_access[0].tenant_id, null)
    primary_key   = try(azurerm_api_management.this.tenant_access[0].primary_key, null)
    secondary_key = try(azurerm_api_management.this.tenant_access[0].secondary_key, null)
  }
}

output "workspace_identity" {
  description = "The identity for the created workspace."
  value = {
    principal_id = try(azurerm_api_management.this.identity[0].principal_id, null)
    type         = try(azurerm_api_management.this.identity[0].type, null)
  }
}
