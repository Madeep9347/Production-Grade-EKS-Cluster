# Security Group for Bastion Host
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg-${var.eks_cluster_name}"
  description = "Security group for bastion host (${var.eks_cluster_name})"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # tighten later
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name            = "bastion-sg-${var.eks_cluster_name}"
    Environment     = var.env
    EKSClusterName  = var.eks_cluster_name
    Project         = "eks-platform"
  }
}

# Bastion EC2 Instance
resource "aws_instance" "bastion_host" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_pair
  subnet_id                   = var.public_subnet_ids[0]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/user_data.sh")

  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]

  tags = {
    Name            = "bastion-${var.eks_cluster_name}"
    Environment     = var.env
    EKSClusterName  = var.eks_cluster_name
    Project         = "eks-platform"
  }
}
