locals {
  # Credentials are write-only: APIM returns the connection string in plain text and the
  # identity client ID as a generated `{{named-value}}` placeholder, so neither is read back.
  credentials = merge(
    nonsensitive(var.connection_string != null) ? { connectionString = var.connection_string } : {},
    var.identity_client_id == null ? {} : { identityClientId = var.identity_client_id },
  )
  main_location = "unknown"
  resource_body = {
    properties = merge(
      { loggerType = var.logger_type },
      var.description == null ? {} : { description = var.description },
      var.is_buffered == null ? {} : { isBuffered = var.is_buffered },
      var.resource_id == null ? {} : { resourceId = var.resource_id },
    )
  }
  sensitive_body = length(local.credentials) == 0 ? null : {
    properties = {
      credentials = local.credentials
    }
  }
}
