# PR 1: Core API Management - Phased Task Breakdown

## Overview

This document provides a comprehensive, phased approach to implementing **PR 1: Core API Management** features for the Azure Verified Modules (AVM) Terraform module for API Management. This PR achieves feature parity with the Bicep AVM module for APIs, Products, Subscriptions, Named Values, and Policies.

---

## Phase 1: Foundation & Planning
**Goal:** Set up structure and understand requirements

### Task 1.1: Research & Schema Analysis

- [ ] Review Bicep module implementation for APIs, Products, Subscriptions, Named Values
- [ ] Study azurerm provider documentation for:
  - `azurerm_api_management_api`
  - `azurerm_api_management_api_operation`
  - `azurerm_api_management_api_policy`
  - `azurerm_api_management_api_operation_policy`
  - `azurerm_api_management_api_version_set`
  - `azurerm_api_management_product`
  - `azurerm_api_management_subscription`
  - `azurerm_api_management_named_value`
  - `azurerm_api_management_policy`
  - `azurerm_api_management_product_api`
  - `azurerm_api_management_product_group`
- [ ] Document resource dependencies and relationships
- [ ] Identify required vs optional properties for each resource

### Task 1.2: Design Variable Structure

- [ ] Design `api_version_sets` variable object structure (versioning schemes)
- [ ] Design `apis` variable object structure (imports, OpenAPI, SOAP, GraphQL support)
- [ ] Design `products` variable object structure
- [ ] Design `subscriptions` variable object structure
- [ ] Design `named_values` variable object structure (including Key Vault integration)
- [ ] Design `policies` variable object structure (service-level and API-level)
- [ ] Create variable validation rules for each resource type
- [ ] Document variable examples for common scenarios

---

## Phase 2: Named Values Implementation
**Goal:** Implement configuration and secrets management (foundation for other resources)

### Task 2.1: Named Values Resource
- [ ] Create `main.namedvalues.tf` file
- [ ] Implement `azurerm_api_management_named_value` resource with dynamic blocks
- [ ] Add support for plain text values
- [ ] Add support for Key Vault secret references
- [ ] Add support for tags and filtering
- [ ] Implement proper depends_on for APIM service

### Task 2.2: Named Values Variables & Outputs
- [ ] Add `named_values` variable to `variables.tf`
- [ ] Add validation for naming conventions
- [ ] Add validation for Key Vault integration requirements
- [ ] Add named values outputs to `outputs.tf` (resource IDs, display names)

### Task 2.3: Named Values Testing
- [ ] Create example in `examples/named_values/`
- [ ] Test plain text named values
- [ ] Test Key Vault integration
- [ ] Test tags and filtering
- [ ] Run AVM pre-commit checks
- [ ] Run AVM PR checks

---

## Phase 2.5: API Version Sets Implementation
**Goal:** Enable API versioning support (required for APIs to reference version sets)

### Task 2.5.1: API Version Sets Resource
- [ ] Create `main.apiversionsets.tf` file
- [ ] Implement `azurerm_api_management_api_version_set` resource
- [ ] Add support for versioning schemes (Header, Query, Segment)
- [ ] Add support for version header name (for Header scheme)
- [ ] Add support for version query name (for Query scheme)
- [ ] Add proper depends_on for APIM service

### Task 2.5.2: API Version Sets Variables & Outputs
- [ ] Add `api_version_sets` variable to `variables.tf`
- [ ] Add validation for versioning scheme values
- [ ] Add validation for header/query name requirements based on scheme
- [ ] Add API version set outputs (resource IDs, names)

### Task 2.5.3: API Version Sets Testing
- [ ] Create example in `examples/api_version_sets/`
- [ ] Test Header-based versioning
- [ ] Test Query-based versioning
- [ ] Test Segment-based versioning
- [ ] Run AVM pre-commit checks
- [ ] Run AVM PR checks

---

## Phase 3: APIs Implementation
**Goal:** Core API management with operations and OpenAPI import

### Task 3.1: API Resources - Basic
- [ ] Create `main.apis.tf` file
- [ ] Implement `azurerm_api_management_api` resource
- [ ] Add support for REST API creation
- [ ] Add support for API versioning and revisions
- [ ] Add support for API version sets linkage
- [ ] Add support for protocols (HTTP/HTTPS)
- [ ] Add support for subscription requirements

### Task 3.2: API Resources - Import Formats
- [ ] Add OpenAPI/Swagger import support
- [ ] Add OpenAPI JSON import support
- [ ] Add WSDL import support (SOAP)
- [ ] Add WADL import support
- [ ] Add support for import from URL vs inline content
- [ ] Handle format-specific configurations

### Task 3.3: API Operations
- [ ] Implement `azurerm_api_management_api_operation` resource
- [ ] Add support for HTTP methods (GET, POST, PUT, DELETE, etc.)
- [ ] Add support for URL templates with parameters
- [ ] Add support for request/response schemas
- [ ] Add support for operation descriptions

### Task 3.4: API Policies

