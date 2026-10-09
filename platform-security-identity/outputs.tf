output "free_defender_plan_types" {
  description = "Defender for Cloud plan resource types kept at the Free tier."
  value       = sort(tolist(var.defender_plan_resource_types))
}
