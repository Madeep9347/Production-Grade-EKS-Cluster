variable "cluster_name" {
  type = string
}

variable "env" {
  type = string
}

variable "kubernetes_version" {
  type    = string
}
variable "instance_types" {
  type = list(string)
  
}
variable "desired_size" {
  type = number
}
variable "min_size" {
  type = number
  
}
variable "max_size" {
  type = number
  
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "eks_cluster_role_arn" {
  type = string
}

variable "eks_node_role_arn" {
  type = string
}
