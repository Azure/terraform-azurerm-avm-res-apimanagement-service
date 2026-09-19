locals {
  # Secret values are write-only and must not live in `body` (or Terraform state).
  use_sensitive_value = var.secret == true && nonsensitive(var.value != null)

  resource_body = {
    properties = {
      displayName = var.display_name
      keyVault = var.key_vault == null ? null : {
        identityClientId = var.key_vault.identity_client_id
        secretIdentifier = var.key_vault.secret_identifier
      }
      secret = var.secret
      tags   = var.named_value_tags
      value  = local.use_sensitive_value ? null : var.value
    }
  }

  sensitive_body_version = !local.use_sensitive_value ? null : {
    "properties.value" = sha256(var.value)
  }
  main_location = "unknown"
}
