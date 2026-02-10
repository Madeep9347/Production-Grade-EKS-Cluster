variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "argocd_namespace" {
  description = "Namespace for Argo CD"
  type        = string
  default     = "argocd"
}
