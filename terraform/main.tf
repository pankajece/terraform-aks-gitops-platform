locals {
  resource_group_name = "rg-${var.name_prefix}-${var.environment}"
  aks_name            = "aks-${var.name_prefix}-${var.environment}"
  acr_name            = "${var.name_prefix}${var.environment}acr"
  tags = merge(var.tags, {
    environment = var.environment
    managed_by  = "terraform"
  })
}

module "rg" {
  source = "./modules/rg"
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}

module "aks" {
  source = "./modules/aks"

  name                            = local.aks_name
  resource_group_name             = module.rg.name
  location                        = module.rg.location
  kubernetes_version              = var.kubernetes_version
  sku_tier                        = var.aks_sku_tier
  private_cluster_enabled         = var.private_cluster_enabled
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges
  admin_group_object_ids          = var.admin_group_object_ids
  system_node_vm_size             = var.system_node_vm_size
  system_node_count               = var.system_node_count
  system_node_min_count           = var.system_node_min_count
  system_node_max_count           = var.system_node_max_count
  additional_node_pools           = var.additional_node_pools
  tags                            = local.tags
}

module "acr" {
  source = "./modules/acr"

  name                          = local.acr_name
  resource_group_name           = module.rg.name
  location                      = module.rg.location
  sku                           = var.acr_sku
  public_network_access_enabled = var.acr_public_network_access_enabled
  tags                          = local.tags
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_identity_object_id
  principal_type       = "ServicePrincipal"
}
