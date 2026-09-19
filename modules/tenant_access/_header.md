# API Management tenant access

This submodule manages the API Management tenant access singleton (`Microsoft.ApiManagement/service/tenant/access`) using the AzAPI provider.

Azure does not expose a delete operation for this setting, so removing the submodule from configuration stops managing tenant access without resetting its current Azure value.

The submodule does not call `listSecrets`; tenant-access keys are not read into Terraform state. Because AzAPI does not expose `ignore_body_changes` on update resources, supported ignored paths are omitted from the PATCH request.
