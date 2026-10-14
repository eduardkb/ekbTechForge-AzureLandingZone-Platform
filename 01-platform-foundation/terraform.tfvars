# USED ON LOCAL DEPLOYMENT ONLY
platform_subscription_id = "00000000-0000-0000-0000-000000000000"
billing_scope_id         = "/providers/Microsoft.Billing/billingAccounts/<billing-account-id>/billingProfiles/<billing-profile-id>"

# GLOBAL VARIABLES
location                 = "southcentralus"
enable_telemetry         = false

# VARIABLES
platform_subscriptions = {
  management = {
    subscription_name   = "platform-management-sub"
    resource_group_name = "platform-management-rg"
  }
  connectivity = {
    subscription_name   = "platform-connectivity-sub"
    resource_group_name = "platform-connectivity-rg"
  }
  security = {
    subscription_name   = "platform-security-sub"
    resource_group_name = "platform-security-rg"
  }
}

resource_tags = {
  Environment = "Platform"
  ManagedBy   = "Terraform"
  CostCenter  = "CloudPlatform"
}

allowed_locations = [
  "southcentralus",
  "eastus",
  "eastus2",
  "westus2"
]

required_tags = [
  "Environment",
  "Owner",
  "CostCenter",
]

allowed_resource_types = [
  # Resource management
  "Microsoft.Resources/subscriptions/resourceGroups",

  # Networking
  "Microsoft.Network/virtualNetworks",
  "Microsoft.Network/virtualNetworks/subnets",
  "Microsoft.Network/networkInterfaces",
  "Microsoft.Network/networkSecurityGroups",
  "Microsoft.Network/publicIPAddresses",
  "Microsoft.Network/routeTables",
  "Microsoft.Network/privateDnsZones",
  "Microsoft.Network/privateDnsZones/virtualNetworkLinks",
  "Microsoft.Network/dnsZones",
  "Microsoft.Network/privateEndpoints",
  "Microsoft.Network/privateLinkServices",
  "Microsoft.Network/loadBalancers",
  "Microsoft.Network/applicationGateways",
  "Microsoft.Network/bastionHosts",
  "Microsoft.Network/natGateways",
  "Microsoft.Network/virtualNetworkGateways",
  "Microsoft.Network/connections",
  "Microsoft.Network/dnsResolvers",
  "Microsoft.Network/dnsResolvers/inboundEndpoints",
  "Microsoft.Network/dnsResolvers/outboundEndpoints",
  "Microsoft.Network/dnsForwardingRulesets",

  # Storage
  "Microsoft.Storage/storageAccounts",
  "Microsoft.Storage/storageAccounts/blobServices",
  "Microsoft.Storage/storageAccounts/fileServices",

  # Virtual machines and compute
  "Microsoft.Compute/virtualMachines",
  "Microsoft.Compute/virtualMachines/extensions",
  "Microsoft.Compute/disks",
  "Microsoft.Compute/snapshots",
  "Microsoft.Compute/availabilitySets",
  "Microsoft.Compute/virtualMachineScaleSets",
  "Microsoft.Compute/galleries",
  "Microsoft.Compute/galleries/images",
  "Microsoft.Compute/galleries/images/versions",

  # App Service, Web Apps and Function Apps
  "Microsoft.Web/serverfarms",
  "Microsoft.Web/sites",
  "Microsoft.Web/sites/slots",
  "Microsoft.Web/staticSites",
  "Microsoft.Web/certificates",
  "Microsoft.Web/hostingEnvironments",

  # Azure Functions dependencies
  "Microsoft.Insights/components",
  "Microsoft.Insights/autoscaleSettings",

  # Azure Container services
  "Microsoft.ContainerRegistry/registries",
  "Microsoft.ContainerInstance/containerGroups",
  "Microsoft.App/containerApps",
  "Microsoft.App/managedEnvironments",
  #"Microsoft.ContainerService/managedClusters",

  # Databases
  "Microsoft.Sql/servers",
  "Microsoft.Sql/servers/databases",
  "Microsoft.Sql/servers/firewallRules",
  "Microsoft.Sql/servers/elasticPools",
  "Microsoft.Sql/servers/administrators",
  #"Microsoft.DBforPostgreSQL/flexibleServers",
  #"Microsoft.DBforPostgreSQL/flexibleServers/databases",
  #"Microsoft.DBforMySQL/flexibleServers",
  #"Microsoft.DBforMySQL/flexibleServers/databases",
  "Microsoft.DocumentDB/databaseAccounts",
  #"Microsoft.Cache/redis",
  #"Microsoft.DataFactory/factories",

  # Key Vault and secrets
  "Microsoft.KeyVault/vaults",

  # Monitoring and logging
  "Microsoft.OperationalInsights/workspaces",
  "Microsoft.Insights/actionGroups",
  "Microsoft.Insights/metricAlerts",
  "Microsoft.Insights/activityLogAlerts",
  "Microsoft.Insights/diagnosticSettings",
  "Microsoft.Insights/scheduledQueryRules",

  # Security
  "Microsoft.Security/pricings",
  "Microsoft.Security/assessments",

  # Identity and access
  "Microsoft.ManagedIdentity/userAssignedIdentities",

  # Messaging and integration
  "Microsoft.ServiceBus/namespaces",
  #"Microsoft.EventHub/namespaces",
  "Microsoft.EventGrid/topics",
  "Microsoft.EventGrid/systemTopics",

  # API management
  #"Microsoft.ApiManagement/service",

  # Backup and recovery
  "Microsoft.RecoveryServices/vaults",
  "Microsoft.DataProtection/backupVaults",

  # Infrastructure automation
  "Microsoft.Automation/automationAccounts",
  "Microsoft.ManagedServices/registrationAssignments",

  # Configuration and deployment
  "Microsoft.Resources/deployments",
  "Microsoft.Resources/templateSpecs",

  # Front Door and CDN
  "Microsoft.Cdn/profiles",
  "Microsoft.Cdn/profiles/afdEndpoints",

  # Application configuration
  "Microsoft.AppConfiguration/configurationStores",
]

