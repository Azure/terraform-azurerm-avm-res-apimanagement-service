# API Management portal setting

This submodule manages an API Management developer portal singleton setting (`Microsoft.ApiManagement/service/portalsettings`) using the AzAPI provider.

The supported singleton names are `delegation`, `signin`, and `signup`. Azure does not expose a delete operation for these settings, so removing the submodule from configuration stops managing the setting without resetting its current Azure value.
