# Plan: Single Comprehensive Example for APIM Module

## Current Status

✅ **Working**: `examples/named_values/` with:
- APIM service deployed (Developer_1, Korea Central)
- System-assigned managed identity
- 5 plain text named values
- 1 Key Vault-backed named value
- Key Vault integration pattern (Bicep AVM aligned)

## Goal

Create a single `examples/complete/` that demonstrates all Phase 1-3 features incrementally on the existing APIM instance.

## Strategy: Incremental Addition (NOT replacement)

Since APIM is already provisioned (40 mins), we'll **ADD** features incrementally to avoid re-provisioning:

### Phase 1: Rename and Baseline (5 mins)
1. Rename `examples/named_values/` → `examples/complete/`
2. Update references in README
3. Commit: "chore: rename named_values example to complete"
4. Test: `terraform plan` (should show no changes)

### Phase 2: Add API Version Sets (5 mins)
1. Add `api_version_sets` configuration to existing `main.tf`
2. Test: `terraform apply` (creates version sets only)
3. Estimated time: 1-2 minutes
4. Commit: "feat(example): add API version sets to complete example"

### Phase 3: Add APIs (10-15 mins)
1. Add `apis` configuration with operations
2. Include examples:
   - REST API with CRUD operations
   - Linked to version set
   - Sample request/response schemas
3. Test: `terraform apply` (creates APIs)
4. Estimated time: 2-3 minutes
5. Commit: "feat(example): add APIs with operations to complete example"

### Phase 4: Add Service-Level Policies (5 mins)
1. Add `policies` configuration
2. Include rate limiting, CORS, headers
3. Test: `terraform apply` (creates policies)
4. Estimated time: 1-2 minutes
5. Commit: "feat(example): add service-level policies to complete example"

### Phase 5: Documentation Update (10 mins)
1. Update `README.md` with all features
2. Update `DEPLOYMENT_GUIDE.md` with new sections
3. Add examples of each feature
4. Commit: "docs(example): update complete example documentation"

## File Structure

```
examples/complete/
├── main.tf                    # All APIM configuration
├── outputs.tf                 # All outputs
├── variables.tf               # Variables with defaults
├── README.md                  # Feature overview + quick start
├── DEPLOYMENT_GUIDE.md        # Step-by-step deployment
└── terraform.tfvars.example   # Sample configuration
```

## Configuration Sections in main.tf

```terraform
module "apim" {
  source = "../../"
  
  # Basic configuration
  name                = ...
  location            = ...
  resource_group_name = ...
  sku_name            = "Developer_1"
  
  # Phase 1: Named Values (EXISTING)
  named_values = { ... }
  
  # Phase 2: API Version Sets (NEW)
  api_version_sets = {
    "products-api" = {
      display_name      = "Products API"
      versioning_scheme = "Segment"
      description       = "Product management API with versioning"
    }
  }
  
  # Phase 3: APIs with Operations (NEW)
  apis = {
    "products-v1" = {
      display_name      = "Products API v1"
      path              = "products"
      protocols         = ["https"]
      revision          = "1"
      api_version       = "v1"
      api_version_set_id = "products-api"
      
      operations = {
        "get-products" = {
          display_name = "Get Products"
          method       = "GET"
          url_template = "/"
        }
        "create-product" = {
          display_name = "Create Product"
          method       = "POST"
          url_template = "/"
        }
      }
    }
  }
  
  # Phase 4: Service-Level Policies (NEW)
  policies = [
    {
      xml_content = <<-XML
        <policies>
          <inbound>
            <rate-limit calls="100" renewal-period="60" />
            <cors allow-credentials="false">
              <allowed-origins>
                <origin>*</origin>
              </allowed-origins>
            </cors>
          </inbound>
          <backend>
            <forward-request />
          </backend>
        </policies>
      XML
    }
  ]
  
  # Identity
  managed_identities = {
    system_assigned = true
  }
}
```

## Testing Strategy

### After Each Phase

```bash
# 1. Validate
terraform validate

# 2. Plan (check for unexpected changes)
terraform plan

# 3. Apply (should only add new resources)
terraform apply

# 4. Verify in Portal
# - Check resources created
# - Test APIs if applicable

# 5. Commit with clear message
git add .
git commit -m "feat(example): add [feature] to complete example"
```

### Key Validations

- ✅ No APIM re-provisioning (check plan output)
- ✅ Only new resources created (version sets, APIs, policies)
- ✅ Existing named values unchanged
- ✅ Terraform state remains consistent
- ✅ Each addition takes < 5 minutes

## Risk Mitigation

### What Could Go Wrong

1. **APIM gets replaced**: 
   - Cause: Changing immutable properties
   - Prevention: Only ADD properties, never modify name/location/sku_name
   - Recovery: Would require 40 min re-provision

2. **Circular dependencies**: 
   - Cause: Cross-references between new features
   - Prevention: Test each phase independently
   - Recovery: Remove problematic resource, re-apply

3. **Named values stop working**:
   - Cause: Changes to managed_identities
   - Prevention: Don't modify identity configuration
   - Recovery: Already have working pattern documented

### Rollback Strategy

Each phase is independently committable:

```bash
# If phase fails, revert last commit
git reset --hard HEAD~1

# State should automatically sync
terraform plan  # Should show no changes after revert
```

## Timeline Estimate

| Phase | Activity | Time | Cumulative |
|-------|----------|------|------------|
| 1 | Rename example | 5 min | 5 min |
| 2 | Add version sets | 5 min | 10 min |
| 3 | Add APIs | 15 min | 25 min |
| 4 | Add policies | 5 min | 30 min |
| 5 | Update docs | 10 min | 40 min |

**Total: ~40 minutes** (plus Terraform apply times of 5-10 min total)

## Success Criteria

After completion:

- ✅ Single `examples/complete/` demonstrates all Phase 1-3 features
- ✅ All features working on existing APIM instance
- ✅ Clear documentation for each feature
- ✅ Deployment guide covers all scenarios
- ✅ No APIM re-provisioning occurred
- ✅ Each feature independently tested and committed

## Next Steps After This Plan

1. **Commit current state** with named_values example
2. **Start Phase 1**: Rename to complete
3. **Proceed incrementally** through phases 2-5
4. **Test thoroughly** at each step
5. **Keep existing APIM instance** throughout

## Alternative: Conservative Approach

If any phase shows risk of APIM replacement:

1. Stop immediately
2. Test feature in separate example first
3. Verify with `terraform plan -out=plan.out`
4. Review plan file carefully: `terraform show plan.out`
5. Only proceed if plan shows additions only

## Questions to Decide

1. **API example complexity**: Simple CRUD or realistic e-commerce scenario?
   - Recommendation: Simple CRUD (can expand later)

2. **Number of APIs**: 1-2 or more?
   - Recommendation: 2 (one for v1, one for v2 to show versioning)

3. **Policy complexity**: Basic or advanced?
   - Recommendation: Basic (rate limit + CORS) for main example

4. **OpenAPI import**: Include or skip?
   - Recommendation: Skip for complete example, create separate example later

## Ready to Proceed?

Once you approve this plan, we'll:

1. Commit current `named_values` example
2. Start Phase 1 (rename)
3. Incrementally add features
4. Test at each step
5. Commit after each successful phase

This approach minimizes risk and keeps the working APIM instance throughout! 🚀
