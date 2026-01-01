variable "cluster_name" {
  type = string
  default = "prod-eks-cluster"
}

variable "env" {
  type = string
  default = "prod"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "kubernetes_version" {
  type    = string
  default = "1.33"
}

variable "ami" {
  type=string
  default = "ami-02b8269d5e85954ef"
  
}

variable "key_pair" {
  type=string
  default = "heliosolutions"
  
}

variable "instance_type" {
  type = string
  default = "t3.micro"
  
}
