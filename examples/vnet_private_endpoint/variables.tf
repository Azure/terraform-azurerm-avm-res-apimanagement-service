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
  default     = "eastus2"
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "publisher_email" {
  type        = string
  default     = "admin@contoso.com"
  description = "The email address of the publisher."
}

variable "subscription_id" {
  type        = string
  default     = null
  description = "The Azure subscription ID. If not provided, the provider will use the default subscription."
}
