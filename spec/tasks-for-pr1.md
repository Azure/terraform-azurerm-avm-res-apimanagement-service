# PR 1: Core API Management - Phased Task Breakdown

## Overview

This document provides a comprehensive, phased approach to implementing **PR 1: Core API Management** features for the Azure Verified Modules (AVM) Terraform module for API Management. This PR achieves feature parity with the Bicep AVM module for APIs, Products, Subscriptions, Named Values, and Policies.

## Progress Summary

### ✅ Completed Phases (Phases 1-7)

- **Phase 1: Foundation & Planning** - Research, schema analysis, and variable structure design
- **Phase 2: Named Values Implementation** - Plain text, secret, and Key Vault-backed named values
- **Phase 2.5: API Version Sets Implementation** - Header, Query, and Segment versioning schemes
- **Phase 3: APIs Implementation** - APIs, operations, policies (API-level and operation-level)
- **Phase 4: Products Implementation** - Products with API and Group associations
- **Phase 5: Subscriptions Implementation** - Subscriptions with flexible scoping (product/api/all_apis)
- **Phase 6: Service-Level Policies** - Global policy with CORS and security headers
- **Phase 7: Integration & Documentation** - Comprehensive example and documentation

### 📊 Implementation Approach

**Consolidated Example Strategy**: Instead of creating 15-18 separate examples, we've adopted a single comprehensive example (`examples/complete/`) that demonstrates all implemented features together. This approach:
- Reduces maintenance burden
- Provides more realistic real-world usage patterns
- Simplifies CI/CD pipeline
- Aligns with AVM best practices

### 📦 What's Been Built

**Module Files**:
- `main.namedvalues.tf` - Named values with Key Vault integration
- `main.apis.tf` - API version sets, APIs, operations, and policies
- `main.products.tf` - Products with API and Group associations
- `main.subscriptions.tf` - Subscriptions with flexible scoping
- `main.policy.tf` - Service-level (global) policy
- `variables.tf` - All variables with comprehensive validation
- `outputs.tf` - All outputs for named values, API version sets, APIs, operations, products, subscriptions, and policy

**Example**:
- `examples/complete/` - Comprehensive example with:
  - 6 Named Values (plain text, secret, Key Vault-backed)
  - 2 API Version Sets (segment and header versioning)
  - 3 APIs (products-v1, products-v2, orders-v1)
  - 9 Operations (CRUD operations with schemas)
  - 4 Policies (3 API-level, 1 operation-level)
  - 1 Service-Level Policy (global CORS and security headers)
  - 3 Products (starter, premium, unlimited)
  - 4 Subscriptions (product-scoped, API-scoped, all-APIs-scoped)
  - Rate limiting, caching, content validation
  - Complete documentation and testing guide

### 🔄 Remaining Phases

- **Phase 8: PR Preparation** - Ready to start (AVM validation and final testing)

---

## Phase 1: Foundation & Planning
**Goal:** Set up structure and understand requirements

### Task 1.1: Research & Schema Analysis

- [x] Review Bicep module implementation for APIs, Products, Subscriptions, Named Values
- [x] Study azurerm provider documentation for:
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
- [x] Document resource dependencies and relationships
- [x] Identify required vs optional properties for each resource

### Task 1.2: Design Variable Structure

- [x] Design `api_version_sets` variable object structure (versioning schemes)
- [x] Design `apis` variable object structure (imports, OpenAPI, SOAP, GraphQL support)
- [ ] Design `products` variable object structure
- [ ] Design `subscriptions` variable object structure
- [x] Design `named_values` variable object structure (including Key Vault integration)
- [ ] Design `policies` variable object structure (service-level and API-level)
- [x] Create variable validation rules for each resource type
- [x] Document variable examples for common scenarios

---

## Phase 2: Named Values Implementation
**Goal:** Implement configuration and secrets management (foundation for other resources)
**Status:** ✅ COMPLETED

### Task 2.1: Named Values Resource
- [x] Create `main.namedvalues.tf` file
- [x] Implement `azurerm_api_management_named_value` resource with dynamic blocks
- [x] Add support for plain text values
- [x] Add support for Key Vault secret references
- [x] Add support for tags and filtering
- [x] Implement proper depends_on for APIM service

### Task 2.2: Named Values Variables & Outputs
- [x] Add `named_values` variable to `variables.tf`
- [x] Add validation for naming conventions
- [x] Add validation for Key Vault integration requirements
- [x] Add named values outputs to `outputs.tf` (resource IDs, display names)