- [ ] Implement `azurerm_api_management_api_policy` resource for API-level policies
- [ ] Implement `azurerm_api_management_api_operation_policy` resource for operation-level policies
- [ ] Add support for XML policy content
- [ ] Add support for policy format types (xml, rawxml, xml-link, rawxml-link)
- [ ] Add support for operation-level policies (using separate resource)
- [ ] Add common policy templates/examples

### Task 3.5: APIs Variables & Outputs
- [ ] Add `apis` variable to `variables.tf`
- [ ] Add validation for API naming and paths
- [ ] Add validation for import formats
- [ ] Add API outputs (resource IDs, URLs, gateway URLs)
- [ ] Add operation outputs

### Task 3.6: APIs Testing
- [ ] Create example in `examples/apis_basic/`
- [ ] Create example in `examples/apis_openapi_import/`
- [ ] Create example in `examples/apis_with_operations/`
- [ ] Create example in `examples/apis_with_policies/`
- [ ] Test all import formats
- [ ] Test versioning and revisions
- [ ] Run AVM pre-commit checks
- [ ] Run AVM PR checks

---

## Phase 4: Products Implementation
**Goal:** API grouping and monetization

### Task 4.1: Product Resources
- [ ] Create `main.products.tf` file
- [ ] Implement `azurerm_api_management_product` resource
- [ ] Add support for product visibility (public/private)
- [ ] Add support for subscription requirements
- [ ] Add support for approval workflows
- [ ] Add support for terms of use
- [ ] Add support for product state (published/not published)

### Task 4.2: Product-API Associations
- [ ] Implement `azurerm_api_management_product_api` resource
- [ ] Handle dynamic linking based on product configuration
- [ ] Add proper dependency management

### Task 4.3: Product-Group Associations
- [ ] Implement `azurerm_api_management_product_group` resource
- [ ] Support linking to built-in groups (Administrators, Developers, Guests)
- [ ] Support linking to custom groups

### Task 4.4: Products Variables & Outputs
- [ ] Add `products` variable to `variables.tf`
- [ ] Add validation for product names and display names
- [ ] Add validation for subscription limits
- [ ] Add product outputs (resource IDs, URLs)

### Task 4.5: Products Testing
- [ ] Create example in `examples/products_basic/`
- [ ] Create example in `examples/products_with_apis/`
- [ ] Create example in `examples/products_with_approval/`
- [ ] Test product lifecycle (create, publish, unpublish)
- [ ] Run AVM pre-commit checks
- [ ] Run AVM PR checks

---

## Phase 5: Subscriptions Implementation
**Goal:** API access key management

### Task 5.1: Subscription Resources
- [ ] Create `main.subscriptions.tf` file
- [ ] Implement `azurerm_api_management_subscription` resource
- [ ] Add support for product-scoped subscriptions
- [ ] Add support for API-scoped subscriptions
- [ ] Add support for all-APIs subscriptions
- [ ] Add support for user assignments
- [ ] Add support for subscription states (active, suspended, etc.)

### Task 5.2: Subscription Key Management
- [ ] Add support for custom primary/secondary keys
- [ ] Add support for key regeneration (via lifecycle management)
- [ ] Add support for tracing enablement

### Task 5.3: Subscriptions Variables & Outputs
- [ ] Add `subscriptions` variable to `variables.tf`
- [ ] Add validation for subscription scopes
- [ ] Add validation for key formats
- [ ] Add subscription outputs (resource IDs, keys as sensitive outputs)

### Task 5.4: Subscriptions Testing
- [ ] Create example in `examples/subscriptions_basic/`
- [ ] Create example in `examples/subscriptions_product_scoped/`
- [ ] Create example in `examples/subscriptions_api_scoped/`
- [ ] Test key rotation scenarios
- [ ] Run AVM pre-commit checks
- [ ] Run AVM PR checks

---

## Phase 6: Service-Level Policies
**Goal:** Global transformation and security policies (single service-level policy)

### Task 6.1: Global Policy Resources

- [ ] Create `main.policies.tf` file (if not merged with APIs)
- [ ] Implement `azurerm_api_management_policy` resource for service-level policy
- [ ] Note: This is a single policy at the service level (not an array)
- [ ] Add support for rate limiting policies
- [ ] Add support for authentication policies (JWT validation, basic auth)
- [ ] Add support for CORS policies
- [ ] Add support for transformation policies

### Task 6.2: Policy Templates & Best Practices
- [ ] Create policy template examples for common scenarios
- [ ] Document policy execution order
- [ ] Add validation for policy XML syntax
- [ ] Add examples for policy expressions

### Task 6.3: Policy Variables & Testing
- [ ] Add service-level `policies` variable (if separate from apis)
- [ ] Create example in `examples/policies_rate_limiting/`
- [ ] Create example in `examples/policies_jwt_validation/`
- [ ] Create example in `examples/policies_cors/`
- [ ] Run AVM pre-commit checks
- [ ] Run AVM PR checks

---

## Phase 7: Integration & Documentation
**Goal:** End-to-end testing and comprehensive documentation

### Task 7.1: Comprehensive Example
- [ ] Create `examples/complete_api_management/`
- [ ] Include named values with Key Vault
- [ ] Include multiple APIs with operations
- [ ] Include products with API associations
- [ ] Include subscriptions with different scopes
- [ ] Include various policy scenarios
- [ ] Test all components working together

