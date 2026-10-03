output "name" {
  description = "The name of the diagnostic."
  value       = var.name
}

output "resource_id" {
  description = "The resource ID of the diagnostic."
  value       = azapi_resource_action.put.id
}
