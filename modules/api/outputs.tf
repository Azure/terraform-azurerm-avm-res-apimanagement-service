output "api_revision" {
  description = "The API revision."
  value       = try(azapi_resource.this.output.properties.apiRevision, null)
}

output "api_type" {
  description = "The API type."
  value       = try(azapi_resource.this.output.properties.apiType, null)
}

output "api_version" {
  description = "The API version identifier."
  value       = try(azapi_resource.this.output.properties.apiVersion, null)
}

output "api_version_set_id" {
  description = "The related API version set resource ID."
  value       = try(azapi_resource.this.output.properties.apiVersionSetId, null)
}

output "display_name" {
  description = "The API display name."
  value       = try(azapi_resource.this.output.properties.displayName, null)
}

output "is_current" {
  description = "Whether this revision is the current API revision."
  value       = try(azapi_resource.this.output.properties.isCurrent, null)
}

output "is_online" {
  description = "Whether this API revision is accessible via the gateway."
  value       = try(azapi_resource.this.output.properties.isOnline, null)
}

output "name" {
  description = "The name of the API resource (may include `;rev=`)."
  value       = azapi_resource.this.name
}

output "path" {
  description = "The relative URL path of the API."
  value       = try(azapi_resource.this.output.properties.path, null)
}

output "protocols" {
  description = "Protocols supported by the API."
  value       = try(azapi_resource.this.output.properties.protocols, null)
}

output "provisioning_state" {
  description = "The provisioning state of the API."
  value       = try(azapi_resource.this.output.properties.provisioningState, null)
}

output "resource_id" {
  description = "The resource ID of the API."
  value       = azapi_resource.this.id
}

output "service_url" {
  description = "The backend service URL of the API."
  value       = try(azapi_resource.this.output.properties.serviceUrl, null)
}

output "subscription_required" {
  description = "Whether a subscription is required to access the API."
  value       = try(azapi_resource.this.output.properties.subscriptionRequired, null)
}
