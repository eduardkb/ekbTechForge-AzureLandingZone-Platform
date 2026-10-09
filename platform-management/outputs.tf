output "management_group_resource_ids" {
  description = "Management group names and resource IDs created by the ALZ module."
  value       = module.alz.management_group_resource_ids
}

output "log_analytics_workspace_resource_id" {
  description = "Log Analytics workspace resource ID, or null when workspace creation is disabled."
  value       = var.create_log_analytics_workspace ? module.log_analytics_workspace[0].resource_id : null
}
