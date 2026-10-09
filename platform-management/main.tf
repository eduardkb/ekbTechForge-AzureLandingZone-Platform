data "azapi_client_config" "current" {}

locals {
  root_id = var.root_management_group_id

  required_tag_policy_ids = {
    for tag_name in var.required_tag_names : tag_name => "${local.root_id}-require-tag-${lower(replace(tag_name, " ", "-"))}"
  }
}

module "alz" {
  source  = "Azure/avm-ptn-alz/azurerm"
  version = "0.22.0"

  architecture_name  = "ekbtechforge"
  location           = var.location
  parent_resource_id = data.azapi_client_config.current.tenant_id
  enable_telemetry   = var.enable_telemetry

  management_group_role_assignments = var.management_group_role_assignments
  subscription_placement            = var.subscription_placement

  management_group_hierarchy_settings = {
    default_management_group_name            = "${local.root_id}-landing-zones"
    require_authorization_for_group_creation = true
  }
}

resource "azurerm_resource_group" "management" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "log_analytics_workspace" {
  count = var.create_log_analytics_workspace ? 1 : 0

  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.5.1"

  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.management.name
  enable_telemetry    = var.enable_telemetry

  log_analytics_workspace_sku                          = "PerGB2018"
  log_analytics_workspace_daily_quota_gb               = var.workspace_daily_quota_gb
  log_analytics_workspace_retention_in_days            = var.workspace_retention_days
  log_analytics_workspace_local_authentication_enabled = false
  tags                                                 = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "subscription_activity" {
  count = var.enable_subscription_diagnostics && var.create_log_analytics_workspace ? 1 : 0

  name                       = "diag-subscription-activity"
  target_resource_id         = "/subscriptions/${var.subscription_id}"
  log_analytics_workspace_id = module.log_analytics_workspace[0].resource_id

  enabled_log {
    category = "Administrative"
  }
  enabled_log {
    category = "Security"
  }
  enabled_log {
    category = "Policy"
  }
  enabled_log {
    category = "ServiceHealth"
  }
  enabled_log {
    category = "Alert"
  }
  enabled_log {
    category = "Recommendation"
  }
  enabled_log {
    category = "ResourceHealth"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_action_group" "management" {
  count = length(var.alert_email_receivers) > 0 ? 1 : 0

  name                = "ag-ekb-platform-management"
  resource_group_name = azurerm_resource_group.management.name
  short_name          = "ekbplatform"
  location            = "Global"
  tags                = var.tags

  dynamic "email_receiver" {
    for_each = var.alert_email_receivers
    content {
      name                    = email_receiver.key
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = true
    }
  }
}

resource "azurerm_monitor_activity_log_alert" "service_health" {
  count = length(var.alert_email_receivers) > 0 ? 1 : 0

  name                = "alert-ekb-platform-service-health"
  resource_group_name = azurerm_resource_group.management.name
  location            = "Global"
  scopes              = ["/subscriptions/${var.subscription_id}"]
  description         = "Notifies the platform team about Azure Service Health events."
  enabled             = true

  criteria {
    category = "ServiceHealth"
  }

  action {
    action_group_id = azurerm_monitor_action_group.management[0].id
  }
}

resource "azurerm_policy_definition" "allowed_locations" {
  name                = "${local.root_id}-allowed-locations"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "EkbTechForge: allowed resource locations"
  management_group_id = "/providers/Microsoft.Management/managementGroups/${local.root_id}"

  parameters = jsonencode({
    allowedLocations = {
      type = "Array"
      metadata = {
        displayName = "Allowed locations"
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        { field = "location", exists = "true" },
        { field = "location", notIn = "[parameters('allowedLocations')]" },
      ]
    }
    then = { effect = "deny" }
  })
}

resource "azurerm_management_group_policy_assignment" "allowed_locations" {
  name                 = "${local.root_id}-allowed-locations"
  display_name         = "EkbTechForge: allowed resource locations"
  management_group_id  = "/providers/Microsoft.Management/managementGroups/${local.root_id}"
  policy_definition_id = azurerm_policy_definition.allowed_locations.id
  parameters = jsonencode({
    allowedLocations = { value = var.allowed_locations }
  })
}

resource "azurerm_policy_definition" "required_tag" {
  for_each = local.required_tag_policy_ids

  name                = each.value
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "EkbTechForge: require ${each.key} tag"
  management_group_id = "/providers/Microsoft.Management/managementGroups/${local.root_id}"

  parameters = jsonencode({
    tagName = {
      type = "String"
      metadata = {
        displayName = "Tag name"
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      field  = "[concat('tags[', parameters('tagName'), ']')]"
      exists = "false"
    }
    then = { effect = "deny" }
  })
}

resource "azurerm_management_group_policy_assignment" "required_tag" {
  for_each = local.required_tag_policy_ids

  name                 = each.value
  display_name         = "EkbTechForge: require ${each.key} tag"
  management_group_id  = "/providers/Microsoft.Management/managementGroups/${local.root_id}"
  policy_definition_id = azurerm_policy_definition.required_tag[each.key].id
  parameters = jsonencode({
    tagName = { value = each.key }
  })
}

resource "azurerm_policy_definition" "allowed_resource_types" {
  name                = "${local.root_id}-allowed-resource-types"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "EkbTechForge: allowed resource types"
  management_group_id = "/providers/Microsoft.Management/managementGroups/${local.root_id}"

  parameters = jsonencode({
    allowedResourceTypes = {
      type = "Array"
      metadata = {
        displayName = "Allowed resource types"
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      field = "type"
      notIn = "[parameters('allowedResourceTypes')]"
    }
    then = { effect = "deny" }
  })
}

resource "azurerm_management_group_policy_assignment" "allowed_resource_types" {
  name                 = "${local.root_id}-allowed-resource-types"
  display_name         = "EkbTechForge: allowed resource types"
  management_group_id  = "/providers/Microsoft.Management/managementGroups/${local.root_id}"
  policy_definition_id = azurerm_policy_definition.allowed_resource_types.id
  parameters = jsonencode({
    allowedResourceTypes = { value = var.allowed_resource_types }
  })
}

resource "azurerm_policy_definition" "deny_public_ips" {
  name                = "${local.root_id}-deny-public-ips"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "EkbTechForge: deny public IP resources"
  management_group_id = "/providers/Microsoft.Management/managementGroups/${local.root_id}"

  policy_rule = jsonencode({
    if = {
      field  = "type"
      equals = "Microsoft.Network/publicIPAddresses"
    }
    then = { effect = "deny" }
  })
}

resource "azurerm_management_group_policy_assignment" "deny_public_ips" {
  name                 = "${local.root_id}-deny-public-ips"
  display_name         = "EkbTechForge: deny public IP resources"
  management_group_id  = "/providers/Microsoft.Management/managementGroups/${local.root_id}"
  policy_definition_id = azurerm_policy_definition.deny_public_ips.id
}