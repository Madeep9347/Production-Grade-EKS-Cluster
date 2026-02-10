
variable "env" {
  description = "Environment name (dev/stage/prod)"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
}
variable "instance_types" {
  type= list(string)
  
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

#EC2
variable "ami" {
  description = "AMI for EC2 instances"
  type        = string
}

variable "key_pair" {
  description = "EC2 key pair name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

# RDS
variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

# RDS MySQL
variable "mysql_db_name" {
  description = "MySQL database name"
  type        = string
}

variable "mysql_instance_class" {
  description = "RDS MySQL instance class"
  type        = string
}

variable "mysql_skip_final_snapshot" {
  description = "Skip final snapshot on delete"
  type        = bool
}

variable "mysql_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
}

# Documentdb (mongodb supported)
# DocumentDB
variable "documentdb_name" {
  description = "DocumentDB cluster name"
  type        = string
}

variable "docdb_skip_final_snapshot" {
  description = "Skip final snapshot for DocumentDB"
  type        = bool
}

variable "docdb_username" {
  description = "Master username for DocumentDB"
  type        = string
  sensitive   = true
}

variable "docdb_password" {
  description = "Master password for DocumentDB"
  type        = string
  sensitive   = true
}
