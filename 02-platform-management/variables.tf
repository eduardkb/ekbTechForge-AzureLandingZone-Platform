variable "management_subscription_id" {
  description = "Subscription ID from the foundation output platform_subscription_ids.management."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.management_subscription_id))
    error_message = "management_subscription_id must be a subscription GUID."
  }
}

variable "location" {
  description = "Azure region used for regional management resources."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group in the platform management subscription."
  type        = string
  default     = "rg-platform-management-southcentralus"
}

variable "log_analytics_workspace_name" {
  description = "Name of the central platform Log Analytics workspace."
  type        = string
  default     = "law-platform-management-southcentralus"
}

variable "action_group_name" {
  description = "Name of the Azure Monitor action group."
  type        = string
  default     = "ag-platform-management"
}

variable "alert_email_address" {
  description = "Operations email address that receives Azure Monitor notifications."
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.alert_email_address))
    error_message = "alert_email_address must be a valid email address."
  }
}

variable "tags" {
  description = "Tags applied to resources, including the keys required by the foundation policies."
  type        = map(string)

  validation {
    condition = alltrue([
      for key in ["Environment", "Owner", "CostCenter"] :
      contains(keys(var.tags), key) && trimspace(var.tags[key]) != ""
    ])
    error_message = "tags must include non-empty Environment, Owner, and CostCenter values."
  }
}

variable "enable_telemetry" {
  description = "Whether Microsoft Azure Verified Modules telemetry is enabled."
  type        = bool
  default     = false
}