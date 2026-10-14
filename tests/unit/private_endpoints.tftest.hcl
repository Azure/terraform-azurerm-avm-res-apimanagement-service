mock_provider "azapi" {
  mock_data "azapi_resource_list" {
    defaults = {
      output = {
        results = [{
          id        = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
          role_name = "Reader"
        }]
      }
    }
  }
}

mock_provider "azurerm" {
  mock_resource "azurerm_api_management" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/apim/providers/Microsoft.ApiManagement/service/apim"
    }
  }
  mock_resource "azurerm_private_endpoint" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/endpoints/providers/Microsoft.Network/privateEndpoints/apim"
    }
  }
}

mock_provider "modtm" {}

mock_provider "random" {
  mock_resource "random_uuid" {
    defaults = {
      result = "11111111-1111-1111-1111-111111111111"
    }
  }
}

variables {
  name                = "apim"
  location            = "uksouth"
  resource_group_name = "apim"
  publisher_email     = "publisher@example.com"
  enable_telemetry    = false
}

run "defaults" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
  }

  assert {
    condition     = length(azurerm_private_endpoint.this) == 0 && length(azurerm_private_endpoint.this_unmanaged_dns_zone_groups) == 0 && length(azapi_resource.private_endpoint_locks) == 0 && length(azapi_resource.private_endpoint_role_assignments) == 0
    error_message = "Default inputs must not create private endpoints or their extensions."
  }
  assert {
    condition     = azurerm_api_management.this.sku_name == "Developer_1" && length(azapi_update_resource.tls13) == 0
    error_message = "Service defaults and opt-in TLS 1.3 management must be preserved."
  }
}

run "managed_dns_supported_fields" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
  }

  variables {
    tags = { service = "apim" }
    retry = {
      error_message_regex = ["ScopeLocked"]
      interval_seconds    = 5
    }
    timeouts = { create = "30m", update = "40m", delete = "5m" }
    resource_types = {
      authorization_locks            = "Microsoft.Authorization/locks@2020-05-01"
      authorization_role_assignments = "Microsoft.Authorization/roleAssignments@2022-04-01"
    }
    ignore_body_changes = {
      authorization_locks            = ["properties.notes"]
      authorization_role_assignments = ["properties.description"]
    }
    private_endpoints = {
      gateway = {
        resource_group_name = "endpoints"
        subnet_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/network/subnets/endpoints"
        subresource_name    = "Gateway"
        location            = "westeurope"
        name                = "custom-endpoint"
        tags                = {}
        private_dns_zone_resource_ids = [
          "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/privateDnsZones/privatelink.azure-api.net"
        ]
        ip_configurations = {
          gateway = {
            name               = "gateway-ip"
            private_ip_address = "10.0.0.5"
            member_name        = "Gateway"
          }
        }
        lock = {
          kind  = "CanNotDelete"
          name  = "endpoint-lock"
          notes = "Endpoint protection"
        }
        role_assignments = {
          reader = {
            name                                   = "22222222-2222-2222-2222-222222222222"
            role_definition_id_or_name             = "Reader"
            principal_id                           = "33333333-3333-3333-3333-333333333333"
            principal_type                         = "ServicePrincipal"
            description                            = "Endpoint reader"
            skip_service_principal_aad_check       = true
            condition                              = "example condition"
            condition_version                      = "2.0"
            delegated_managed_identity_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/delegated"
          }
        }
      }
    }
  }

  assert {
    condition     = length(azurerm_private_endpoint.this) == 1 && length(azurerm_private_endpoint.this_unmanaged_dns_zone_groups) == 0
    error_message = "Managed DNS must use only the existing managed endpoint address."
  }
  assert {
    condition     = azurerm_private_endpoint.this["gateway"].resource_group_name == "endpoints" && azurerm_private_endpoint.this["gateway"].location == "westeurope" && azurerm_private_endpoint.this["gateway"].name == "custom-endpoint" && length(azurerm_private_endpoint.this["gateway"].tags) == 0
    error_message = "Endpoint resource-group, location, name, and empty-tag overrides must be honored."
  }
  assert {
    condition     = azurerm_private_endpoint.this["gateway"].ip_configuration[0].member_name == "Gateway" && azurerm_private_endpoint.this["gateway"].ip_configuration[0].subresource_name == "Gateway" && length(azurerm_private_endpoint.this["gateway"].private_dns_zone_group) == 1
    error_message = "Static IP member and subresource names and managed DNS must be wired."
  }
  assert {
    condition     = azapi_resource.private_endpoint_locks["gateway"].parent_id == azurerm_private_endpoint.this["gateway"].id && azapi_resource.private_endpoint_locks["gateway"].body.properties.level == "CanNotDelete" && azapi_resource.private_endpoint_locks["gateway"].body.properties.notes == "Endpoint protection"
    error_message = "The endpoint lock must have the requested scope, level, and notes."
  }
  assert {
    condition     = azapi_resource.private_endpoint_role_assignments["gateway-reader"].parent_id == azurerm_private_endpoint.this["gateway"].id && azapi_resource.private_endpoint_role_assignments["gateway-reader"].name == "22222222-2222-2222-2222-222222222222" && azapi_resource.private_endpoint_role_assignments["gateway-reader"].body.properties.roleDefinitionId == "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
    error_message = "Endpoint role assignments must retain their scope, explicit name, and resolved role permissions."
  }
  assert {
    condition     = azapi_resource.private_endpoint_role_assignments["gateway-reader"].body.properties.principalType == "ServicePrincipal" && azapi_resource.private_endpoint_role_assignments["gateway-reader"].body.properties.description == "Endpoint reader" && azapi_resource.private_endpoint_role_assignments["gateway-reader"].body.properties.conditionVersion == "2.0" && azapi_resource.private_endpoint_role_assignments["gateway-reader"].body.properties.condition == "example condition" && azapi_resource.private_endpoint_role_assignments["gateway-reader"].body.properties.delegatedManagedIdentityResourceId == var.private_endpoints.gateway.role_assignments.reader.delegated_managed_identity_resource_id
    error_message = "Endpoint assignment principal, description, condition, and delegation must not be dropped."
  }
  assert {
    condition     = azapi_resource.private_endpoint_locks["gateway"].type == var.resource_types.authorization_locks && azapi_resource.private_endpoint_role_assignments["gateway-reader"].type == var.resource_types.authorization_role_assignments && azapi_resource.private_endpoint_locks["gateway"].retry.interval_seconds == 5 && azapi_resource.private_endpoint_role_assignments["gateway-reader"].retry.interval_seconds == 5 && azapi_resource.private_endpoint_locks["gateway"].timeouts.delete == "5m" && azapi_resource.private_endpoint_role_assignments["gateway-reader"].timeouts.update == "40m"
    error_message = "Every new extension must honor API-version, retry, and timeout controls."
  }
}

