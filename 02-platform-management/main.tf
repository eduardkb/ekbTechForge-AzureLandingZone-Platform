provider "azurerm" {
  features {
    subscription {
      prevent_cancellation_on_destroy = false
    }
  }
  subscription_id = var.management_subscription_id
}

provider "azapi" {
  subscription_id = var.management_subscription_id
}

locals {
  subscription_scope = "/subscriptions/${var.management_subscription_id}"

  action_group_email_receivers = {
    operations = {
      name                    = "Platform Operations"
      email_address           = var.alert_email_address
      use_common_alert_schema = true
    }
  }

  subscription_activity_log_categories = toset([
    "Administrative",
    "Security",
    "ServiceHealth",
    "Alert",
    "Recommendation",
    "Policy",
    "Autoscale",
    "ResourceHealth",
  ])
}

module "management_resource_group" {
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

module "log_analytics_workspace" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.5.1"

  name                                                    = var.log_analytics_workspace_name
  resource_group_name                                     = module.management_resource_group.name
  location                                                = var.location
  log_analytics_workspace_sku                             = "PerGB2018"
  log_analytics_workspace_retention_in_days               = 30
  log_analytics_workspace_local_authentication_enabled    = false
  log_analytics_workspace_allow_resource_only_permissions = true
  tags                                                    = var.tags
  enable_telemetry                                        = var.enable_telemetry
}

module "management_action_group" {
  source  = "Azure/avm-res-insights-actiongroup/azurerm"
  version = "0.1.0"

  name             = var.action_group_name
  parent_id        = module.management_resource_group.resource_id
  location         = "Global"
  short_name       = "PlatformOps"
  email_receivers  = local.action_group_email_receivers
  tags             = var.tags
  enable_telemetry = var.enable_telemetry
}

resource "azurerm_monitor_diagnostic_setting" "subscription_activity_log" {
  name                           = "diag-platform-management-activity-log"
  target_resource_id             = local.subscription_scope
  log_analytics_workspace_id     = module.log_analytics_workspace.resource_id
  log_analytics_destination_type = "Dedicated"

  dynamic "enabled_log" {
    for_each = local.subscription_activity_log_categories

    content {
      category = enabled_log.value
    }
  }
}

resource "azurerm_monitor_activity_log_alert" "service_health" {
  name                = "alert-platform-management-service-health"
  location            = "Global"
  resource_group_name = module.management_resource_group.name
  scopes              = [local.subscription_scope]
  description         = "Notifies Platform Operations about Azure Service Health events for the management subscription."
  enabled             = true
  tags                = var.tags

  criteria {
    category = "ServiceHealth"
  }

  action {
    action_group_id = module.management_action_group.resource_id
  }
}

resource "azurerm_monitor_activity_log_alert" "critical_administrative" {
  name                = "alert-platform-management-critical-administrative"
  location            = "Global"
  resource_group_name = module.management_resource_group.name
  scopes              = [local.subscription_scope]
  description         = "Notifies Platform Operations about critical administrative activity in the management subscription."
  enabled             = true
  tags                = var.tags

  criteria {
    category = "Administrative"
    level    = "Critical"
  }

  action {
    action_group_id = module.management_action_group.resource_id
  }
}