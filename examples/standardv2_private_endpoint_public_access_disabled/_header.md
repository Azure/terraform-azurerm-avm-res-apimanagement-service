# StandardV2 private endpoint (public access disabled) example

This deploys an API Management `StandardV2` instance with a private endpoint and `public_network_access_enabled = false`, resulting in a fully closed service from a single `terraform apply`.

`StandardV2` (and other v2 SKUs) cannot be created with public network access already disabled — the resource provider rejects it (`ActivateServiceWithPrivateEndpointAccessNotAllowed`). To reach the secure-by-default end state, the module creates the service with public access enabled, provisions the private endpoint, and then disables public network access via an ordered post-creation update. This example targets compliance-bound landing zones where Azure Policy requires private-only access, and acts as the regression guard for that orchestration.
