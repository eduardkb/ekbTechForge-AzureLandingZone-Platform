# EkbTechForge Azure Landing Zone

Terraform configuration for a small-company Azure platform, split into three independent roots and remote states:

| Root | State key | Owns |
| --- | --- | --- |
| `platform-management` | `platform-management.tfstate` | ALZ management-group hierarchy, management workspace, optional action group/diagnostics, and root-scope policies/RBAC |
| `platform-connectivity` | `platform-connectivity.tfstate` | Resource group, hub VNet, low-cost subnets, optional VNet peerings |
| `platform-security-identity` | `platform-security-identity.tfstate` | Free Defender for Cloud pricing tiers; no identity resources |

The hierarchy uses Microsoft's supported [ALZ Terraform pattern module](https://registry.terraform.io/modules/Azure/avm-ptn-alz/azurerm/latest), and the workspace and VNet use Microsoft's [AVM Log Analytics](https://registry.terraform.io/modules/Azure/avm-res-operationalinsights-workspace/azurerm/latest) and [AVM Virtual Network](https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest) modules. The deprecated `caf-enterprise-scale` module is intentionally not used.

## Cost Defaults

- No Azure Firewall, VPN/ExpressRoute gateway, NAT Gateway, DDoS plan, public IP, private endpoint, Sentinel, Automation account, or paid Defender plan is deployed.
- The Log Analytics workspace is enabled with a `0.5 GB/day` ingestion cap and 30-day retention. Workspace ingestion and retention can incur charges; the daily cap limits ingestion, not the Azure bill. Set `create_log_analytics_workspace = false` if you want no workspace cost until needed.
- Subscription diagnostic settings are disabled by default because sending logs to Log Analytics is metered. Alert email receivers are empty by default; an action group is only created when receivers are configured.
- VNet, subnets, management groups, policy assignments, and Free Defender plans have no direct hourly compute charge. Azure egress, DNS query volume, and use of optional services may still incur charges.
- Foundational CSPM in Defender for Cloud is free. The security root explicitly sets available Defender plan resource types to `Free`; it never opts into `Standard`.

## Before Deploying

1. Confirm the tenant root management group and subscription to manage. The subscription used for Terraform state can be separate from `subscription_id` below. Do not place the state-storage subscription under this hierarchy unless that is intentional.
2. Give the deployment identity permissions to create management groups and policy definitions/assignments at the tenant root, plus the required subscription-level resource and role-assignment permissions. Management-group deployments generally need a tenant-root `Management Group Contributor` equivalent and `Resource Policy Contributor`; role assignments require `Role Based Access Control Administrator` or `User Access Administrator`. Keep permanent privilege minimal and use PIM where available.
3. Create a private blob container in the existing state storage account. Enable blob versioning and soft delete on the state account. State contains infrastructure metadata and must be access-controlled.
4. Copy each root's `terraform.tfvars.example` to `terraform.tfvars` and set real IDs, naming, network ranges, and email addresses. These files are ignored by Git.

Terraform 1.12+ is required for the current ALZ pattern module. Log in with an identity that has the permissions above (for local use, `az login` and select the target subscription). For each root, configure the same backend account/container but use its separate key:

```powershell
cd platform-management
terraform init -backend-config="resource_group_name=<state-rg>" -backend-config="storage_account_name=<state-account>" -backend-config="container_name=<state-container>" -backend-config="key=platform-management.tfstate" -backend-config="use_azuread_auth=true"
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Repeat in `platform-connectivity` and `platform-security-identity`, changing the backend key to the value in the table. The security and connectivity roots do not depend on outputs from the management root; their management groups and policy guardrails are established by the first root. Deploy each root with its own GitHub Actions job/workflow and the same backend account/container, passing the matching key. Do not run `apply` concurrently against the same key.

The configuration includes a manually dispatched GitHub Actions workflow for selecting one root at a time. Configure repository variables `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `PLATFORM_SUBSCRIPTION_ID`, `TFSTATE_RESOURCE_GROUP`, `TFSTATE_STORAGE_ACCOUNT`, and `TFSTATE_CONTAINER`, and establish a GitHub OIDC federated credential for the workflow. The GitHub identity needs the Azure permissions described above. The workflow's `apply` option defaults to false.

## Customization Notes

- `root_management_group_id` is the immutable Azure management-group ID (`ekbtechforge` by default); its display name is `EkbTechForge`. Azure IDs should be lowercase and must not be renamed after creation.
- The ALZ architecture contains `EkbTechForge > Platform > Management, Security, Identity, Connectivity`, plus `Landing Zones > Corp, Online` and `Sandbox`. The baseline ALZ library supplies Microsoft policy archetypes. The custom policies are assigned at the EkbTechForge management group.
- Allowed locations default to `southcentralus`, `eastus`, `eastus2`, `westus`, and `westus2`. Azure region names use this form, not `us_east` / `us_west`.
- Required tags and allowed resource types are configurable in `platform-management/terraform.tfvars`. The allowed-type list is an explicit allow-list: add every resource type your workloads and deployment tooling require before applying the policy.
- `management_group_role_assignments` is empty by default. Add Entra security-group object IDs for named, least-privilege roles such as `Reader` or `Security Reader`. Avoid permanent `Owner`/`Contributor` at the root; use PIM and narrower scopes for elevation.
- `subscription_placement` is also empty by default. Set it only when you intentionally want this state to move subscriptions under the ALZ hierarchy; the management root is the sole owner of those placements.
- `platform-connectivity` creates only a VNet and subnets unless peerings are provided. A VNet alone does not provide outbound internet or hybrid connectivity. No public IP is created.
- There is intentionally no cross-state Terraform remote-state lookup. The roots are independently deployable and use inputs for subscription IDs; this avoids coupling deployments or exposing state outputs unnecessarily.

Review all policy assignments and the first `terraform plan` with the organization's workload requirements before applying. A deny policy can block future deployments by design.