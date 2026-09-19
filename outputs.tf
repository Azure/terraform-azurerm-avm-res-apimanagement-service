output "additional_locations" {
  description = "Configured additional locations for the API Management Service (input echo; computed regional URLs are not exported by AzAPI)."
  value       = var.additional_location
}

output "api_ids" {
  description = "A map of API names to their resource IDs."
  value = {
    for k, v in module.api : k => v.resource_id
  }
}

output "api_operation_ids" {
  description = "A map of API operation keys to their operation IDs (ARM resource names)."
  value = {
    for k, v in module.operation : k => v.name
  }
}

# API Operations outputs
output "api_operations" {
  description = "A map of API operations created in the API Management service."
  value = {
    for k, v in module.operation : k => {
      id           = v.resource_id
      operation_id = v.name
      api_name     = local.api_operations[k].api_key
      display_name = v.display_name
      method       = v.method
      url_template = v.url_template
    }
  }
}

output "api_version_set_ids" {
  description = "A map of API version set names to their resource IDs."
  value       = { for k, v in module.api_version_set : k => v.resource_id }
}

# API Version Sets outputs
output "api_version_sets" {
  description = "A map of API version sets created in the API Management service."
  value = {
    for k, v in module.api_version_set : k => {
      id                  = v.resource_id
      name                = v.name
      display_name        = var.api_version_sets[k].display_name
      versioning_scheme   = var.api_version_sets[k].versioning_scheme
      version_header_name = var.api_version_sets[k].version_header_name
      version_query_name  = var.api_version_sets[k].version_query_name
    }
  }
}

output "apim_gateway_url" {
  description = "The gateway URL of the API Management service."
  value       = try(azapi_resource.this.output.properties.gatewayUrl, null)
}

output "apim_management_url" {
  description = "The management URL of the API Management service."
  value       = try(azapi_resource.this.output.properties.managementApiUrl, null)
}

# APIs outputs
output "apis" {
  description = "A map of APIs created in the API Management service."
  value = {
    for k, v in module.api : k => {
      id                    = v.resource_id
      name                  = v.name
      api_type              = v.api_type
      display_name          = v.display_name
      path                  = v.path
      protocols             = v.protocols
      revision              = v.api_revision
      version               = v.api_version
      version_set_id        = v.api_version_set_id
      subscription_required = v.subscription_required
      service_url           = v.service_url
      is_current            = v.is_current
      is_online             = v.is_online
    }
  }
}

output "backend_ids" {
  description = "A map of backend names to their resource IDs."
  value = merge(
    { for k, v in module.backend : k => v.resource_id },
    { for k, v in module.backend_pool : k => v.resource_id },
  )
}

# Backends outputs
output "backends" {
  description = "A map of backends created in the API Management service."
  value = merge(
    { for k, v in module.backend : k => {
      id          = v.resource_id
      name        = v.name
      protocol    = v.protocol
      url         = v.url
      description = v.description
      resource_id = v.backend_resource_id
      title       = v.title
      type        = v.backend_type
    } },
    { for k, v in module.backend_pool : k => {
      id          = v.resource_id
      name        = v.name
      protocol    = v.protocol
      url         = v.url
      description = v.description
      resource_id = v.backend_resource_id
      title       = v.title
      type        = v.backend_type
    } },
  )
}

output "certificates" {
  description = "Configured certificates for the API Management Service (input echo; computed certificate metadata is not exported by AzAPI)."
  sensitive   = true
  value       = var.certificate
}

output "developer_portal_url" {
  description = "The publisher URL of the API Management service."
  value       = try(azapi_resource.this.output.properties.developerPortalUrl, null)
}

output "gateway_regional_url" {
  description = "The Region URL for the Gateway of the API Management Service."
  value       = try(azapi_resource.this.output.properties.gatewayRegionalUrl, null)
}

output "hostname_configuration" {
  description = "Configured hostname configuration for the API Management Service (input echo)."
  sensitive   = true
  value       = var.hostname_configuration
}

output "name" {
  description = "The name of the API Management service."
  value       = azapi_resource.this.name
}

output "named_value_ids" {
  description = "A map of named value keys to their resource IDs."
  value = {
    for k, v in module.named_value : k => v.resource_id
  }
}

