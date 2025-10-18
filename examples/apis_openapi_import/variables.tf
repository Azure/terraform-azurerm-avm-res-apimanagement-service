variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "location" {
  type        = string
  description = "Azure region where the resources should be deployed."
  default     = "East US"
}

variable "publisher_email" {
  type        = string
  description = "The email address of the owner of the API Management service."
  default     = "admin@example.com"
}

variable "publisher_name" {
  type        = string
  description = "The name of the owner of the API Management service."
  default     = "Contoso"
}

variable "sku_name" {
  type        = string
  description = "The SKU name of the API Management service. Valid values: Consumption, Developer_1, Basic_1, Basic_2, Standard_1, Standard_2, Premium_1, Premium_2, etc."
  default     = "Developer_1"
}
