# Examples

- Create a directory for each example.
- Create a `_header.md` file in each directory to describe the example.
- See the `default` example provided as a skeleton - this must remain, but you can add others.
- Run `make fmt && make docs` from the repo root to generate the required documentation.

> **Note:** Examples must be deployable and idempotent. Ensure that no input variables are required to run the example and that random values are used to ensure unique resource names. E.g. use the [naming module](https://registry.terraform.io/modules/Azure/naming/azurerm/latest) to generate a unique name for a resource.

- Notice that since APIM requires an email address to be provided for the `publisher_email` field, we do not specify a default email for the users, and instead the user is required to provide an email. The user can either provide an email interactuively or set it in the `terraform.tfvars` file or set an env var `exoort TF_VAR_publisher_email='YOUR EMAIL'` to set the email address.

- There are 2 examples that require the user to set a virtual network subnet id. There are examples that create the vnet for you in `preprovisioned_virtual_network_private_endpoints_with_permissions` and `preprovisioned_virtual_network`, however for the 2 examples in `internal_virtual_network` and `external_virtual_network`. This allows us to demonstrate a minimalist example to deploy the APIM into a virtual network.
