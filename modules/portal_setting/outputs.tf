output "name" {
  description = "The singleton portal setting name."
  value       = var.name
}

output "resource_id" {
  description = "The resource ID of the portal setting."
  value       = local.resource_id
}

output "settings" {
  description = "The non-secret portal setting configuration."
  value = {
    enabled                   = var.enabled
    subscriptions_enabled     = var.subscriptions_enabled
    terms_of_service          = var.terms_of_service
    url                       = var.url
    user_registration_enabled = var.user_registration_enabled
  }
}
