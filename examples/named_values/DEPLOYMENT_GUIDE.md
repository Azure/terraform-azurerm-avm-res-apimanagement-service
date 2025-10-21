# Named Values with Key Vault Integration - Deployment Guide

## Overview

This example demonstrates API Management named values with Key Vault integration, following the **Azure Verified Modules (AVM) Bicep pattern** for access policy management.

## Why This Pattern?

The Bicep AVM module delegates Key Vault access policy management to users rather than handling it within the module. We follow the same pattern for consistency across AVM modules (both Bicep and Terraform).

### Benefits

- ✅ **Avoids circular dependencies** in Terraform
- ✅ **Aligns with AVM Bicep module design**
- ✅ **Provides deployment flexibility**
- ✅ **Clear separation of concerns**

## Quick Start: Two-Step Deployment

This is the recommended approach for first-time deployment.

### Step 1: Deploy APIM Infrastructure

Comment out the Key Vault-backed named value in `main.tf`:

```terraform
# Comment this block:
# "database-connection-string" = {
#   display_name = "Database-Connection-String"
#   secret       = true
#   value_from_key_vault = {
#     secret_id = azurerm_key_vault_secret.db_connection.versionless_id
#   }
#   tags = ["database", "secret", "keyvault"]
# }
```

Deploy:

```bash
terraform init
terraform apply
```

**⏱️ Note**: APIM provisioning takes ~40 minutes for Developer tier.

### Step 2: Grant Key Vault Access

After APIM is created, grant access to its system-assigned identity:

```bash
az keyvault set-policy \
  --name $(terraform output -raw key_vault_name) \
  --object-id $(terraform output -raw apim_identity_principal_id) \
  --secret-permissions get list
```

Verify access was granted:

```bash
az keyvault show --name $(terraform output -raw key_vault_name) \
  --query "properties.accessPolicies[?objectId=='$(terraform output -raw apim_identity_principal_id)'].permissions"
```

### Step 3: Deploy Key Vault-Backed Named Value

Uncomment the `database-connection-string` named value in `main.tf` and apply:

```bash
terraform apply
```

This adds the Key Vault-backed named value (takes ~2-3 minutes).

## Alternative: Automated Access Policy (Advanced)

If you prefer Terraform to manage the access policy, uncomment the `azurerm_key_vault_access_policy` resource in `main.tf`.

**Note**: This still requires the two-step deployment due to Terraform's dependency resolution:

1. Comment out KV named value → `terraform apply`
2. Uncomment KV named value → `terraform apply`

## Comparison with Other Patterns

| Pattern | Pros | Cons | Use Case |
|---------|------|------|----------|
| **Two-Step CLI** (This example) | Clean separation, no circular deps, matches Bicep AVM | Manual CLI step | First-time setup, learning |
| **Terraform Access Policy** (Commented in example) | Fully automated infrastructure, version controlled | Still needs two applies, circular dependency | Production pipelines |
| **User-Assigned Identity** (LZA pattern) | True single-apply, production-ready | More complex example | Enterprise deployments |

## Troubleshooting

### Error: "The caller does not have permission to request secret"

**Cause**: Key Vault access policy not granted to APIM identity.

**Solution**:

```bash
# Verify APIM identity exists
terraform output apim_identity_principal_id

# Grant access
az keyvault set-policy \
  --name $(terraform output -raw key_vault_name) \
  --object-id $(terraform output -raw apim_identity_principal_id) \
  --secret-permissions get list
```

### Error: "Cycle: module.apim → azurerm_key_vault_access_policy.apim"

**Cause**: Terraform circular dependency between APIM and access policy.

**Solution**: Use two-step deployment (comment out KV named value for first apply).

### Named Value Shows as "Not Resolved"

**Cause**: APIM cannot access the Key Vault secret.

**Solution**:

1. Verify access policy exists
2. Check secret exists in Key Vault
3. Verify secret_id is correct (use versionless ID)

## Outputs for CLI Commands

This example provides helpful outputs for the CLI approach:

```bash
# Get APIM identity
terraform output apim_identity_principal_id

# Get Key Vault name
terraform output key_vault_name

# Get Key Vault ID
terraform output key_vault_id
```

## Production Considerations

For production deployments, consider:

1. **User-Assigned Identity**: Create identity separately and grant access before APIM deployment
2. **Azure RBAC**: Use Key Vault RBAC instead of access policies (set `enableRbacAuthorization = true`)
3. **Automation**: Use CI/CD pipelines with proper sequencing
4. **Secret Rotation**: Use Key Vault secret versions and update named values accordingly

## References

- [Bicep AVM APIM Module](https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/api-management/service)
- [APIM Landing Zone Accelerator](https://github.com/Azure/apim-landing-zone-accelerator)
- [APIM Named Values Documentation](https://learn.microsoft.com/azure/api-management/api-management-howto-properties)
