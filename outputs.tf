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

# Named Values outputs
output "named_values" {
  description = "A map of named values created in the API Management service."
  value = {
    for k, v in azurerm_api_management_named_value.this : k => {
      id           = v.id
      name         = v.name
      display_name = v.display_name
      secret       = v.secret
    }
  }
}

output "named_value_ids" {
  description = "A map of named value keys to their resource IDs."
  value = {
    for k, v in azurerm_api_management_named_value.this : k => v.id
  }
}

# API Version Sets outputs
output "api_version_sets" {
  description = "A map of API version sets created in the API Management service."
  value = {
    for k, v in azurerm_api_management_api_version_set.this : k => {
      id                  = v.id
      name                = v.name
      display_name        = v.display_name
      versioning_scheme   = v.versioning_scheme
      version_header_name = v.version_header_name
      version_query_name  = v.version_query_name
    }
  }
}

output "api_version_set_ids" {
  description = "A map of API version set names to their resource IDs."
  value = {
    for k, v in azurerm_api_management_api_version_set.this : k => v.id
  }
}

# APIs outputs
output "apis" {
  description = "A map of APIs created in the API Management service."
  value = {
    for k, v in azurerm_api_management_api.this : k => {
      id                    = v.id
      name                  = v.name
      api_type              = v.api_type
      display_name          = v.display_name
      path                  = v.path
      protocols             = v.protocols
      revision              = v.revision
      version               = v.version
      version_set_id        = v.version_set_id
      subscription_required = v.subscription_required
      service_url           = v.service_url
      is_current            = v.is_current
      is_online             = v.is_online
    }
  }
}

output "api_ids" {
  description = "A map of API names to their resource IDs."
  value = {
    for k, v in azurerm_api_management_api.this : k => v.id
  }
}

# API Operations outputs
output "api_operations" {
  description = "A map of API operations created in the API Management service."
  value = {
    for k, v in azurerm_api_management_api_operation.this : k => {
      id           = v.id
      operation_id = v.operation_id
      api_name     = v.api_name
      display_name = v.display_name
      method       = v.method
      url_template = v.url_template
    }
  }
}

output "api_operation_ids" {
  description = "A map of API operation keys to their operation IDs."
  value = {
    for k, v in azurerm_api_management_api_operation.this : k => v.operation_id
  }
}

# Products outputs
output "products" {
  description = "A map of products created in the API Management service."
  value = {
    for k, v in azurerm_api_management_product.this : k => {
      id                    = v.id
      product_id            = v.product_id
      display_name          = v.display_name
      description           = v.description
      subscription_required = v.subscription_required
      approval_required     = v.approval_required
      published             = v.published
      subscriptions_limit   = v.subscriptions_limit
      terms                 = v.terms
    }
  }
}

output "product_ids" {
  description = "A map of product keys to their resource IDs."
  value = {
    for k, v in azurerm_api_management_product.this : k => v.id
  }
}

# Subscriptions outputs
output "subscriptions" {
  description = "A map of subscriptions created in the API Management service."
  value = {
    for k, v in azurerm_api_management_subscription.this : k => {
      id              = v.id
      subscription_id = v.subscription_id
      display_name    = v.display_name
      state           = v.state
      allow_tracing   = v.allow_tracing
    }
  }
  sensitive = true
}

output "subscription_ids" {
  description = "A map of subscription keys to their resource IDs."
  value = {
    for k, v in azurerm_api_management_subscription.this : k => v.id
  }
  sensitive = true
}

output "subscription_keys" {
  description = "A map of subscription keys to their primary and secondary keys."
  value = {
    for k, v in azurerm_api_management_subscription.this : k => {
      primary_key   = v.primary_key
      secondary_key = v.secondary_key
    }
  }
  sensitive = true
}
