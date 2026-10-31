variable "name" {
  description = "AKS cluster name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the cluster."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version, or null to use the Azure-supported default."
  type        = string
  default     = null
  nullable    = true
}

variable "sku_tier" {
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
  description = "Optional CIDR allow-list for a public API server."
  type        = list(string)
  default     = null
  nullable    = true
}

variable "admin_group_object_ids" {
  description = "Microsoft Entra group object IDs granted AKS cluster-admin."
  type        = list(string)
  default     = []
}

variable "system_node_vm_size" {
  description = "System node pool VM size."
  type        = string
}

variable "system_node_count" {
  description = "Initial system node count."
  type        = number
}

variable "system_node_min_count" {
  description = "Minimum autoscaled system node count."
  type        = number
}

variable "system_node_max_count" {
  description = "Maximum autoscaled system node count."
  type        = number
}

variable "additional_node_pools" {
  description = "Additional autoscaling user node pools keyed by short pool name."
  type = map(object({
    vm_size     = string
    min_count   = number
    max_count   = number
    node_labels = optional(map(string), {})
    node_taints = optional(list(string), [])
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to the cluster and node pools."
  type        = map(string)
  default     = {}
}
