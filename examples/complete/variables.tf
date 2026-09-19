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

variable "key_vault_secret_identifier" {
  type        = string
  default     = null
  description = "Optional Key Vault secret identifier for the named-value example. The APIM managed identity must have permission to read the secret. Use an unversioned identifier for automatic refresh or a versioned identifier to pin a version."
}

variable "named_value_secret" {
  type        = string
  default     = null
  description = "Optional inline secret for the named-value example."
  sensitive   = true
}

variable "subscription_primary_key" {
  type        = string
  default     = null
  description = "Optional custom primary key for the starter subscription. When omitted, Azure generates the key."
  sensitive   = true
}

variable "subscription_secondary_key" {
  type        = string
  default     = null
  description = "Optional custom secondary key for the starter subscription. When omitted, Azure generates the key."
  sensitive   = true
}
