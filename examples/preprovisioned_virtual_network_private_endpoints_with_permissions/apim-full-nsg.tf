resource "azurerm_network_security_group" "apim_nsg" {
  location            = azurerm_resource_group.this.location
  name                = "apim-nsg"
  resource_group_name = azurerm_resource_group.this.name
}

# Inbound Rules
resource "azurerm_network_security_rule" "inbound_internet_http_https" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "allow-internet-http-https"
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
  priority                    = 100
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "VirtualNetwork"
  destination_port_ranges     = ["80", "443"]
  source_address_prefix       = "Internet"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "inbound_apimgmt_management" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "allow-apimgmt-management"
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
  priority                    = 110
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "VirtualNetwork"
  destination_port_range      = "3443"
  source_address_prefix       = "ApiManagement"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "inbound_azure_lb" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "allow-azure-lb"
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
  priority                    = 120
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "VirtualNetwork"
  destination_port_range      = "6390"
  source_address_prefix       = "AzureLoadBalancer"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "inbound_azure_tm" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "allow-azure-traffic-manager"
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
  priority                    = 130
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "VirtualNetwork"
  destination_port_range      = "443"
  source_address_prefix       = "AzureTrafficManager"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "inbound_azure_lb_monitoring" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "allow-azure-lb-monitoring"
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
  priority                    = 140
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "VirtualNetwork"
  destination_port_range      = "6391"
  source_address_prefix       = "AzureLoadBalancer"
  source_port_range           = "*"
}

# Outbound Rules
resource "azurerm_network_security_rule" "outbound_storage" {
  access                      = "Allow"
  direction                   = "Outbound"
  name                        = "allow-storage"
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
  priority                    = 200
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "Storage"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "outbound_aad" {
  access                      = "Allow"
  direction                   = "Outbound"
  name                        = "allow-aad"
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
  priority                    = 210
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "AzureActiveDirectory"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "outbound_azure_connectors" {
  access                      = "Allow"
  direction                   = "Outbound"
  name                        = "allow-azure-connectors"
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
  priority                    = 220
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "AzureConnectors"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "outbound_sql" {
  access                      = "Allow"
  direction                   = "Outbound"
  name                        = "allow-sql"
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
  priority                    = 230
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "Sql"
  destination_port_range      = "1433"
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "outbound_key_vault" {
  access                      = "Allow"
  direction                   = "Outbound"
  name                        = "allow-key-vault"
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
  priority                    = 240
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "AzureKeyVault"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "outbound_event_hub" {
  access                      = "Allow"
  direction                   = "Outbound"
  name                        = "allow-event-hub"
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
  priority                    = 250
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "EventHub"
  destination_port_ranges     = ["5671", "5672", "443"]
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "outbound_file_storage" {
  access                      = "Allow"
  direction                   = "Outbound"
  name                        = "allow-file-storage"
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
  priority                    = 260
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "Storage"
  destination_port_range      = "445"
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "outbound_azure_monitor" {
  access                      = "Allow"
  direction                   = "Outbound"
  name                        = "allow-azure-monitor"
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
  priority                    = 270
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "AzureMonitor"
  destination_port_ranges     = ["1886", "443"]
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
}

# Inbound & Outbound Rules for Redis and Sync
resource "azurerm_network_security_rule" "inbound_redis_external" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "allow-redis-external-inbound"
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
  priority                    = 300
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "VirtualNetwork"
  destination_port_range      = "6380"
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "outbound_redis_external" {
  access                      = "Allow"
  direction                   = "Outbound"
  name                        = "allow-redis-external-outbound"
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
  priority                    = 310
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "VirtualNetwork"
  destination_port_range      = "6380"
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "inbound_redis_internal" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "allow-redis-internal-inbound"
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
  priority                    = 320
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "VirtualNetwork"
  destination_port_range      = "6381-6383"
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "outbound_redis_internal" {
  access                      = "Allow"
  direction                   = "Outbound"
  name                        = "allow-redis-internal-outbound"
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
  priority                    = 330
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "VirtualNetwork"
  destination_port_range      = "6381-6383"
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "inbound_sync_counters" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "allow-sync-counters-inbound"
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
  priority                    = 340
  protocol                    = "Udp"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "VirtualNetwork"
  destination_port_range      = "4290"
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "outbound_sync_counters" {
  access                      = "Allow"
  direction                   = "Outbound"
  name                        = "allow-sync-counters-outbound"
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
  priority                    = 350
  protocol                    = "Udp"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "VirtualNetwork"
  destination_port_range      = "4290"
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
}

# Associate NSG with the APIM subnet
resource "azurerm_subnet_network_security_group_association" "apim" {
  network_security_group_id = azurerm_network_security_group.apim_nsg.id
  subnet_id                 = azurerm_subnet.apim_subnet.id
}
