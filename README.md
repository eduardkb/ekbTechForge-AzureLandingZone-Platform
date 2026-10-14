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
Get the 


Configure following Variables as repository variables in the github repository (Inside Repo Settings -> Secrets and Variables -> Actions -> Variabels -> New Repository Variable):
- AZURE_CLIENT_ID
- AZURE_TENANT_ID
- PLATFORM_SUBSCRIPTION_ID  (the ID of the bootstrap subscription)
- BILLING_SCOPE_ID          (inside properties blade of the billing scope)
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

document get invoiceSectionId (or build it manually getting all 3 parameters)
	with billing account id found in azure execute below in cloud shell (powershell)
	then get the parameter "invoiceSectionId" from the result
		sample: /providers/Microsoft.Billing/billingAccounts/b75b932d-f3fb-5d49-e6de-5397e6b0a316:17ef770d-ab91-472e-9f0c-f8cac36b5e3d_2019-05-31/billingProfiles/BDBD-SEP3-BG7-PGB/invoiceSections/ZXGN-S5ZD-PJA-PGB
	
	```PowerShell
	$billingAccount = "b75b932d-f3fb-5d49-e6de-5397e6b0a316:17ef770d-ab91-472e-9f0c-f8cac36b5e3d_2019-05-31"

	# Get a token for Azure Resource Manager
	$token = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token
	$tokenPlainText = [System.Net.NetworkCredential]::new("", $token).Password
	$headers = @{
		Authorization = "Bearer $tokenPlainText"
	}

	$uri = "https://management.azure.com/providers/Microsoft.Billing/billingAccounts/$billingAccount/listInvoiceSectionsWithCreateSubscriptionPermission?api-version=2024-04-01"

	# List invoice sections where you can create subscriptions
	$result = Invoke-RestMethod -Method POST -Uri $uri -Headers $headers

	$result.value | Select-Object billingProfileDisplayName, billingProfileId, invoiceSectionDisplayName, invoiceSectionId | Format-List


	/providers/Microsoft.Billing/billingAccounts/b75b932d-f3fb-5d49-e6de-5397e6b0a316:17ef770d-ab91-472e-9f0c-f8cac36b5e3d_2019-05-31/billingProfiles/BDBD-SEP3-BG7-PGB
	```
	
Modify github variable from BILLING_SCOPE_ID to INVOICE_SECTION_ID
	- on variables
	- on git actions code
	- on terraform