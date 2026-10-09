variable "subscription_id" {
  type        = string
  description = "Subscription where Defender for Cloud pricing settings are managed."
}

variable "defender_plan_resource_types" {
  type        = set(string)
  description = "Defender for Cloud plans explicitly pinned to the Free tier. Do not change to Standard without a cost review."
  default = [
    "AI",
    "Api",
    "AppServices",
    "CloudPosture",
    "ContainerRegistry",
    "Containers",
    "CosmosDbs",
    "Dns",
    "KeyVaults",
    "KubernetesService",
    "OpenSourceRelationalDatabases",
    "SqlServerVirtualMachines",
    "SqlServers",
    "StorageAccounts",
    "VirtualMachines",
    "Arm",
  ]
}