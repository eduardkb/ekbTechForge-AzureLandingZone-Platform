# EkbTechForge Azure Landing Zone

## Summary

- Replace with content

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
  - On Root Management Group:
    - Allows creating Management Groups: Assign the "Management Group Contributor" role from the Job Function Roles to the SP on the root Management Group.     
    - Allows creating resources: Create custom role below (replacing <ROOT_MANAGEMENT_GROUP_ID> with it's ID from the overview blade) and assign it to the SP on the root Management Group.
    - Allows assigning RBAC Roles to management groups: Assign the "Role Based Access Control Administrator" role from the Priviledged administrator Roles to the SP on the root Management Group. 
    - Allows assigning Policies to management groups: Assign the "Resource Policy Contributor" role from the Job Function Roles to the SP on the root Management Group. 
  - On Bootstrap Storage Account:
    - Allows writing terraform state files to bootstrap storage account: Assing "Storage Blob Data Contributor" to the service principal on the bootstrap storage account.
  - On Billing Profile:
    - Allows creating subscriptions: Access "Cost Management + Billing" -> "Billing Profiles" -> select the billing profile -> Access Control (IAM) -> Add Role Assignment and add "Billing Profile Contributor" role to the dSP.
  - On Entra ID:
    - Allows creating security groups: Go to Entra ID -> Roles and Administrator -> select "Groups Administrator" -> Add Assignments and add the GitHub Service Principal.
  

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
Build the INVOICE_SECTION_ID
- Go to a subscription using the same billing profile as the new subscriptions
- Access "Billing Properties" blade of the sunbscription.
- all parameners needed are on this screen. Replaace each one on the string below
- Format of the INVOICE_SECTION_ID: "/providers/Microsoft.Billing/billingAccounts/<BILLING_ACCOUNT_ID>/billingProfiles/<BILLING_PROFILE_ID>/invoiceSections/<INVOICE_SECTIONS_ID>"
- Use the built string on the variable below.

Configure following Variables as repository variables in the github repository (Inside Repo Settings -> Secrets and Variables -> Actions -> Variabels -> New Repository Variable):
- AZURE_CLIENT_ID
- AZURE_TENANT_ID
- PLATFORM_SUBSCRIPTION_ID    (the ID of the bootstrap subscription)
- INVOICE_SECTION_ID          (from above explained section how to get the INVOICE_SECTION_ID)
- TFSTATE_RESOURCE_GROUP
- TFSTATE_STORAGE_ACCOUNT
- TFSTATE_CONTAINER


## Platform - Foundation Details

- Replace with content

## Platform - Management Details

- Replace with content

## Platform - Connectivity Details

- Replace with content

## Platform - Security/Identity Details

- Replace with content

## TODO List:

- 5 subs limit problem
 	bootstrap
	management
	connectivity
	app-a
	app-b


add eduard buhali as owner to everything below root mg.