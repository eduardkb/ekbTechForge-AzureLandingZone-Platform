variable "connectivity_subscription_id" {
  description = "Subscription ID from the foundation output platform_subscription_ids.connectivity."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.connectivity_subscription_id))
    error_message = "connectivity_subscription_id must be a subscription GUID."
  }
}

variable "location" {
  description = "Azure region used for connectivity resources."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for hub networking, flow-log storage, and private DNS zones."
  type        = string
  default     = "rg-platform-connectivity"
}

variable "hub_virtual_network_name" {
  description = "Name of the connectivity hub virtual network."
  type        = string
  default     = "vnet-platform-hub"
}

variable "hub_address_space" {
  description = "CIDR address space reserved for the hub. Ensure it does not overlap with other corporate networks."
  type        = list(string)

  validation {
    condition     = length(var.hub_address_space) > 0
    error_message = "hub_address_space must contain at least one CIDR prefix."
  }
}

variable "hub_subnet_address_prefixes" {
  description = "Address prefixes for the hub shared-services and private-endpoint subnets."
  type = object({
    shared_services   = list(string)
    private_endpoints = list(string)
  })
}

variable "flow_log_storage_account_name" {
  description = "Globally unique StorageV2 account name for VNet flow logs (3-24 lowercase letters and numbers)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.flow_log_storage_account_name))
    error_message = "flow_log_storage_account_name must be 3-24 lowercase letters or numbers."
  }
}

variable "flow_log_name" {
  description = "Name of the Virtual Network Flow Log resource."
  type        = string
  default     = "vnet-platform-hub-flowlog"
}

variable "flow_log_retention_days" {
  description = "Number of days VNet flow logs are retained in the storage account."
  type        = number
  default     = 7

  validation {
    condition     = var.flow_log_retention_days >= 1 && var.flow_log_retention_days <= 365
    error_message = "flow_log_retention_days must be between 1 and 365."
  }
}

variable "network_watcher_name" {
  description = "Name of the existing regional Network Watcher. Azure normally creates one per subscription and region."
  type        = string
  default     = "NetworkWatcher_southcentralus"
}

variable "network_watcher_resource_group_name" {
  description = "Resource group containing the existing regional Network Watcher."
  type        = string
  default     = "NetworkWatcherRG"
}

variable "private_dns_zones" {
  description = "Private DNS zones for common Azure private endpoints; each zone is linked to the hub VNet."
  type        = set(string)
  default = [
    "privatelink.blob.core.windows.net",
    "privatelink.file.core.windows.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.database.windows.net",
  ]
}

variable "public_dns_zone_name" {
  description = "Optional public DNS domain name. Set this only for a domain owned by the organization."
  type        = string
  default     = null
  nullable    = true
}

variable "tags" {
  description = "Tags applied to resources, including keys required by the foundation policies."
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