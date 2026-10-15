# GLOBAL VARIABLES
location = "southcentralus"
resource_group_name          = "rg-platform-management"
log_analytics_workspace_name = "law-platform-management"
action_group_name            = "ag-platform-management"
alert_email_address = "eduardbuhali@gmail.com"

tags = {
  Environment = "Platform"
  Owner       = "eduardbuhali@gmail.com"
  CostCenter  = "CC-0001"
}

enable_telemetry = false