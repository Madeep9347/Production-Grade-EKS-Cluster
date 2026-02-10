########################################
# VPC MODULE
########################################

module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr         = var.vpc_cidr
  env              = var.env
  eks_cluster_name = var.cluster_name
}

########################################
# EC2 MODULE (BASTION)
########################################

module "ec2" {
  source = "../../modules/ec2"

  ami           = var.ami
  key_pair      = var.key_pair
  env           = var.env
  instance_type = var.instance_type

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  eks_cluster_name  = var.cluster_name
}

########################################
# IAM MODULE
########################################

module "iam" {
  source = "../../modules/iam"
  env    = var.env
}

########################################
# EKS MODULE
########################################

module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  env                = var.env

  instance_types = var.instance_types
  desired_size   = var.desired_size
  min_size       = var.min_size
  max_size       = var.max_size

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  eks_cluster_role_arn = module.iam.eks_cluster_role_arn
  eks_node_role_arn    = module.iam.eks_node_role_arn
}

########################################
# RDS MYSQL
########################################

module "rds_mysql" {
  source = "../../modules/rds-mysql"

  environment = var.env

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  eks_node_sg_id     = module.eks.node_security_group_id

  db_name     = var.mysql_db_name
  db_username = var.db_username
  db_password = var.db_password

  instance_class      = var.mysql_instance_class
  skip_final_snapshot = var.mysql_skip_final_snapshot
  deletion_protection = var.mysql_deletion_protection
}

########################################
# DOCUMENTDB
########################################

module "documentdb" {
  source = "../../modules/documentdb"

  name               = var.documentdb_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  eks_node_sg_id     = module.eks.node_security_group_id

  master_username    = var.docdb_username
  master_password    = var.docdb_password
  skip_final_snapshot = var.docdb_skip_final_snapshot
}

########################################
# ARGOCD
########################################

module "argocd" {
  source = "../../modules/argocd"
  cluster_name = var.cluster_name
}

########################################
# ADDONS
########################################

module "addons" {
  source = "../../modules/addons"

  env          = var.env
  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url

  depends_on = [
    module.eks
  ]
}

########################################
# SECRETS MANAGER
########################################

module "secrets" {
  source = "../../modules/secrets-manager"

  env = var.env

  mysql_username = var.db_username
  mysql_password = var.db_password

  docdb_username = var.docdb_username
  docdb_password = var.docdb_password
}
