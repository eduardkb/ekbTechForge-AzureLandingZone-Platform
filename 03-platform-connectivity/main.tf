provider "azurerm" {
  features {
    subscription {
      prevent_cancellation_on_destroy = false
    }
  }
  subscription_id = var.connectivity_subscription_id
}

provider "azapi" {
  subscription_id = var.connectivity_subscription_id
}

resource "azurerm_resource_group" "network_watcher" {
  name     = var.network_watcher_resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_network_watcher" "connectivity" {
  name                = var.network_watcher_name
  resource_group_name = azurerm_resource_group.network_watcher.name
  location            = azurerm_resource_group.network_watcher.location
  tags                = var.tags
}

locals {
  subscription_scope = "/subscriptions/${var.connectivity_subscription_id}"
}

module "connectivity_resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.4.0"

  name             = var.resource_group_name
  location         = var.location
  tags             = var.tags
  enable_telemetry = var.enable_telemetry
  lock = {
    kind = "CanNotDelete"
  }
}

module "hub_virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.22.3"

  name             = var.hub_virtual_network_name
  parent_id        = module.connectivity_resource_group.resource_id
  location         = var.location
  address_space    = var.hub_address_space
  enable_telemetry = var.enable_telemetry
  tags             = var.tags
  subnets = {
    shared_services = {
      name             = "snet-shared-services"
      address_prefixes = var.hub_subnet_address_prefixes.shared_services
    }
    private_endpoints = {
      name             = "snet-private-endpoints"
      address_prefixes = var.hub_subnet_address_prefixes.private_endpoints
    }
  }
}

module "flow_log_storage" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.10.0"

  name                            = var.flow_log_storage_account_name
  parent_id                       = module.connectivity_resource_group.resource_id
  location                        = var.location
  account_kind                    = "StorageV2"
  account_sku_name                = "Standard_LRS"
  access_tier                     = "Hot"
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = true
  shared_access_key_enabled       = true
  allow_nested_items_to_be_public = false
  network_rules = {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }
  enable_telemetry = var.enable_telemetry
  tags             = var.tags
}

resource "azapi_resource" "hub_vnet_flow_log" {
  type      = "Microsoft.Network/networkWatchers/flowLogs@2025-07-01"
  name      = var.flow_log_name
  parent_id = azurerm_network_watcher.connectivity.id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      enabled = true
      flowAnalyticsConfiguration = {
        networkWatcherFlowAnalyticsConfiguration = {
          enabled = false
        }
      }
      format = {
        type    = "JSON"
        version = 2
      }
      retentionPolicy = {
        days    = var.flow_log_retention_days
        enabled = true
      }
      storageId        = module.flow_log_storage.resource_id
      targetResourceId = module.hub_virtual_network.resource_id
    }
  }
}

module "private_dns_zone_hub_links" {
  source  = "Azure/avm-res-network-privatednszone/azurerm//modules/private_dns_virtual_network_link"
  version = "0.5.0"

  for_each = var.private_dns_zones

  name                   = "vnet-hub-link"
  parent_id              = module.private_dns_zones[each.key].resource_id
  virtual_network_id     = module.hub_virtual_network.resource_id
  registration_enabled   = false
  tags                   = var.tags

  # Disables the deprecated retry attributes for the VNet-link resource.
  retry = null
}

module "public_dns_zone" {
  count   = var.public_dns_zone_name == null ? 0 : 1
  source  = "Azure/avm-res-network-dnszone/azurerm"
  version = "0.2.1"

  name                = var.public_dns_zone_name
  resource_group_name = module.connectivity_resource_group.name
  enable_telemetry    = var.enable_telemetry
  tags                = var.tags
} # placeholder. Add code.