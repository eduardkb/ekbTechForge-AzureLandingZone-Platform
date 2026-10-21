output "connectivity_resource_group_id" {
  description = "Resource ID of the platform connectivity resource group."
  value       = module.connectivity_resource_group.resource_id
}

output "hub_virtual_network_id" {
  description = "Resource ID of the hub virtual network."
  value       = module.hub_virtual_network.resource_id
}

output "hub_subnet_ids" {
  description = "Resource IDs of the shared-services and private-endpoint subnets."
  value = {
    for key, subnet in module.hub_virtual_network.subnets : key => subnet.resource_id
  }
}

output "flow_log_storage_account_id" {
  description = "Resource ID of the VNet flow-log storage account."
  value       = module.flow_log_storage.resource_id
}

output "hub_vnet_flow_log_id" {
  description = "Resource ID of the hub Virtual Network Flow Log."
  value       = azapi_resource.hub_vnet_flow_log.id
}

output "private_dns_zone_ids" {
  description = "Resource IDs of the private DNS zones linked to the hub."
  value       = { for key, zone in module.private_dns_zones : key => zone.resource_id }
}

output "public_dns_zone_id" {
  description = "Resource ID of the optional public DNS zone, or null when not configured."
  value       = try(module.public_dns_zone[0].resource_id, null)
}