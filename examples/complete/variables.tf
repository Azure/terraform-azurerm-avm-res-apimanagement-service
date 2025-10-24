variable "subscription_id" {
  type        = string
  description = "The Azure subscription ID to deploy resources into."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg-apim"
  description = "The prefix to use for the resource group name. If not specified, the naming module will generate a unique name. Set to empty string to use only the naming module suffix."
}

variable "azure_region" {
  type        = string
  default     = null
  description = "The Azure region to deploy resources into. If not specified, a random region will be selected from available Azure regions."
}
