#VPC
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true


  tags = {
    Name = var.eks_cluster_name
    Environment = var.env
    Project     = "eks-platform"
    Owner       = "platform-team"
  }
}

#IGW
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.eks_cluster_name
  }
}
#AZ
data "aws_availability_zones" "available" {
  state = "available"
}

#public subnets
resource "aws_subnet" "public_subnets" {
  count = 3
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr,8,count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true


  tags = {
    Name = "public_subnet_${count.index+1}"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}

#private subnets
resource "aws_subnet" "private_subnets" {
  count = 3
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr,4,count.index+3)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private_subnets_${count.index+1}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}"="shared"
  }
}

#public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "public_route_table${var.eks_cluster_name}"
  }
}

#public subnet association
resource "aws_route_table_association" "public_rt_asso" {
  count=length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

#EIP for NAT
resource "aws_eip" "lb" {
  domain = "vpc"
}

#NAT gateway
resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "Nat_gateway_${var.eks_cluster_name}"
  }

  depends_on = [aws_internet_gateway.gw]
}


#private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.example.id
  }


  tags = {
    Name = "private_route_table${var.eks_cluster_name}"
  }
}

#private subnet association
resource "aws_route_table_association" "private_rt_asso" {
  count=length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

##vpc flowlogs
resource "aws_flow_log" "example" {
  iam_role_arn    = aws_iam_role.example.arn
  log_destination = aws_cloudwatch_log_group.example.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/vpc/flow-logs/${var.eks_cluster_name}"
  retention_in_days = 7
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "example" {
  name               = "example"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "example" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "example" {
  name   = "example"
  role   = aws_iam_role.example.id
  policy = data.aws_iam_policy_document.example.json
}