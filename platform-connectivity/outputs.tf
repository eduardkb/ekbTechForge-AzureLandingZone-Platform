output "hub_vnet_id" {
  description = "Hub VNet resource ID."
  value       = module.hub_vnet.resource_id
}

output "hub_vnet_name" {
  description = "Hub VNet name."
  value       = module.hub_vnet.name
}

output "subnets" {
  description = "Created hub subnet details."
  value       = module.hub_vnet.subnets
}