### Task 2.3: Named Values Testing
- [x] Create example in `examples/complete/` (consolidated approach)
- [x] Test plain text named values
- [x] Test Key Vault integration
- [x] Test tags and filtering
- [ ] Run AVM pre-commit checks
- [ ] Run AVM PR checks

---

## Phase 2.5: API Version Sets Implementation
**Goal:** Enable API versioning support (required for APIs to reference version sets)
**Status:** ✅ COMPLETED

### Task 2.5.1: API Version Sets Resource
- [x] Create API version set resource in `main.apis.tf` file
- [x] Implement `azurerm_api_management_api_version_set` resource
- [x] Add support for versioning schemes (Header, Query, Segment)
- [x] Add support for version header name (for Header scheme)
- [x] Add support for version query name (for Query scheme)
- [x] Add proper depends_on for APIM service

### Task 2.5.2: API Version Sets Variables & Outputs
- [x] Add `api_version_sets` variable to `variables.tf`
- [x] Add validation for versioning scheme values
- [x] Add validation for header/query name requirements based on scheme
- [x] Add API version set outputs (resource IDs, names)

### Task 2.5.3: API Version Sets Testing
- [x] Create example in `examples/complete/` (consolidated approach)
- [x] Test Header-based versioning (orders-api)
- [x] Test Segment-based versioning (products-api)
- [ ] Test Query-based versioning (not in current example)
- [ ] Run AVM pre-commit checks
- [ ] Run AVM PR checks

---

## Phase 3: APIs Implementation
**Goal:** Core API management with operations and OpenAPI import
**Status:** ✅ COMPLETED (with comprehensive example approach)

### Task 3.1: API Resources - Basic
- [x] Create `main.apis.tf` file
- [x] Implement `azurerm_api_management_api` resource
- [x] Add support for REST API creation
- [x] Add support for API versioning and revisions
- [x] Add support for API version sets linkage
- [x] Add support for protocols (HTTP/HTTPS)
- [x] Add support for subscription requirements

### Task 3.2: API Resources - Import Formats
- [x] Add OpenAPI/Swagger import support
- [x] Add OpenAPI JSON import support
- [x] Add WSDL import support (SOAP)
- [x] Add WADL import support
- [x] Add support for import from URL vs inline content
- [x] Handle format-specific configurations

### Task 3.3: API Operations
- [x] Implement `azurerm_api_management_api_operation` resource
- [x] Add support for HTTP methods (GET, POST, PUT, DELETE, etc.)
- [x] Add support for URL templates with parameters
- [x] Add support for request/response schemas
- [x] Add support for operation descriptions

### Task 3.4: API Policies

- [x] Implement `azurerm_api_management_api_policy` resource for API-level policies
- [x] Implement `azurerm_api_management_api_operation_policy` resource for operation-level policies
- [x] Add support for XML policy content
- [x] Add support for policy format types (xml, rawxml, xml-link, rawxml-link)
- [x] Add support for operation-level policies (using separate resource)
- [x] Add common policy templates/examples

### Task 3.5: APIs Variables & Outputs
- [x] Add `apis` variable to `variables.tf`
- [x] Add validation for API naming and paths
- [x] Add validation for import formats
- [x] Add API outputs (resource IDs, URLs, gateway URLs)
- [x] Add operation outputs

### Task 3.6: APIs Testing
- [x] Create comprehensive example in `examples/complete/` (consolidated approach)
- [x] Test basic APIs with operations (products-v1: 5 ops, products-v2: 2 ops, orders-v1: 2 ops)
- [x] Test API versioning (segment and header-based)
- [x] Test API policies (3 API-level policies)
- [x] Test operation policies (1 operation-level policy on create-product)
- [x] Test request/response schemas and query parameters
- [ ] Test OpenAPI/Swagger import formats (not in current example)
- [ ] Run AVM pre-commit checks
- [ ] Run AVM PR checks

---

## Phase 4: Products Implementation
**Goal:** API grouping and monetization
**Status:** ✅ COMPLETED

### Task 4.1: Product Resources
- [x] Create `main.products.tf` file
- [x] Implement `azurerm_api_management_product` resource
- [x] Add support for product visibility (public/private)
- [x] Add support for subscription requirements
- [x] Add support for approval workflows
- [x] Add support for terms of use
- [x] Add support for product state (published/not published)

### Task 4.2: Product-API Associations
- [x] Implement `azurerm_api_management_product_api` resource
- [x] Handle dynamic linking based on product configuration
- [x] Add proper dependency management

