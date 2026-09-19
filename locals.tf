locals {
  # Parse sku_name "Premium_3" → { name = "Premium", capacity = 3 }
  sku_parts = split("_", var.sku_name)
  sku = {
    name     = local.sku_parts[0]
    capacity = tonumber(local.sku_parts[1])
  }

  # Flatten hostname_configuration into the ARM hostnameConfigurations list.
  hostname_configurations = var.hostname_configuration == null ? null : concat(
    [for item in coalesce(var.hostname_configuration.management, []) : {
      type                       = "Management"
      hostName                   = item.host_name
      encodedCertificate         = item.certificate
      certificatePassword        = item.certificate_password
      keyVaultId                 = item.key_vault_id
      negotiateClientCertificate = item.negotiate_client_certificate
      identityClientId           = item.ssl_keyvault_identity_client_id
      defaultSslBinding          = null
    }],
    [for item in coalesce(var.hostname_configuration.portal, []) : {
      type                       = "Portal"
      hostName                   = item.host_name
      encodedCertificate         = item.certificate
      certificatePassword        = item.certificate_password
      keyVaultId                 = item.key_vault_id
      negotiateClientCertificate = item.negotiate_client_certificate
      identityClientId           = item.ssl_keyvault_identity_client_id
      defaultSslBinding          = null
    }],
    [for item in coalesce(var.hostname_configuration.developer_portal, []) : {
      type                       = "DeveloperPortal"
      hostName                   = item.host_name
      encodedCertificate         = item.certificate
      certificatePassword        = item.certificate_password
      keyVaultId                 = item.key_vault_id
      negotiateClientCertificate = item.negotiate_client_certificate
      identityClientId           = item.ssl_keyvault_identity_client_id
      defaultSslBinding          = null
    }],
    [for item in coalesce(var.hostname_configuration.proxy, []) : {
      type                       = "Proxy"
      hostName                   = item.host_name
      encodedCertificate         = item.certificate
      certificatePassword        = item.certificate_password
      keyVaultId                 = item.key_vault_id
      negotiateClientCertificate = item.negotiate_client_certificate
      identityClientId           = item.ssl_keyvault_identity_client_id
      defaultSslBinding          = item.default_ssl_binding
    }],
    [for item in coalesce(var.hostname_configuration.scm, []) : {
      type                       = "Scm"
      hostName                   = item.host_name
      encodedCertificate         = item.certificate
      certificatePassword        = item.certificate_password
      keyVaultId                 = item.key_vault_id
      negotiateClientCertificate = item.negotiate_client_certificate
      identityClientId           = item.ssl_keyvault_identity_client_id
      defaultSslBinding          = null
    }],
  )

  certificates = [
    for item in var.certificate : {
      encodedCertificate  = item.encoded_certificate
      storeName           = item.store_name
      certificatePassword = item.certificate_password
    }
  ]

  sensitive_body = length(local.certificates) == 0 && local.hostname_configurations == null ? null : {
    properties = merge(
      length(local.certificates) == 0 ? {} : { certificates = local.certificates },
      local.hostname_configurations == null ? {} : { hostnameConfigurations = local.hostname_configurations },
    )
  }

  sensitive_body_version = local.sensitive_body == null ? null : merge(
    length(local.certificates) == 0 ? {} : {
      "properties.certificates" = sha256(jsonencode(var.certificate))
    },
    local.hostname_configurations == null ? {} : {
      "properties.hostnameConfigurations" = sha256(jsonencode(var.hostname_configuration))
    },
  )

  # Map security + protocols into customProperties (ARM)
  custom_properties = merge(
    var.security == null ? {} : {
      "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30"                      = tostring(var.security.enable_backend_ssl30)
      "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10"                      = tostring(var.security.enable_backend_tls10)
      "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11"                      = tostring(var.security.enable_backend_tls11)
      "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30"                              = tostring(var.security.enable_frontend_ssl30)
      "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10"                              = tostring(var.security.enable_frontend_tls10)
      "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11"                              = tostring(var.security.enable_frontend_tls11)
      "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168"                         = tostring(var.security.triple_des_ciphers_enabled)
      "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA" = tostring(var.security.tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled)
      "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA" = tostring(var.security.tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled)
      "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA"   = tostring(var.security.tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled)
      "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA"   = tostring(var.security.tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled)
      "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA256"      = tostring(var.security.tls_rsa_with_aes128_cbc_sha256_ciphers_enabled)
      "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA"         = tostring(var.security.tls_rsa_with_aes128_cbc_sha_ciphers_enabled)
      "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_GCM_SHA256"      = tostring(var.security.tls_rsa_with_aes128_gcm_sha256_ciphers_enabled)
      "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA256"      = tostring(var.security.tls_rsa_with_aes256_cbc_sha256_ciphers_enabled)
      "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA"         = tostring(var.security.tls_rsa_with_aes256_cbc_sha_ciphers_enabled)
      "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_GCM_SHA384"      = tostring(var.security.tls_rsa_with_aes256_gcm_sha384_ciphers_enabled)
    },
    var.security == null || var.security.enable_backend_tls13 == null ? {} : {
      "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls13" = tostring(var.security.enable_backend_tls13)
    },
    var.security == null || var.security.enable_frontend_tls13 == null ? {} : {
      "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls13" = tostring(var.security.enable_frontend_tls13)
    },
    var.protocols == null ? {} : {
      "Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2" = tostring(var.protocols.enable_http2)
    },
  )

  resource_body = {
    properties = {
      publisherEmail          = var.publisher_email
      publisherName           = var.publisher_name
      notificationSenderEmail = var.notification_sender_email
      disableGateway          = var.gateway_disabled
      enableClientCertificate = var.client_certificate_enabled
      publicIpAddressId       = var.public_ip_address_id
      publicNetworkAccess     = var.public_network_access_enabled == null ? null : (var.public_network_access_enabled ? "Enabled" : "Disabled")
      virtualNetworkType      = var.virtual_network_type
      virtualNetworkConfiguration = contains(["Internal", "External"], var.virtual_network_type) ? {
        subnetResourceId = var.virtual_network_subnet_id
      } : null
      apiVersionConstraint = var.min_api_version == null ? null : {
        minApiVersion = var.min_api_version
      }
      additionalLocations = length(var.additional_location) == 0 ? null : [
        for loc in var.additional_location : {
          location          = loc.location
          disableGateway    = loc.gateway_disabled
          publicIpAddressId = loc.public_ip_address_id
          zones             = loc.zones
          sku = loc.capacity == null ? null : {
            name     = local.sku.name
            capacity = loc.capacity
          }
          virtualNetworkConfiguration = loc.virtual_network_configuration == null ? null : {
            subnetResourceId = loc.virtual_network_configuration.subnet_id
          }
        }
      ]
      certificates           = null
      hostnameConfigurations = null
      customProperties       = length(local.custom_properties) == 0 ? null : local.custom_properties
    }
    sku   = local.sku
    zones = var.zones
  }

  managed_identities = {
    system_assigned_user_assigned = (var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0) ? {
      this = {
        type                       = var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" : "SystemAssigned"
        user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
      }
    } : {}
    system_assigned = var.managed_identities.system_assigned ? {
      this = {
        type = "SystemAssigned"
      }
    } : {}
    user_assigned = length(var.managed_identities.user_assigned_resource_ids) > 0 ? {
      this = {
        type                       = "UserAssigned"
        user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
      }
    } : {}
  }

  single_backend_keys = toset([
    for k, v in nonsensitive(var.backends) : k
    if v.type == "Single"
  ])

  backend_pool_keys = toset([
    for k, v in nonsensitive(var.backends) : k
    if v.type == "Pool"
  ])

  api_keys = toset(nonsensitive(keys(var.apis)))

  # Flatten API operations into a single map for resource creation
  api_operations = merge([
    for api_key in local.api_keys : {
      for operation_key, operation in nonsensitive(coalesce(var.apis[api_key].operations, {})) : "${api_key}-${operation_key}" => merge(operation, {
        api_key       = api_key
        operation_key = operation_key
      })
    }
  ]...)

  # Flatten operation-level policies into a single map
  operation_policies = merge([
    for api_key in local.api_keys : {
      for operation_key, operation in nonsensitive(coalesce(var.apis[api_key].operations, {})) : "${api_key}-${operation_key}" => {
        api_key     = api_key
        xml_content = operation.policy != null ? operation.policy.xml_content : null
        xml_link    = operation.policy != null ? operation.policy.xml_link : null
      } if operation.policy != null
    }
  ]...)

  # Transform diagnostic_settings into the avm-utl-interfaces shape.
  diagnostic_settings_v2 = {
    for k, v in var.diagnostic_settings : k => {
      name                                     = v.name
      log_analytics_destination_type           = v.log_analytics_destination_type
      workspace_resource_id                    = v.workspace_resource_id
      storage_account_resource_id              = v.storage_account_resource_id
      event_hub_authorization_rule_resource_id = v.event_hub_authorization_rule_resource_id
      event_hub_name                           = v.event_hub_name
      marketplace_partner_resource_id          = v.marketplace_partner_resource_id
      logs = setunion(
        [for c in v.log_categories : { category = c, category_group = null, enabled = true, retention_policy = {} }],
        length(v.log_categories) == 0 ? [for g in v.log_groups : { category = null, category_group = g, enabled = true, retention_policy = {} }] : toset([])
      )
      metrics = toset([for m in v.metric_categories : { category = m, enabled = true, retention_policy = {} }])
    }
  }

  private_endpoint_parent_ids = {
    for k, v in var.private_endpoints : k => v.resource_group_name == null ? var.parent_id : format(
      "/subscriptions/%s/resourceGroups/%s",
      provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.parent_id).subscription_id,
      v.resource_group_name,
    )
  }

  # Use Gateway as the APIM private-link subresource unless explicitly overridden.
  private_endpoints_for_interfaces = {
    for k, v in var.private_endpoints : k => merge(v, {
      subresource_name = coalesce(v.subresource_name, "Gateway")
    })
  }

  # API-level policies (apis with policy set)
  api_policies = {
    for k in local.api_keys : k => nonsensitive(var.apis[k].policy)
    if nonsensitive(var.apis[k].policy != null)
  }

  # Product-API associations
  product_api_associations = {
    for assoc in flatten([
      for product_key, product in var.products : [
        for api_name in product.api_names : {
          product_key = product_key
          api_name    = api_name
          key         = "${product_key}-${api_name}"
        }
      ]
    ]) : assoc.key => assoc
  }

  # Product-group associations
  product_group_associations = {
    for assoc in flatten([
      for product_key, product in var.products : [
        for group_name in product.group_names : {
          product_key = product_key
          group_name  = group_name
          key         = "${product_key}-${group_name}"
        }
      ]
    ]) : assoc.key => assoc
  }

  # Subscription ARM scopes for AzAPI subscription submodule
  subscription_scopes = {
    for k, v in nonsensitive(var.subscriptions) : k => (
      v.scope_type == "product" ? "/products/${v.scope_identifier}" :
      v.scope_type == "api" ? "/apis/${v.scope_identifier}" :
      "/apis"
    )
  }

  main_location = var.location

}
