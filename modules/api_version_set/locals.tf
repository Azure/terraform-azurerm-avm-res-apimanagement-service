locals {
  resource_body = {
    properties = {
      description       = var.description
      displayName       = var.display_name
      versionHeaderName = var.version_header_name
      versionQueryName  = var.version_query_name
      versioningScheme  = var.versioning_scheme
    }
  }
  main_location = "unknown"
}