### Task 7.2: Documentation
- [ ] Update main `README.md` with new capabilities
- [ ] Document all new variables with examples
- [ ] Document all new outputs
- [ ] Create architecture diagram showing resource relationships
- [ ] Add troubleshooting guide
- [ ] Add migration guide from basic to advanced configurations

### Task 7.3: AVM Compliance
- [ ] Ensure all variables follow AVM naming conventions
- [ ] Ensure all outputs follow AVM standards
- [ ] Add proper resource tags support
- [ ] Verify role assignments work with new resources
- [ ] Verify locks work with new resources
- [ ] Run full AVM validation suite

### Task 7.4: Final Validation
- [ ] Run `terraform fmt -recursive`
- [ ] Run `terraform validate`
- [ ] Run `PORCH_NO_TUI=1 ./avm pre-commit`
- [ ] Commit any auto-generated changes
- [ ] Run `PORCH_NO_TUI=1 ./avm pr-check`
- [ ] Fix any validation failures
- [ ] Test all examples in clean environment

---

## Phase 8: PR Preparation
**Goal:** Clean, reviewable PR ready for submission

### Task 8.1: Code Review & Cleanup
- [ ] Review all code for consistency
- [ ] Remove debug comments and temporary code
- [ ] Ensure consistent formatting
- [ ] Verify no sensitive data in code
- [ ] Check for unused variables/outputs

### Task 8.2: PR Documentation
- [ ] Write detailed PR description
- [ ] List all new resources added
- [ ] List all breaking changes (if any)
- [ ] Add before/after examples
- [ ] Reference GitHub issue #26
- [ ] Create PR checklist

### Task 8.3: Testing Evidence
- [ ] Screenshot/log of successful `terraform plan`
- [ ] Screenshot/log of successful `terraform apply`
- [ ] Screenshot/log of AVM validation passing
- [ ] Document test environment details

---

## Summary Statistics

- **Total Phases:** 9 (added API Version Sets phase)
- **Total Tasks:** ~90+ individual tasks
- **Estimated Files to Create/Modify:**
  - New: ~6-8 `.tf` files
  - Modified: `variables.tf`, `outputs.tf`, `README.md`
  - New Examples: ~15-18 example directories

## Key Resources Implemented

1. **Named Values** - Configuration and secrets management
2. **API Version Sets** - API versioning support (Header/Query/Segment schemes)
3. **APIs** - API definitions with OpenAPI/SOAP/GraphQL support
4. **API Operations** - HTTP operations for APIs
5. **API Policies** - XML-based transformation and security policies (API-level)
6. **API Operation Policies** - Operation-level policies (using separate resource)
7. **Products** - API grouping and access control
8. **Product-API Links** - Association between products and APIs
9. **Product-Group Links** - Access control via groups
10. **Subscriptions** - API key management and access control
11. **Service-Level Policies** - Global policies (single service-level policy)

## Key Success Criteria

✅ All AVM validation checks pass
✅ All examples deploy successfully
✅ No breaking changes to existing functionality
✅ Comprehensive documentation
✅ Feature parity with Bicep module for scope (APIs, Products, Subscriptions, Named Values, Policies)

## Dependencies Between Phases

```mermaid
Phase 1 (Foundation)
    ↓
Phase 2 (Named Values) ← Can reference in policies and configurations
    ↓
Phase 2.5 (API Version Sets) ← Required for API versioning
    ↓
Phase 3 (APIs + Operations + Policies) ← Can use named values and reference version sets
    ↓
Phase 4 (Products) ← Links to APIs
    ↓
Phase 5 (Subscriptions) ← Scoped to products or APIs
    ↓
Phase 6 (Service-Level Policies) ← Global policies applying to all APIs
    ↓
Phase 7 (Integration & Documentation)
    ↓
Phase 8 (PR Preparation)
```

## Recommended Development Order

This phased approach allows for incremental development and testing, ensuring each component works before building the next layer of functionality. Each phase can be committed separately to maintain a clean git history, though all phases should be completed before creating the PR.

## Notes

- All code must comply with AVM standards
- Use snake_case for all variable and resource names
- Follow existing module patterns for consistency
- Add comprehensive examples for each feature
- Test in a clean environment before finalizing PR
- Document any deviations from Bicep implementation with rationale

## Recent Updates

### 2025-10-17: Priority 1 Additions
- **Added Phase 2.5: API Version Sets** - Required for API versioning support (Header/Query/Segment schemes)
- **Updated Phase 3.4: API Policies** - Clarified use of separate resources:
  - `azurerm_api_management_api_policy` for API-level policies
  - `azurerm_api_management_api_operation_policy` for operation-level policies
- **Updated Phase 6: Service-Level Policies** - Clarified that `azurerm_api_management_policy` is a single service-level policy resource
- **Updated Summary Statistics** - Now 9 phases with ~90+ tasks covering 11 key resources
- **Updated Dependencies Diagram** - Reflects new Phase 2.5 for API Version Sets