security_groups = {
  "SG-Azure-Platform-Readers" = {
    description = "Reader Corporate management group"
  }
  "SG-Azure-Platform-Admins" = {
    description = "Contributor Platform management group"
  }
  "SG-Azure-EkbTechForge-Admins" = {
    description = "Contributor Company-A management group"
  }
  "SG-Azure-EkbTechForge-Readers" = {
    description = "Reader Company-A management group"
  }
  "SG-Azure-CorpB-Admins" = {
    description = "Contributor Company-B management group"
  }
  "SG-Azure-CorpB-Readers" = {
    description = "Reader Company-B management group"
  }
}

group_role_assignments = {
  platform_readers = {
    group_name           = "SG-Azure-Platform-Readers"
    role_definition_name = "Reader"
    management_group_key = "platform"
  }
  platform_admins = {
    group_name           = "SG-Azure-Platform-Admins"
    role_definition_name = "Contributor"
    management_group_key = "platform"
  }
  ekbtechforge_admins = {
    group_name           = "SG-Azure-EkbTechForge-Admins"
    role_definition_name = "Contributor"
    management_group_key = "ekbtechforge"
  }
  ekbtechforge_readers = {
    group_name           = "SG-Azure-EkbTechForge-Readers"
    role_definition_name = "Reader"
    management_group_key = "ekbtechforge"
  }
  corpb_admins = {
    group_name           = "SG-Azure-CorpB-Admins"
    role_definition_name = "Contributor"
    management_group_key = "corp_b"
  }
  corpb_readers = {
    group_name           = "SG-Azure-CorpB-Readers"
    role_definition_name = "Reader"
    management_group_key = "corp_b"
  }
}