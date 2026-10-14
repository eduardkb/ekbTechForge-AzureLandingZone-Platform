output "management_group_ids" {
  description = "Management group resource IDs created by the ALZ architecture."
  value       = module.alz_foundation.management_group_resource_ids
}

output "platform_subscription_ids" {
  description = "Subscription IDs created for the platform management, connectivity, and security areas."
  value       = { for key, subscription in azurerm_subscription.platform : key => subscription.subscription_id }
}

output "platform_resource_group_ids" {
  description = "Resource group IDs created in the platform subscriptions."
  value       = { for key, resource_group in azapi_resource.platform_resource_group : key => resource_group.id }
}