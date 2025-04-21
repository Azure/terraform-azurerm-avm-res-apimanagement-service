resource "azurerm_api_management" "this" {
  location            = var.location
  name                = var.name
  publisher_email     = var.publisher_email
  publisher_name      = var.publisher_name
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  # Client certificate settings
  client_certificate_enabled = var.client_certificate_enabled
  # Gateway settings
  gateway_disabled = var.gateway_disabled
  min_api_version  = var.min_api_version
  # Notification sender email
  notification_sender_email = var.notification_sender_email
  # Public IP and network access settings
  public_ip_address_id          = var.public_ip_address_id
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags
  virtual_network_type          = var.virtual_network_type
  # Availability Zones
  zones = var.zones

  # Additional locations
  dynamic "additional_location" {
    for_each = var.additional_location

    content {
      location             = additional_location.value.location
      capacity             = additional_location.value.capacity
      gateway_disabled     = additional_location.value.gateway_disabled
      public_ip_address_id = additional_location.value.public_ip_address_id
      zones                = additional_location.value.zones

      dynamic "virtual_network_configuration" {
        for_each = additional_location.value.virtual_network_configuration != null ? [additional_location.value.virtual_network_configuration] : []

        content {
          subnet_id = virtual_network_configuration.value.subnet_id
        }
      }
    }
  }
  # Certificates
  dynamic "certificate" {
    for_each = var.certificate

    content {
      encoded_certificate  = certificate.value.encoded_certificate
      store_name           = certificate.value.store_name
      certificate_password = certificate.value.certificate_password
    }
  }
  # Delegation settings
  dynamic "delegation" {
    for_each = var.delegation != null ? [var.delegation] : []

    content {
      subscriptions_enabled     = delegation.value.subscriptions_enabled
      url                       = delegation.value.url
      user_registration_enabled = delegation.value.user_registration_enabled
      validation_key            = delegation.value.validation_key
    }
  }
  # Hostname configuration
  dynamic "hostname_configuration" {
    for_each = var.hostname_configuration != null ? [var.hostname_configuration] : []

    content {
      dynamic "developer_portal" {
        for_each = hostname_configuration.value.developer_portal

        content {
          host_name                       = developer_portal.value.host_name
          certificate                     = developer_portal.value.certificate
          certificate_password            = developer_portal.value.certificate_password
          key_vault_id                    = developer_portal.value.key_vault_id
          negotiate_client_certificate    = developer_portal.value.negotiate_client_certificate
          ssl_keyvault_identity_client_id = developer_portal.value.ssl_keyvault_identity_client_id
        }
      }
      dynamic "management" {
        for_each = hostname_configuration.value.management

        content {
          host_name                       = management.value.host_name
          certificate                     = management.value.certificate
          certificate_password            = management.value.certificate_password
          key_vault_id                    = management.value.key_vault_id
          negotiate_client_certificate    = management.value.negotiate_client_certificate
          ssl_keyvault_identity_client_id = management.value.ssl_keyvault_identity_client_id
        }
      }
      dynamic "portal" {
        for_each = hostname_configuration.value.portal

        content {
          host_name                       = portal.value.host_name
          certificate                     = portal.value.certificate
          certificate_password            = portal.value.certificate_password
          key_vault_id                    = portal.value.key_vault_id
          negotiate_client_certificate    = portal.value.negotiate_client_certificate
          ssl_keyvault_identity_client_id = portal.value.ssl_keyvault_identity_client_id
        }
      }
      dynamic "proxy" {
        for_each = hostname_configuration.value.proxy

        content {
          host_name                       = proxy.value.host_name
          certificate                     = proxy.value.certificate
          certificate_password            = proxy.value.certificate_password
          default_ssl_binding             = proxy.value.default_ssl_binding
          key_vault_id                    = proxy.value.key_vault_id
          negotiate_client_certificate    = proxy.value.negotiate_client_certificate
          ssl_keyvault_identity_client_id = proxy.value.ssl_keyvault_identity_client_id
        }
      }
      dynamic "scm" {
        for_each = hostname_configuration.value.scm

        content {
          host_name                       = scm.value.host_name
          certificate                     = scm.value.certificate
          certificate_password            = scm.value.certificate_password
          key_vault_id                    = scm.value.key_vault_id
          negotiate_client_certificate    = scm.value.negotiate_client_certificate
          ssl_keyvault_identity_client_id = scm.value.ssl_keyvault_identity_client_id
        }
      }
    }
  }
  # Identity settings
  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }
  # HTTP protocol settings
  dynamic "protocols" {
    for_each = var.protocols != null ? [var.protocols] : []

    content {
      enable_http2 = protocols.value.enable_http2
    }
  }
  # Security settings
  dynamic "security" {
    for_each = var.security != null ? [var.security] : []

    content {
      enable_backend_ssl30                                = security.value.enable_backend_ssl30
      enable_backend_tls10                                = security.value.enable_backend_tls10
      enable_backend_tls11                                = security.value.enable_backend_tls11
      enable_frontend_ssl30                               = security.value.enable_frontend_ssl30
      enable_frontend_tls10                               = security.value.enable_frontend_tls10
      enable_frontend_tls11                               = security.value.enable_frontend_tls11
      tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = security.value.tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled
      tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = security.value.tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled
      tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = security.value.tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled
      tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = security.value.tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled
      tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = security.value.tls_rsa_with_aes128_cbc_sha256_ciphers_enabled
      tls_rsa_with_aes128_cbc_sha_ciphers_enabled         = security.value.tls_rsa_with_aes128_cbc_sha_ciphers_enabled
      tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      = security.value.tls_rsa_with_aes128_gcm_sha256_ciphers_enabled
      tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      = security.value.tls_rsa_with_aes256_cbc_sha256_ciphers_enabled
      tls_rsa_with_aes256_cbc_sha_ciphers_enabled         = security.value.tls_rsa_with_aes256_cbc_sha_ciphers_enabled
      tls_rsa_with_aes256_gcm_sha384_ciphers_enabled      = security.value.tls_rsa_with_aes256_gcm_sha384_ciphers_enabled
      triple_des_ciphers_enabled                          = security.value.triple_des_ciphers_enabled
    }
  }
  # Sign-in settings
  dynamic "sign_in" {
    for_each = var.sign_in != null ? [var.sign_in] : []

    content {
      enabled = sign_in.value.enabled
    }
  }
  # Sign-up settings
  dynamic "sign_up" {
    for_each = var.sign_up != null ? [var.sign_up] : []

    content {
      enabled = sign_up.value.enabled

      terms_of_service {
        consent_required = sign_up.value.terms_of_service.consent_required
        enabled          = sign_up.value.terms_of_service.enabled
        text             = sign_up.value.terms_of_service.text
      }
    }
  }
  # Tenant access settings
  dynamic "tenant_access" {
    for_each = var.tenant_access != null ? [var.tenant_access] : []

    content {
      enabled = tenant_access.value.enabled
    }
  }
  # This implementation uses a dynamic block with for_each to conditionally create the virtual_network_configuration block only when virtual_network_type is either "Internal" or "External".
  # If the type is "None", the block won't be included in the resource.
  dynamic "virtual_network_configuration" {
    for_each = contains(["Internal", "External"], var.virtual_network_type) ? [1] : []

    content {
      subnet_id = var.virtual_network_subnet_id
    }
  }

  lifecycle {
    # This prevents errors when deleting products with subscriptions
    create_before_destroy = true
    # Optional: If you want to skip destroying default products
    ignore_changes = [
      # product
    ]
  }
}

# Lock resource
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azurerm_api_management.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete resource or child resources." : "Cannot modify the resource or its children."
}

# Role assignments
resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_api_management.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}


