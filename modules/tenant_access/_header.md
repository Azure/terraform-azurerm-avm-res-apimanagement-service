# API Management tenant access

This submodule manages the API Management tenant access singleton (`Microsoft.ApiManagement/service/tenant/access`) using the AzAPI provider.

Azure does not expose a delete operation for this setting, so removing the submodule from configuration stops managing tenant access without resetting its current Azure value.
