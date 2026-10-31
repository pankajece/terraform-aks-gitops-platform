name_prefix                     = "aksshow"
environment                     = "test"
location                        = "eastus2"
kubernetes_version              = null
aks_sku_tier                    = "Standard"
private_cluster_enabled         = true
api_server_authorized_ip_ranges = null
admin_group_object_ids          = []
system_node_vm_size             = "Standard_D2s_v5"
system_node_count               = 2
system_node_min_count           = 2
system_node_max_count           = 4
additional_node_pools = {
  user = {
    vm_size     = "Standard_D2s_v5"
    min_count   = 1
    max_count   = 4
    node_labels = { "workload" = "general" }
    node_taints = []
  }
}
acr_sku                           = "Standard"
acr_public_network_access_enabled = true
tags = {
  managed_by = "terraform"
  workload   = "aks"
}
