# EkbTechForge Azure Landing Zone

## Summary

- TODO: Replace with content

## Pre-Requisites

### Create App Registration
- Go to Azure EntraID and create a App Registration
- Setup Federated Credentials
  - open AppReg and navigate to "Certificates & Secrets" -> "Federated Credentials" -> "Add Credential".
  - Scenario = Github Actions
  - Fill out fileds
  - Organization ID (Get ID Number from: https://api.github.com/users/<USER_ID>)
  - Repository ID (Get ID Number from: https://api.github.com/repos/<USER_ID>/<REPO_NAME>).
  - Entity type = Environment
  - Env. Name = "azure-platform"
  - give it a name
  - Save

### Assign required access to the Service Principal
- Setup Access for teh Application Registration's Service Principal
  - Allows creating Management Groups: Assign the "Management Group Contributor" role from the Job Function Roles to the SP on the root Management Group. 
  - Allows creating subscriptions: Access "Cost Management + Billing" -> "Billing Profiles" -> select the billing profile -> Access Control (IAM) -> Add Role Assignment and add "Billing Profile Contributor" role to the SP.
  - Allows creating security groups: Go to Entra ID -> Roles and Administrator -> select "Groups Administrator" -> Add Assignments and add the GitHub Service Principal.
  - Allows creating resources: Create custom role below (replacing <ROOT_MANAGEMENT_GROUP_ID> with it's ID from the overview blade) and assign it to the SP on the root Management Group.

```JSON
{
  "properties": {
    "roleName": "Git-Platform-LandingZone-Contributor",
    "description": "Create, read, modify, and delete Landing Zone networking, DNS, storage, Defender for Cloud, Log Analytics, Azure Monitor, diagnostic settings, alerts, and action groups.",
    "assignableScopes": 
      ["/providers/Microsoft.Management/managementGroups/<ROOT_MANAGEMENT_GROUP_ID>"],    
    "permissions": [
      {
        "actions": [
          "Microsoft.Network/virtualNetworks/*",
          "Microsoft.Network/virtualNetworks/subnets/*",
          "Microsoft.Network/privateEndpoints/*",
          "Microsoft.Network/privateDnsZones/*",
          "Microsoft.Network/dnsZones/*",
          "Microsoft.Storage/storageAccounts/*",
          "Microsoft.Security/*",
          "Microsoft.OperationalInsights/workspaces/*",
          "Microsoft.OperationalInsights/operations/read",
          "Microsoft.Insights/*",
          "Microsoft.AlertsManagement/*",
          "Microsoft.Resources/deployments/*",
          "Microsoft.Resources/subscriptions/resourceGroups/read",
          "Microsoft.Resources/subscriptions/providers/read",
          "Microsoft.Authorization/*/read",
          "Microsoft.Network/register/action",
          "Microsoft.Storage/register/action",
          "Microsoft.Security/register/action",
          "Microsoft.OperationalInsights/register/action",
          "Microsoft.Insights/register/action"
        ],
        "notActions": [],
        "dataActions": [],
        "notDataActions": []
      }
    ]
  }
}
```

### Create Github Variables
Configure following Variables as repository variables in the github repository (Inside Repo Settings -> Secrets and Variables -> Actions -> Variabels -> New Repository Variable):
- AZURE_CLIENT_ID
- AZURE_TENANT_ID
- PLATFORM_SUBSCRIPTION_ID
- TFSTATE_RESOURCE_GROUP
- TFSTATE_STORAGE_ACCOUNT
- TFSTATE_CONTAINER


## Platform - Foundation Details

- TODO: Replace with content

## Platform - Management Details

- TODO: Replace with content

## Platform - Connectivity Details

- TODO: Replace with content

## Platform - Security/Identity Details

- TODO: Replace with content
