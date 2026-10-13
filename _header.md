# terraform-azurerm-avm-res-apimanagement-service

This repo deploys the base Azure API management service.  

Private endpoint resource-group overrides, static IP member names, role assignments, and locks are applied in both managed and externally managed DNS modes. Existing Terraform resource addresses are unchanged. Upgrading configurations that already specify private endpoint role assignments or locks now creates those previously ignored extension resources. An existing endpoint whose resource-group override was previously ignored may be replaced to honor that override; review the upgrade plan before applying.

Example preparation maps a configured `TF_VAR_PUBLISHER_EMAIL` to Terraform's case-sensitive `TF_VAR_publisher_email` through an ignored `.env` file. Explicit lowercase inputs are preserved; no publisher email is supplied by default.

> [!IMPORTANT]
> As the overall AVM framework is not GA (generally available) yet - the CI framework and test automation is not fully functional and implemented across all supported languages yet - breaking changes are expected, and additional customer feedback is yet to be gathered and incorporated. Hence, modules **MUST NOT** be published at version `1.0.0` or higher at this time.
> 
> All module **MUST** be published as a pre-release version (e.g., `0.1.0`, `0.1.1`, `0.2.0`, etc.) until the AVM framework becomes GA.
> 
> However, it is important to note that this **DOES NOT** mean that the modules cannot be consumed and utilized. They **CAN** be leveraged in all types of environments (dev, test, prod etc.). Consumers can treat them just like any other IaC module and raise issues or feature requests against them as they learn from the usage of the module. Consumers should also read the release notes for each version, if considering updating to a more recent version of a module to see if there are any considerations or breaking changes etc.
