variable "azure_region" {
  type        = string
  default     = null
  description = "The Azure region to deploy resources into. If not specified, a random region will be selected from available Azure regions."
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