run "unmanaged_dns_defaults_and_extensions" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
  }

  variables {
    tags                                    = { service = "apim" }
    private_endpoints_manage_dns_zone_group = false
    private_endpoints = {
      gateway = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/network/subnets/endpoints"
        ip_configurations = {
          gateway = {
            name               = "gateway-ip"
            private_ip_address = "10.0.0.5"
          }
        }
        lock = { kind = "ReadOnly" }
        role_assignments = {
          reader = {
            role_definition_id_or_name = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
            principal_id               = "33333333-3333-3333-3333-333333333333"
          }
        }
      }
    }
  }

  assert {
    condition     = length(azurerm_private_endpoint.this) == 0 && length(azurerm_private_endpoint.this_unmanaged_dns_zone_groups) == 1 && length(azurerm_private_endpoint.this_unmanaged_dns_zone_groups["gateway"].private_dns_zone_group) == 0
    error_message = "Unmanaged DNS must use only the existing unmanaged address and must not create a DNS zone group."
  }
  assert {
    condition     = azurerm_private_endpoint.this_unmanaged_dns_zone_groups["gateway"].resource_group_name == "apim" && azurerm_private_endpoint.this_unmanaged_dns_zone_groups["gateway"].name == "pe-apim" && azurerm_private_endpoint.this_unmanaged_dns_zone_groups["gateway"].private_service_connection[0].name == "psc-apim" && azurerm_private_endpoint.this_unmanaged_dns_zone_groups["gateway"].private_service_connection[0].subresource_names == tolist(["Gateway"]) && azurerm_private_endpoint.this_unmanaged_dns_zone_groups["gateway"].tags == var.tags
    error_message = "Existing endpoint names, resource-group fallback, service connection, and inherited tags must be preserved."
  }
  assert {
    condition     = azurerm_private_endpoint.this_unmanaged_dns_zone_groups["gateway"].ip_configuration[0].member_name == "default" && azurerm_private_endpoint.this_unmanaged_dns_zone_groups["gateway"].ip_configuration[0].subresource_name == "gateway"
    error_message = "Omitted IP member/subresource fields must use the existing defaults without unsupported-attribute errors."
  }
  assert {
    condition     = azapi_resource.private_endpoint_locks["gateway"].parent_id == azurerm_private_endpoint.this_unmanaged_dns_zone_groups["gateway"].id && azapi_resource.private_endpoint_role_assignments["gateway-reader"].parent_id == azurerm_private_endpoint.this_unmanaged_dns_zone_groups["gateway"].id && azapi_resource.private_endpoint_locks["gateway"].name == "lock-ReadOnly"
    error_message = "Unmanaged-DNS extensions must be scoped to the unmanaged endpoint."
  }
}

run "service_assignment_supported_fields" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
  }
  variables {
    role_assignments = {
      reader = {
        role_definition_id_or_name = "Reader"
        principal_id               = "33333333-3333-3333-3333-333333333333"
        principal_type             = "ServicePrincipal"
        description                = "Service reader"
      }
    }
  }
  assert {
    condition     = azurerm_role_assignment.this["reader"].description == "Service reader" && azurerm_role_assignment.this["reader"].principal_type == "ServicePrincipal" && azurerm_role_assignment.this["reader"].scope == azurerm_api_management.this.id
    error_message = "Existing service assignment addresses and permissions must retain the supported description and principal type."
  }
}

run "azapi_controls_and_telemetry_mocked" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
  }
  variables {
    enable_telemetry = true
    security = {
      enable_backend_tls13  = true
      enable_frontend_tls13 = false
    }
    retry = {
      error_message_regex = ["ScopeLocked"]
      interval_seconds    = 5
    }
    timeouts       = { create = "30m", update = "40m", delete = "5m" }
    resource_types = { apimanagement_service = "Microsoft.ApiManagement/service@2024-05-01" }
  }
  assert {
    condition     = azapi_update_resource.tls13[0].type == var.resource_types.apimanagement_service && azapi_update_resource.tls13[0].retry.interval_seconds == 5 && azapi_update_resource.tls13[0].timeouts.update == "40m"
    error_message = "TLS update must honor the consumer API version, retries, and timeouts."
  }
  assert {
    condition     = azapi_update_resource.tls13[0].body.properties.customProperties["Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls13"] == "true" && azapi_update_resource.tls13[0].body.properties.customProperties["Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls13"] == "false"
    error_message = "TLS update must preserve explicit true and false values."
  }
}

run "invalid_subnet" {
  command = plan
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
  }
  variables {
    private_endpoints = {
      gateway = { subnet_resource_id = "/not/a/subnet" }
    }
  }
  expect_failures = [var.private_endpoints]
}
