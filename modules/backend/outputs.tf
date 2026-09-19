output "backend_resource_id" {
  description = "The external system resource ID configured on the backend."
  value       = var.resource_id
}

output "backend_type" {
  description = "The backend type (`Single` or `Pool`)."
  value       = var.type
}

output "description" {
  description = "The backend description."
  value       = var.description
}

output "name" {
  description = "The name of the backend."
  value       = azapi_resource.this.name
}

output "protocol" {
  description = "The backend protocol."
  value       = var.protocol
}

output "resource_id" {
  description = "The resource ID of the backend."
  value       = azapi_resource.this.id
}

output "title" {
  description = "The backend title."
  value       = var.title
}

output "url" {
  description = "The backend URL."
  value       = var.url
}
