provider "azurerm" {
  features {
    subscription {
      prevent_cancellation_on_destroy = false
    }
  }
  resource_provider_registrations = "none"
  subscription_id                 = var.platform_subscription_id
}

provider "azuread" {
  tenant_id = data.azurerm_client_config.current.tenant_id
}

provider "alz" {
  library_overwrite_enabled = true
  library_references = [
    {
      path = "platform/alz"
      ref  = "2026.04.2"
    },
    {
      custom_url = "${path.root}/lib"
    },
  ]
}

data "azurerm_client_config" "current" {}

locals {
  management_group_ids = {
    corporate                   = "corporate"
    platform                    = "platform"
    management                  = "platform-management"
    connectivity                = "platform-connectivity"
    security                    = "platform-security"
    identity                    = "platform-identity"
    ekbtechforge                = "ekbtechforge"
    ekbtechforge_production     = "ekbtechforge-production"
    ekbtechforge_nonproduction  = "ekbtechforge-nonproduction"
    ekbtechforge_sandbox        = "ekbtechforge-sandbox"
    lfzstratcraft               = "lfzstratcraft"
    lfzstratcraft_production    = "lfzstratcraft-production"
    lfzstratcraft_nonproduction = "lfzstratcraft-nonproduction"
    lfzstratcraft_sandbox       = "lfzstratcraft-sandbox"
  }

  management_group_resource_ids = {
    for key, id in local.management_group_ids : key => "/providers/Microsoft.Management/managementGroups/${id}"
  }

  platform_subscriptions = {
    management   = var.platform_subscriptions.management
    connectivity = var.platform_subscriptions.connectivity
  }
}

module "alz_foundation" {
  source  = "Azure/avm-ptn-alz/azurerm"
  version = "0.12.0"

  architecture_name  = "ekbtechforge"
  location           = var.location
  parent_resource_id = data.azurerm_client_config.current.tenant_id
  enable_telemetry   = var.enable_telemetry
}

resource "azurerm_subscription" "platform" {
  for_each = local.platform_subscriptions

  subscription_name = each.value.subscription_name
  billing_scope_id  = var.invoice_section_id
  # workload          = each.value.workload
}

resource "azurerm_management_group_subscription_association" "platform" {
  for_each = azurerm_subscription.platform

  management_group_id = local.management_group_resource_ids[each.key]
  subscription_id     = "/subscriptions/${each.value.subscription_id}"

  depends_on = [module.alz_foundation]
}

data "azurerm_policy_definition" "allowed_locations" {
  display_name = "Allowed locations"
}

data "azurerm_policy_definition" "required_tag" {
  display_name = "Require a tag on resources"
}

data "azurerm_policy_definition" "allowed_resource_types" {
  display_name = "Allowed resource types"
}

resource "azurerm_management_group_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  display_name         = "Allowed locations"
  management_group_id  = local.management_group_resource_ids.corporate
  policy_definition_id = data.azurerm_policy_definition.allowed_locations.id
  parameters = jsonencode({
    listOfAllowedLocations = { value = var.allowed_locations }
  })
}

resource "azurerm_management_group_policy_assignment" "required_tags" {
  for_each = toset(var.required_tags)

  name                 = "required-tag-${substr(sha1(each.value), 0, 8)}"
  display_name         = "Require tag: ${each.value}"
  management_group_id  = local.management_group_resource_ids.corporate
  policy_definition_id = data.azurerm_policy_definition.required_tag.id
  parameters = jsonencode({
    tagName = { value = each.value }
  })
}

resource "azurerm_management_group_policy_assignment" "allowed_resource_types" {
  name                 = "allowed-resource-types"
  display_name         = "Allowed resource types"
  management_group_id  = local.management_group_resource_ids.corporate
  policy_definition_id = data.azurerm_policy_definition.allowed_resource_types.id
  parameters = jsonencode({
    listOfResourceTypesAllowed = { value = var.allowed_resource_types }
  })
}

resource "azurerm_management_group_policy_assignment" "deny_public_ip" {
  name                 = "deny-public-ip-on-nics"
  display_name         = "Deny public IPs on NICs"
  management_group_id  = local.management_group_resource_ids.corporate

  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/83a86a26-fd1f-447c-b59d-e51f44264114"
}

resource "azuread_group" "security" {
  for_each = var.security_groups

  display_name     = each.key
  description      = each.value.description
  security_enabled = true
  mail_enabled     = false
}

resource "azurerm_role_assignment" "management_group" {
  for_each = var.group_role_assignments

  scope                = local.management_group_resource_ids[each.value.management_group_key]
  role_definition_name = each.value.role_definition_name
  principal_id         = azuread_group.security[each.value.group_name].object_id
  principal_type       = "Group"
}