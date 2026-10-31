variable "subscription_id" {
  description = "Azure subscription ID. Leave null to use ARM_SUBSCRIPTION_ID or the active Azure CLI subscription."
  type        = string
  default     = null
  nullable    = true
}

variable "name_prefix" {
  description = "Short lowercase prefix used in Azure resource names."
  type        = string
}

variable "environment" {
  description = "Environment identifier used in names and tags."
  type        = string
  validation {
    condition     = contains(["dev", "test"], var.environment)
    error_message = "environment must be dev or test."
  }
}

variable "location" {
  description = "Azure region for the environment resources."
  type        = string
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version. Null selects the Azure-supported default."
  type        = string
  default     = null
  nullable    = true
}

variable "aks_sku_tier" {
  description = "AKS control plane tier."
  type        = string
  default     = "Standard"
}

variable "private_cluster_enabled" {
  description = "Whether the AKS API server is private."
  type        = bool
  default     = true
}

variable "api_server_authorized_ip_ranges" {
  description = "Optional CIDR allow-list for a public AKS API server; null omits the allow-list block."
  type        = list(string)
  default     = null
  nullable    = true
}

variable "admin_group_object_ids" {
  description = "Microsoft Entra group object IDs to receive AKS cluster-admin permissions."
  type        = list(string)
  default     = []
}

variable "system_node_vm_size" {
  description = "VM size for the AKS system node pool."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "system_node_count" {
  description = "Initial system node count."
  type        = number
  default     = 2
}

variable "system_node_min_count" {
  description = "Minimum autoscaled system node count."
  type        = number
  default     = 2
}

variable "system_node_max_count" {
  description = "Maximum autoscaled system node count."
  type        = number
  default     = 3
}

variable "additional_node_pools" {
  description = "Additional autoscaling node pools keyed by a short pool name."
  type = map(object({
    vm_size     = string
    min_count   = number
    max_count   = number
    node_labels = optional(map(string), {})
    node_taints = optional(list(string), [])
  }))
  default = {}
}

variable "acr_sku" {
  description = "Azure Container Registry SKU."
  type        = string
  default     = "Basic"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "acr_sku must be Basic, Standard, or Premium."
  }
}

variable "acr_public_network_access_enabled" {
  description = "Whether the ACR public endpoint is enabled. Disable only when private connectivity is provided."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional Azure resource tags."
  type        = map(string)
  default     = {}
}
