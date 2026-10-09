resource "azurerm_resource_group" "connectivity" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "hub_vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.22.2"

  name             = var.hub_vnet_name
  location         = var.location
  parent_id        = azurerm_resource_group.connectivity.id
  address_space    = var.hub_address_space
  subnets          = var.subnets
  peerings         = var.peerings
  enable_telemetry = var.enable_telemetry
  tags             = var.tags
}