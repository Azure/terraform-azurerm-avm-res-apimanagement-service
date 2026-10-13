variable "ignore_body_changes" {
  type = object({
    authorization_locks            = optional(list(string), [])
    authorization_role_assignments = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative dot-notation paths to ignore for AzAPI resources. Changes take effect only after apply. Ignored configuration is not sent to Azure until the path is removed. Non-empty values require Terraform 1.11 or later.

- `authorization_locks` - Paths ignored on private endpoint locks.
- `authorization_role_assignments` - Paths ignored on private endpoint role assignments.
DESCRIPTION
  nullable    = false
}

variable "resource_types" {
  type = object({
    apimanagement_service          = optional(string, "Microsoft.ApiManagement/service@2024-05-01")
    authorization_locks            = optional(string, "Microsoft.Authorization/locks@2020-05-01")
    authorization_role_assignments = optional(string, "Microsoft.Authorization/roleAssignments@2022-04-01")
  })
  default     = {}
  description = <<DESCRIPTION
AzAPI resource types and API versions used by the module.

- `apimanagement_service` - API version for the TLS 1.3 service update.
- `authorization_locks` - API version for private endpoint locks.
- `authorization_role_assignments` - API version for private endpoint role assignments.
DESCRIPTION
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = null
  description = <<DESCRIPTION
Retry configuration applied to every supported AzAPI resource declared by the module. Defaults to `null` (no custom retry).

- `error_message_regex` - (Optional) Error-message patterns that trigger a retry.
- `interval_seconds` - (Optional) Initial interval between retries in seconds.
- `max_interval_seconds` - (Optional) Maximum interval between retries in seconds.
DESCRIPTION
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Per-operation timeouts applied to every supported AzAPI resource declared by the module. Defaults to `null` (provider defaults). Values are Go duration strings such as `30m` or `1h`.

- `create` - (Optional) Timeout for create operations.
- `read` - (Optional) Timeout for read operations.
- `update` - (Optional) Timeout for update operations.
- `delete` - (Optional) Timeout for delete operations.
DESCRIPTION
}
