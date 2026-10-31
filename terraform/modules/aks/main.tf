data "azurerm_client_config" "current" {}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.name
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier

  private_cluster_enabled = var.private_cluster_enabled
  local_account_disabled  = true

  role_based_access_control_enabled = true
  azure_active_directory_role_based_access_control {
    tenant_id              = data.azurerm_client_config.current.tenant_id
    admin_group_object_ids = var.admin_group_object_ids
    azure_rbac_enabled     = true
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  automatic_upgrade_channel = "patch"

  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_node_vm_size
    node_count                   = var.system_node_count
    min_count                    = var.system_node_min_count
    max_count                    = var.system_node_max_count
    auto_scaling_enabled         = true
    only_critical_addons_enabled = true
    os_sku                       = "Ubuntu"
    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
  }

  dynamic "api_server_access_profile" {
    for_each = var.api_server_authorized_ip_ranges == null ? [] : [var.api_server_authorized_ip_ranges]
    content {
      authorized_ip_ranges = api_server_access_profile.value
    }
  }

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  for_each = var.additional_node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_size
  mode                  = "User"
  node_count            = each.value.min_count
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  auto_scaling_enabled  = true
  os_type               = "Linux"
  os_sku                = "Ubuntu"
  node_labels           = each.value.node_labels
  node_taints           = each.value.node_taints

  upgrade_settings {
    max_surge = "10%"
  }

  tags = var.tags
}
