output "resource_group_name" {
  description = "Name of the environment resource group."
  value       = module.rg.name
}

output "aks_cluster_name" {
  description = "AKS cluster name."
  value       = module.aks.name
}

output "acr_name" {
  description = "Azure Container Registry name."
  value       = module.acr.name
}

output "acr_login_server" {
  description = "Azure Container Registry login server."
  value       = module.acr.login_server
}
