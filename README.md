# AKS Terraform foundation

Reusable Terraform for Azure Kubernetes Service and Azure Container Registry. A shared Terraform root calls the resource group, AKS, and ACR modules. Dev and test inputs are kept in separate tfvars files and use independent remote state keys.

## Layout

```text
.github/workflows/       PR checks and protected manual deployment
terraform/
  backend.tf            Shared AzureRM backend configuration
  provider.tf           Shared Terraform and AzureRM provider configuration
  main.tf               Calls rg, aks, and acr modules
  variable.tf           Shared root inputs
  output.tf             Shared root outputs
  environments/
    dev/dev.tfvars       Dev inputs
    test/test.tfvars     Test inputs
  modules/
    rg/                   Resource group
    aks/                  AKS cluster and optional user node pools
    acr/                  Azure Container Registry
```

## Prerequisites

- Terraform 1.8 or newer
- Azure subscription and permissions to create the resources in the selected environment
- An Azure Storage account/container for remote state, created separately
- For GitHub deployment: an Azure federated identity credential for GitHub OIDC

Terraform state can contain sensitive infrastructure metadata. Keep it in a private Azure Storage container with blob versioning, soft delete, and least-privilege Azure RBAC. Do not commit credentials or state files.

## Local use

Configure the Azure CLI (`az login`) and set `ARM_SUBSCRIPTION_ID`, or pass `subscription_id` in a local, untracked tfvars file. Configure the remote backend values as environment variables before initialization:

```powershell
$env:TF_STATE_RESOURCE_GROUP = "<state-resource-group>"
$env:TF_STATE_STORAGE_ACCOUNT = "<globally-unique-storage-account>"
$env:TF_STATE_CONTAINER = "tfstate"
```

From the shared Terraform root, initialize the backend and apply the desired tfvars:

```powershell
cd terraform
terraform init `
  -backend-config="resource_group_name=$env:TF_STATE_RESOURCE_GROUP" `
  -backend-config="storage_account_name=$env:TF_STATE_STORAGE_ACCOUNT" `
  -backend-config="container_name=$env:TF_STATE_CONTAINER" `
  -backend-config="key=aks/dev.tfstate" `
  -backend-config="use_azuread_auth=true"
terraform plan -var-file="environments/dev/dev.tfvars" -out="dev.tfplan"
terraform apply "dev.tfplan"
```

For test, remain in `terraform`, use `-var-file="environments/test/test.tfvars"`, and initialize with `key=aks/test.tfstate`. Terraform backend configuration is intentionally partial: each environment's state key is supplied at init time. For local OIDC backend auth, set `ARM_USE_OIDC=true`; Azure CLI authentication is also supported for local development.

## GitHub Actions setup

Configure repository variables `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, `TF_STATE_RESOURCE_GROUP`, `TF_STATE_STORAGE_ACCOUNT`, and `TF_STATE_CONTAINER`. The Azure identity must trust this repository's GitHub OIDC subject and have the required Azure deployment permissions. Assign the three Azure identity values as GitHub **variables** or **secrets**; the workflow reads them as variables. Create GitHub Environments named `terraform-dev` and `terraform-test`; configure required reviewers and branch restrictions there before enabling applies.

The PR workflow runs format, backend-free validation, and Trivy misconfiguration/secret scanning. The manual workflow creates a plan and applies that exact plan only when `apply` is selected; environment protection rules gate the job. Restrict who can dispatch deployment workflows. Pin third-party actions to reviewed commit SHAs if required by your organization.

## Configuration and production notes

- `terraform/environments/dev/dev.tfvars` and `terraform/environments/test/test.tfvars` are non-secret examples. Change names, region, node sizes, and CIDRs to match your Azure landing zone.
- AKS uses managed identity, Azure RBAC, OIDC/workload identity, a private API server by default, disabled local accounts, autoscaling, and a dedicated system node pool. The example also creates a user node pool so workloads have a schedulable pool.
- API server authorized IP ranges are an optional input for public API server configurations. The API server stays private unless `private_cluster_enabled` is changed.
- ACR admin credentials are disabled. The AKS kubelet identity receives `AcrPull` through a role assignment.
- A production deployment should add/attach a private endpoint and private DNS for ACR, private AKS connectivity, central logging/diagnostics, policy/monitoring, zone-aware sizing, and approved image/build policies according to the organization's landing zone. This baseline does not create those shared-network services.
- Review Trivy findings against your policy; do not suppress a finding without documenting the risk and compensating control.