# Named Values outputs
output "named_values" {
  description = "A map of named values created in the API Management service."
  value = {
    for k, v in module.named_value : k => {
      id           = v.resource_id
      name         = v.name
      display_name = v.display_name
      secret       = v.secret
    }
  }
}

output "policy" {
  description = "Service-level policy details."
  value = length(module.policy) > 0 ? {
    id = module.policy[0].resource_id
  } : null
}

output "policy_fragment_ids" {
  description = "A map of policy fragment names to resource IDs."
  value       = { for k, v in module.policy_fragment : k => v.resource_id }
}

output "policy_fragments" {
  description = "A map of policy fragments created in the API Management service."
  value = {
    for k, v in module.policy_fragment : k => {
      id          = v.resource_id
      name        = v.name
      description = var.policy_fragments[k].description
      format      = var.policy_fragments[k].format
    }
  }
}

output "portal_url" {
  description = "The URL for the Publisher Portal associated with this API Management service."
  value       = try(azapi_resource.this.output.properties.portalUrl, null)
}

output "private_endpoints" {
  description = "A map of the private endpoints created."
  value = {
    for k, v in azapi_resource.private_endpoints : k => {
      id                 = v.id
      name               = v.name
      custom_dns_configs = try(v.output.properties.customDnsConfigs, [])
      network_interfaces = try(v.output.properties.networkInterfaces, [])
    }
  }
}

output "private_ip_addresses" {
  description = "Private Static Load Balanced IP addresses of the API Management service in the primary region."
  value       = try(azapi_resource.this.output.properties.privateIPAddresses, [])
}

output "product_ids" {
  description = "A map of product keys to their resource IDs."
  value       = { for k, product in module.product : k => product.resource_id }
}

output "products" {
  description = "A map of products created in the API Management service."
  value = {
    for k, product in module.product : k => {
      id                    = product.resource_id
      product_id            = product.name
      display_name          = var.products[k].display_name
      description           = var.products[k].description
      subscription_required = var.products[k].subscription_required
      approval_required     = var.products[k].approval_required
      published             = var.products[k].state == "published"
      subscriptions_limit   = var.products[k].subscriptions_limit
      terms                 = var.products[k].terms
    }
  }
}

output "public_ip_addresses" {
  description = "The Public IP addresses of the API Management Service."
  value       = try(azapi_resource.this.output.properties.publicIPAddresses, [])
}

output "resource_id" {
  description = "The ID of the API Management service."
  value       = azapi_resource.this.id
}

output "scm_url" {
  description = "The URL for the SCM (Source Code Management) Endpoint associated with this API Management service."
  value       = try(azapi_resource.this.output.properties.scmUrl, null)
}

output "subscription_ids" {
  description = "A map of subscription keys to their resource IDs."
  sensitive   = true
  value       = { for k, v in module.subscription : k => v.resource_id }
}

output "subscription_keys" {
  description = "Subscription primary/secondary keys are not exported by AzAPI; use the listSecrets data-plane operation if required. Values supplied via `var.subscriptions` primary_key/secondary_key are write-only."
  sensitive   = true
  value = {
    for k, v in module.subscription : k => {
      primary_key   = null
      secondary_key = null
    }
  }
}

# Subscriptions outputs
output "subscriptions" {
  description = "A map of subscriptions created in the API Management service."
  sensitive   = true
  value = {
    for k, v in module.subscription : k => {
      id              = v.resource_id
      subscription_id = v.name
      display_name    = var.subscriptions[k].display_name
      state           = var.subscriptions[k].state
      allow_tracing   = var.subscriptions[k].allow_tracing
    }
  }
}

output "tenant_access" {
  description = "Tenant access keys are not exported by the AzAPI service resource; manage via the tenant/access child resource (not yet migrated)."
  sensitive   = true
  value = {
    tenant_id     = null
    primary_key   = null
    secondary_key = null
  }
}

output "workspace_identity" {
  description = "The managed identity of the API Management service."
  value = {
    principal_id = try(azapi_resource.this.output.identity.principalId, null)
    tenant_id    = try(azapi_resource.this.output.identity.tenantId, null)
  }
}
