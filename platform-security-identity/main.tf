resource "azurerm_security_center_subscription_pricing" "free" {
  for_each = var.defender_plan_resource_types

  resource_type = each.value
  tier          = "Free"
}