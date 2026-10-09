variable "subscription_id" {
  type        = string
  description = "Subscription where connectivity resources are deployed."
}

variable "location" {
  type        = string
  description = "Hub VNet region."
  default     = "southcentralus"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group for hub network resources."
  default     = "rg-ekb-platform-connectivity"
}

variable "hub_vnet_name" {
  type        = string
  description = "Hub virtual network name."
  default     = "vnet-ekb-hub-scus-001"
}

variable "hub_address_space" {
  type        = list(string)
  description = "Non-overlapping address space reserved for the hub."
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
  description = "Hub subnets. Avoid creating gateway/firewall subnets until those paid services are approved."
  default = {
    SharedServices = {
      name             = "snet-shared-services"
      address_prefixes = ["10.0.1.0/24"]
    }
  }
}

variable "peerings" {
  type = map(object({
    name                               = string
    remote_virtual_network_resource_id = string
    allow_forwarded_traffic            = optional(bool, false)
    allow_gateway_transit              = optional(bool, false)
    allow_virtual_network_access       = optional(bool, true)
    create_reverse_peering             = optional(bool, false)
    reverse_name                       = optional(string)
  }))
  description = "Optional peerings to existing VNets. Cross-state references are supplied as resource IDs."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to connectivity resources."
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