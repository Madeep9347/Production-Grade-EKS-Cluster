#EKS Security Group (Control Plane)
resource "aws_security_group" "eks_cluster_sg" {
  name        = "eks-cluster-sg-${var.env}"
  description = "EKS control plane security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # e.g. 10.0.0.0/16
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "eks-cluster-sg"
    Environment = var.env
    Project     = "eks-platform"
  }
}
#EKS Cluster
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.eks_cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = {
    Name        = var.cluster_name
    Environment = var.env
    Project     = "eks-platform"
  }
}

# Managed Node Group
resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-al2023-ng"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.private_subnet_ids

  ami_type       = "AL2023_x86_64_STANDARD"
  instance_types = var.instance_types
  capacity_type  = "ON_DEMAND"

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  disk_size = 20

  labels = {
    role = "general"
    os   = "amazon-linux"
  }

  tags = {
    # EC2 / ASG identification
    Name        = "${var.cluster_name}-worker"
    Environment = var.env
    Project     = "eks-platform"

    # REQUIRED for Kubernetes ownership
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"

    # REQUIRED for Cluster Autoscaler
    "k8s.io/cluster-autoscaler/enabled"          = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"

    # Useful metadata
    "eks:nodegroup-name" = "${var.cluster_name}-al2023-ng"
    "eks:cluster-name"   = var.cluster_name
  }

  depends_on = [
    aws_eks_cluster.this
  ]
}





#OIDC provider
#Data source to read cluster identity
data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.this.name
}

#Get TLS thumbprint
data "tls_certificate" "eks_oidc" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

#Create OIDC provider
resource "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint
  ]

  depends_on = [
    aws_eks_cluster.this
  ]

  tags = {
    Name        = "${var.cluster_name}-oidc"
    Environment = var.env
    Project     = "eks-platform"
  }
}

#IRSA
#Trust policy for EBS CSI
data "aws_iam_policy_document" "ebs_csi_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

#Create the IRSA role
resource "aws_iam_role" "ebs_csi_irsa" {
  name               = "${var.cluster_name}-ebs-csi-irsa"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json

  tags = {
    Name        = "ebs-csi-irsa"
    Environment = var.env
    Project     = "eks-platform"
  }
}

#Attach AWS managed policy
resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  role       = aws_iam_role.ebs_csi_irsa.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

#Install EBS CSI Driver (BEST PRACTICE)
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = aws_eks_cluster.this.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_irsa.arn

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_policy
  ]
}
