variable "platform_subscription_id" {
  description = "Existing subscription used to authenticate the AzureRM provider while vending platform subscriptions."
  type        = string
}

variable "billing_scope_id" {
  description = "Azure billing scope authorized to create subscriptions."
  type        = string
}

variable "location" {
  description = "Default Azure region for platform resource groups and policy identities."
  type        = string
}

variable "enable_telemetry" {
  description = "Whether Microsoft AVM module telemetry is enabled."
  type        = bool
  default     = false
}

variable "platform_subscriptions" {
  description = "Names, resource groups, and workload types for the three platform subscriptions."
  type = map(object({
    subscription_name   = string
    resource_group_name = string
    workload            = optional(string, "Production")
  }))

  validation {
    condition = length(var.platform_subscriptions) == 3 && alltrue([
      for key in ["management", "connectivity", "security"] : contains(keys(var.platform_subscriptions), key)
    ])
    error_message = "platform_subscriptions must contain exactly management, connectivity, and security entries."
  }
}

variable "resource_tags" {
  description = "Tags applied to platform resource groups."
  type        = map(string)
}

variable "allowed_locations" {
  description = "Azure regions permitted by the Corporate management-group policy."
  type        = set(string)

  validation {
    condition     = length(var.allowed_locations) > 0
    error_message = "At least one allowed Azure location must be specified."
  }
}

variable "required_tags" {
  description = "Tag keys that every resource under Corporate must define. One policy assignment is created per key."
  type        = set(string)

  validation {
    condition     = length(var.required_tags) > 0
    error_message = "At least one required tag key must be specified."
  }
}

variable "allowed_resource_types" {
  description = "Azure resource types permitted by the Corporate management-group policy."
  type        = set(string)

  validation {
    condition     = length(var.allowed_resource_types) > 0
    error_message = "At least one allowed resource type must be specified."
  }
}

variable "security_groups" {
  description = "Entra security groups to create, keyed by their display name."
  type = map(object({
    description = string
  }))
}

variable "group_role_assignments" {
  description = "Management-group roles granted to the created Entra security groups."
  type = map(object({
    group_name           = string
    role_definition_name = string
    management_group_key = string
  }))
}