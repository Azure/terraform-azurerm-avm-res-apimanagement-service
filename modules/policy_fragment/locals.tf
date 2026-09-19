locals {
  resource_body = {
    properties = {
      description = var.description
      format      = var.format
      value       = var.value
    }
  }
  main_location = "unknown"
}
