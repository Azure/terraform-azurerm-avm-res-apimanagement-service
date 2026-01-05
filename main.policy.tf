# API Management Service-Level Policy
# This file implements the service-level (global) policy

# Service-Level Policy - applies to all APIs
resource "azurerm_api_management_policy" "this" {
  count = var.policy != null ? 1 : 0

  api_management_id = azurerm_api_management.this.id
  xml_content       = var.policy.xml_content

  depends_on = [azurerm_api_management.this]
}
