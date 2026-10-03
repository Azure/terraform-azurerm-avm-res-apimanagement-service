# APIM auto-creates the `azuremonitor` diagnostic when the service is
# provisioned, and `azapi_resource` refuses to adopt server-created
# resources (it pre-GETs the resource and fails with "Resource already
# exists"). Use resource actions instead: an idempotent PUT upsert on
# apply and a DELETE on destroy.
# TFFR8 (avm_interface_ignore_body_changes) does not apply: `azapi_resource_action`
# has no `ignore_body_changes` argument (AzAPI 2.x), so this action-only module has no
# resource the TFFR8 variable could be applied to.
# tflint-ignore: avm_interface_ignore_body_changes
resource "azapi_resource_action" "put" {
  type                   = var.resource_types.apimanagement_service_diagnostics
  resource_id            = format("%s/diagnostics/%s", var.parent_id, var.name)
  method                 = "PUT"
  body                   = local.resource_body
  response_export_values = []

  retry = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azapi_resource_action" "delete" {
  type                   = var.resource_types.apimanagement_service_diagnostics
  resource_id            = format("%s/diagnostics/%s", var.parent_id, var.name)
  method                 = "DELETE"
  when                   = "destroy"
  response_export_values = []

  ignore_not_found = true

  retry = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}
