# Complete Example

This example demonstrates the core features of the Azure API Management module, including APIs with operations, weighted backend pools, policy fragments, products, subscriptions, named values, policies, developer portal settings, and tenant access configuration.

Set `key_vault_secret_identifier` to demonstrate a Key Vault-backed named value after granting the API Management managed identity access to that secret. Optional custom subscription keys are accepted through sensitive variables and sent write-only; omit them to let Azure generate the keys. Generated subscription and tenant-access keys are not read into Terraform state.
