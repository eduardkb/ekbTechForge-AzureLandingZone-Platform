variable "subscription_id" {
  type        = string
  description = "Subscription where management resources are deployed. Does not have to be the state-storage subscription."
}

variable "root_management_group_id" {
  type        = string
  description = "Immutable ID for the EkbTechForge intermediate root management group."
  default     = "ekbtechforge"
}

variable "location" {
  type        = string
  description = "Default Azure region for policy identities and management resources."
  default     = "southcentralus"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group for management resources."
  default     = "rg-ekb-platform-management"
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "Globally unique Log Analytics workspace name."
  default     = "law-ekb-platform-management"
}

variable "create_log_analytics_workspace" {
  type        = bool
  description = "Create the low-ingestion-cap workspace. Workspace ingestion is metered."
  default     = true
}

variable "workspace_daily_quota_gb" {
  type        = number
  description = "Maximum Log Analytics ingestion per day in GB. This is not a monetary budget."
  default     = 0.5
}

variable "workspace_retention_days" {
  type        = number
  description = "Log Analytics retention in days."
  default     = 30
}

variable "enable_subscription_diagnostics" {
  type        = bool
  description = "Send subscription Activity Log categories to the workspace. This can incur ingestion charges."
  default     = false
}

variable "alert_email_receivers" {
  type = map(object({
    email_address = string
  }))
  description = "Optional email receivers for the management action group. No action group is created when empty."
  default     = {}
}

variable "allowed_locations" {
  type        = list(string)
  description = "Allowed Azure location names enforced by a management-group policy."
  default     = ["southcentralus", "eastus", "eastus2", "westus", "westus2"]
}

variable "required_tag_names" {
  type        = set(string)
  description = "Tag keys that must exist on resources. The policy denies resource creation when a key is missing."
  default     = ["Environment", "Owner"]
}

variable "allowed_resource_types" {
  type        = list(string)
  description = "Explicit Azure resource-type allow-list enforced at the EkbTechForge management group. Extend before deployment to cover workload and deployment-tool requirements."
  default = [
    "Microsoft.Authorization/policyAssignments",
    "Microsoft.Authorization/roleAssignments",
    "Microsoft.Compute/disks",
    "Microsoft.Compute/virtualMachines",
    "Microsoft.Insights/actionGroups",
    "Microsoft.Insights/activityLogAlerts",
    "Microsoft.Insights/diagnosticSettings",
    "Microsoft.Insights/metricAlerts",
    "Microsoft.KeyVault/vaults",
    "Microsoft.ManagedIdentity/userAssignedIdentities",
    "Microsoft.Network/networkSecurityGroups",
    "Microsoft.Network/networkWatchers",
    "Microsoft.Network/privateDnsZones",
    "Microsoft.Network/privateDnsZones/virtualNetworkLinks",
    "Microsoft.Network/routeTables",
    "Microsoft.Network/virtualNetworks",
    "Microsoft.Network/virtualNetworks/subnets",
    "Microsoft.Network/virtualNetworks/virtualNetworkPeerings",
    "Microsoft.OperationalInsights/workspaces",
    "Microsoft.Resources/deployments",
    "Microsoft.Resources/deploymentScripts",
    "Microsoft.Resources/resourceGroups",
    "Microsoft.Resources/templateSpecs",
    "Microsoft.Security/pricings",
    "Microsoft.Storage/storageAccounts",
    "Microsoft.Web/sites",
  ]
}

variable "management_group_role_assignments" {
  type = map(object({
    management_group_name      = string
    role_definition_id_or_name = string
    principal_id               = string
    principal_type             = optional(string)
    description                = optional(string)
  }))
  description = "Optional least-privilege assignments. Use Entra security-group IDs, e.g. Reader or Security Reader; avoid permanent privileged roles at the root."
  default     = {}
}

variable "subscription_placement" {
  type = map(object({
    subscription_id       = string
    management_group_name = string
  }))
  description = "Explicit subscription-to-management-group placements managed only by this root. Leave empty to avoid moving subscriptions."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to management resources."
  default = {
    Environment = "platform"
    Owner       = "platform-team"
    ManagedBy   = "Terraform"
  }
}

variable "enable_telemetry" {
  type        = bool
  description = "Enable Microsoft AVM module telemetry."
  default     = false
}