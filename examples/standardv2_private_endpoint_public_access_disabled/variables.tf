variable "publisher_email" {
  type        = string
  description = "The email address of the publisher."
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

variable "location" {
  type        = string
  default     = "germanywestcentral"
  description = "Azure region where the resource should be deployed. Pinned to a region with StandardV2 availability."
  nullable    = false
}
