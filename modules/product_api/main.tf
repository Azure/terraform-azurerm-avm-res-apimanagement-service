# APIM does not support a single-resource GET/PUT for product-API
# associations (405 Method Not Allowed), so `azapi_resource` cannot
# manage this type. Use resource actions instead: an idempotent PUT on
# apply and a DELETE on destroy.
# TFFR8 (avm_interface_ignore_body_changes) does not apply: `azapi_resource_action`
# has no `ignore_body_changes` argument (AzAPI 2.x), so this action-only module has no
# resource the TFFR8 variable could be applied to.
# tflint-ignore: avm_interface_ignore_body_changes
resource "azapi_resource_action" "associate" {
  type                   = var.resource_types.apimanagement_service_products_apis
  resource_id            = format("%s/apis/%s", var.parent_id, var.name)
  method                 = "PUT"
  body                   = {}
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

resource "azapi_resource_action" "disassociate" {
  type                   = var.resource_types.apimanagement_service_products_apis
  resource_id            = format("%s/apis/%s", var.parent_id, var.name)
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
