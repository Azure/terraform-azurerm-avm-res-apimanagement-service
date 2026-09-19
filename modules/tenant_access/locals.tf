locals {
  main_location = ""
  resource_body = {
    properties = contains(var.ignore_body_changes.apimanagement_service_tenant, "properties") || contains(var.ignore_body_changes.apimanagement_service_tenant, "properties.enabled") ? {} : {
      enabled = var.enabled
    }
  }
  resource_id = "${var.parent_id}/tenant/${var.name}"
}
