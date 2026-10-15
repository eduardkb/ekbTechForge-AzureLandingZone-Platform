output "management_resource_group_id" {
  description = "Resource ID of the platform management resource group."
  value       = module.management_resource_group.resource_id
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the central Log Analytics workspace."
  value       = module.log_analytics_workspace.resource_id
}

output "monitor_action_group_id" {
  description = "Resource ID of the Azure Monitor action group."
  value       = module.management_action_group.resource_id
}

output "subscription_activity_log_diagnostic_setting_id" {
  description = "Resource ID of the management subscription activity log diagnostic setting."
  value       = azurerm_monitor_diagnostic_setting.subscription_activity_log.id
}

output "activity_log_alert_ids" {
  description = "Resource IDs of the Service Health and critical administrative activity alerts."
  value = {
    service_health          = azurerm_monitor_activity_log_alert.service_health.id
    critical_administrative = azurerm_monitor_activity_log_alert.critical_administrative.id
  }
}