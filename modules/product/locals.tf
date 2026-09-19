locals {
  resource_body = {
    properties = {
      for k, v in {
        approvalRequired     = var.approval_required
        description          = var.description
        displayName          = var.display_name
        state                = var.state
        subscriptionRequired = var.subscription_required
        subscriptionsLimit   = var.subscriptions_limit
        terms                = var.terms
      } : k => v if v != null
    }
  }
  main_location = "unknown"
}
