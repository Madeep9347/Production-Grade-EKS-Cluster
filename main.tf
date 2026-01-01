
########################################
# VPC MODULE
########################################

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr = var.vpc_cidr
  env      = var.env
  eks_cluster_name = var.cluster_name
}

########################################
# EC2 MODULE
########################################

module "ec2" {
  source = "./modules/ec2"

  ami                = var.ami
  key_pair           = var.key_pair
  env                = var.env
  instance_type = var.instance_type

  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
}

########################################
# IAM MODULE
########################################

module "iam" {
  source = "./modules/iam"

  env = var.env
}

########################################
# EKS MODULE
########################################

module "eks" {
  source = "./modules/eks"

  cluster_name              = var.cluster_name
  kubernetes_version        = var.kubernetes_version
  env                       = var.env

  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids

  eks_cluster_role_arn      = module.iam.eks_cluster_role_arn
  eks_node_role_arn         = module.iam.eks_node_role_arn
}
