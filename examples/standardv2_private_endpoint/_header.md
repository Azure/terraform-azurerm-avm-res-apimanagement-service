# StandardV2 private endpoint (secure-by-default) example

This deploys an API Management `StandardV2` instance with a private endpoint and `public_network_access_enabled = false` set from the very first apply (no enable-then-disable workaround).

It targets compliance-bound landing zones where Azure Policy blocks creating services that have public network access enabled. If the platform/provider rejects creating a `StandardV2` instance fully closed before the private endpoint exists, this example documents that limitation; once the capability is supported it becomes the regression guard.