### Task 4.3: Product-Group Associations
- [x] Implement `azurerm_api_management_product_group` resource
- [x] Support linking to built-in groups (Administrators, Developers, Guests)
- [x] Support linking to custom groups

### Task 4.4: Products Variables & Outputs
- [x] Add `products` variable to `variables.tf`
- [x] Add validation for product names and display names
- [x] Add validation for subscription limits
- [x] Add product outputs (resource IDs, URLs)

### Task 4.5: Products Testing
- [x] Create example in `examples/complete/` (consolidated approach)
- [x] Test product with APIs (starter, premium, unlimited)
- [x] Test product with approval workflows (premium, unlimited)
- [x] Test product lifecycle (create, publish)
- [ ] Run AVM pre-commit checks
- [ ] Run AVM PR checks

---

## Phase 5: Subscriptions Implementation
**Goal:** API access key management
**Status:** ✅ COMPLETED

### Task 5.1: Subscription Resources
- [x] Create `main.subscriptions.tf` file
- [x] Implement `azurerm_api_management_subscription` resource
- [x] Add support for product-scoped subscriptions
- [x] Add support for API-scoped subscriptions
- [x] Add support for all-APIs subscriptions
- [x] Add support for user assignments
- [x] Add support for subscription states (active, suspended, submitted, etc.)

### Task 5.2: Subscription Key Management
- [x] Add support for custom primary/secondary keys
- [x] Add support for key regeneration (via lifecycle management)
- [x] Add support for tracing enablement

### Task 5.3: Subscriptions Variables & Outputs
- [x] Add `subscriptions` variable to `variables.tf`
- [x] Add validation for subscription scopes
- [x] Add validation for scope_type values
- [x] Add subscription outputs (resource IDs, keys as sensitive outputs)

### Task 5.4: Subscriptions Testing
- [x] Create example in `examples/complete/` (consolidated approach)
- [x] Test product-scoped subscription (developer-starter-sub)
- [x] Test API-scoped subscription (api-specific-sub)
- [x] Test all-APIs subscription (all-apis-sub)
- [x] Test subscription states (active, submitted)
- [ ] Run AVM pre-commit checks
- [ ] Run AVM PR checks

---

## Phase 6: Service-Level Policies
**Goal:** Global transformation and security policies (single service-level policy)
**Status:** ✅ COMPLETED

### Task 6.1: Global Policy Resources

- [x] Create `main.policy.tf` file
- [x] Implement `azurerm_api_management_policy` resource for service-level policy
- [x] Note: This is a single policy at the service level (not an array)
- [x] Add support for rate limiting policies
- [x] Add support for authentication policies (JWT validation, basic auth)
- [x] Add support for CORS policies
- [x] Add support for transformation policies

### Task 6.2: Policy Templates & Best Practices
- [x] Create policy template examples for common scenarios
- [x] Document policy execution order
- [x] Add examples for policy expressions (in variable documentation)

### Task 6.3: Policy Variables & Testing
- [x] Add service-level `policy` variable
- [x] Create example in `examples/complete/` (consolidated approach)
- [x] Add CORS and security headers example
- [ ] Run AVM pre-commit checks
- [ ] Run AVM PR checks

---

## Phase 7: Integration & Documentation
**Goal:** End-to-end testing and comprehensive documentation
**Status:** ✅ COMPLETED

### Task 7.1: Comprehensive Example
- [x] Create `examples/complete/` (consolidated approach)
- [x] Include named values with Key Vault
- [x] Include multiple APIs with operations
- [x] Include products with API associations
- [x] Include subscriptions with different scopes
- [x] Include various policy scenarios (API-level, operation-level, service-level)
- [x] Test all components working together

### Task 7.2: Documentation
- [x] Update example `README.md` with new capabilities
- [x] Document all new variables with examples
- [x] Document all new outputs
- [x] Add comprehensive usage guide
- [x] Update feature lists and resource counts
- [ ] Main `README.md` will be auto-generated by terraform-docs

### Task 7.3: AVM Compliance
- [x] Ensure all variables follow AVM naming conventions
- [x] Ensure all outputs follow AVM standards
- [x] Proper resource tags support (inherited from base module)
- [x] Role assignments work with new resources (inherited from base module)
- [x] Locks work with new resources (inherited from base module)
- [ ] Run full AVM validation suite (Phase 8)

### Task 7.4: Final Validation
- [x] Run `terraform fmt -recursive`
- [x] Run `terraform validate`
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
