output "management_group_ids" {
  description = "Management group resource IDs created by the ALZ architecture."
  value       = module.alz_foundation.management_group_resource_ids
}

output "platform_subscription_ids" {
  description = "Subscription IDs created for the platform management and connectivity areas."
  value       = { for key, subscription in azurerm_subscription.platform : key => subscription.subscription_id }
}