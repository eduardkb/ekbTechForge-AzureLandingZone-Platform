location = "southcentralus"

resource_group_name      = "rg-platform-connectivity"
hub_virtual_network_name = "vnet-platform-hub"
hub_address_space        = ["10.0.0.0/16"]
hub_subnet_address_prefixes = {
  shared_services   = ["10.0.1.0/24"]
  private_endpoints = ["10.0.2.0/24"]
}

# Storage account names must be globally unique; change the suffix if already taken.
flow_log_storage_account_name       = "stplatnetlogs0001"
flow_log_name                       = "vnet-platform-hub-flowlog"
flow_log_retention_days             = 7
network_watcher_name                = "NetworkWatcher_southcentralus"
network_watcher_resource_group_name = "NetworkWatcherRG"

private_dns_zones = [
  "privatelink.blob.core.windows.net",
  "privatelink.file.core.windows.net",
  "privatelink.vaultcore.azure.net",
  "privatelink.database.windows.net",
]

# Set this only when creating a public DNS zone for a domain the organization owns.
public_dns_zone_name = null

tags = {
  Environment = "Platform"
  Owner       = "platform-team@example.com"
  CostCenter  = "CC-0001"
}

enable_telemetry = false