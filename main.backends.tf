# API Management Backends
# This file implements backend resources for the API Management service.
# Backends define the HTTP endpoint that API operations forward requests to,
# including Azure AI Foundry endpoints, Function Apps, Logic Apps, and custom HTTP services.

resource "azurerm_api_management_backend" "this" {
  for_each = var.backends

  api_management_name = azurerm_api_management.this.name
  name                = each.key
  protocol            = each.value.protocol
  resource_group_name = azurerm_api_management.this.resource_group_name
  url                 = each.value.url
  description         = each.value.description
  resource_id         = each.value.resource_id
  title               = each.value.title

  # Credentials for backend authentication
  dynamic "credentials" {
    for_each = each.value.credentials != null ? [each.value.credentials] : []

    content {
      certificate = credentials.value.certificate
      header      = credentials.value.header
      query       = credentials.value.query

      dynamic "authorization" {
        for_each = credentials.value.authorization != null ? [credentials.value.authorization] : []

        content {
          parameter = authorization.value.parameter
          scheme    = authorization.value.scheme
        }
      }
    }
  }
  # Proxy configuration
  dynamic "proxy" {
    for_each = each.value.proxy != null ? [each.value.proxy] : []

    content {
      url      = proxy.value.url
      username = proxy.value.username
      password = proxy.value.password
    }
  }
  # Service Fabric cluster configuration
  dynamic "service_fabric_cluster" {
    for_each = each.value.service_fabric_cluster != null ? [each.value.service_fabric_cluster] : []

    content {
      management_endpoints             = service_fabric_cluster.value.management_endpoints
      max_partition_resolution_retries = service_fabric_cluster.value.max_partition_resolution_retries
      client_certificate_id            = service_fabric_cluster.value.client_certificate_id
      client_certificate_thumbprint    = service_fabric_cluster.value.client_certificate_thumbprint
      server_certificate_thumbprints   = service_fabric_cluster.value.server_certificate_thumbprints

      dynamic "server_x509_name" {
        for_each = service_fabric_cluster.value.server_x509_name

        content {
          issuer_certificate_thumbprint = server_x509_name.value.issuer_certificate_thumbprint
          name                          = server_x509_name.value.name
        }
      }
    }
  }
  # TLS validation settings
  dynamic "tls" {
    for_each = each.value.tls != null ? [each.value.tls] : []

    content {
      validate_certificate_chain = tls.value.validate_certificate_chain
      validate_certificate_name  = tls.value.validate_certificate_name
    }
  }

  depends_on = [azurerm_api_management.this]
}
