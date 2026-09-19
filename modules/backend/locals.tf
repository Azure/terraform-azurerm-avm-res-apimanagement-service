locals {
  credentials_body = var.credentials == null ? null : {
    authorization = var.credentials.authorization == null ? null : {
      parameter = var.credentials.authorization.parameter
      scheme    = var.credentials.authorization.scheme
    }
    certificate    = length(var.credentials.certificate) > 0 ? var.credentials.certificate : null
    certificateIds = length(var.credentials.certificate_ids) > 0 ? var.credentials.certificate_ids : null
    header         = length(var.credentials.header) > 0 ? { for k, v in var.credentials.header : k => split(",", v) } : null
    query          = length(var.credentials.query) > 0 ? { for k, v in var.credentials.query : k => split(",", v) } : null
  }

  service_fabric_cluster_body = var.service_fabric_cluster == null ? null : {
    clientCertificateId           = var.service_fabric_cluster.client_certificate_id
    clientCertificatethumbprint   = var.service_fabric_cluster.client_certificate_thumbprint
    managementEndpoints           = var.service_fabric_cluster.management_endpoints
    maxPartitionResolutionRetries = var.service_fabric_cluster.max_partition_resolution_retries
    serverCertificateThumbprints  = length(var.service_fabric_cluster.server_certificate_thumbprints) > 0 ? var.service_fabric_cluster.server_certificate_thumbprints : null
    serverX509Names = length(var.service_fabric_cluster.server_x509_name) > 0 ? [
      for item in var.service_fabric_cluster.server_x509_name : {
        issuerCertificateThumbprint = item.issuer_certificate_thumbprint
        name                        = item.name
      }
    ] : null
  }

  sensitive_body = {
    properties = {
      credentials = local.credentials_body
      proxy = var.proxy == null ? null : {
        password = var.proxy.password
        url      = var.proxy.url
        username = var.proxy.username
      }
    }
  }

  sensitive_body_version = {
    "properties.credentials" = sha256(jsonencode(var.credentials))
    "properties.proxy"       = sha256(jsonencode(var.proxy))
  }

  resource_body = {
    properties = {
      description = var.description
      pool = var.pool == null ? null : {
        services = [
          for service in var.pool.services : {
            id       = service.id
            priority = service.priority
            weight   = service.weight
          }
        ]
      }
      properties = local.service_fabric_cluster_body == null ? null : {
        serviceFabricCluster = local.service_fabric_cluster_body
      }
      protocol   = var.protocol
      resourceId = var.resource_id
      title      = var.title
      tls = var.tls == null ? null : {
        validateCertificateChain = var.tls.validate_certificate_chain
        validateCertificateName  = var.tls.validate_certificate_name
      }
      type = var.type
      url  = var.url
    }
  }
  main_location = "unknown"
}
