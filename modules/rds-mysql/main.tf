########################################
# DB SUBNET GROUP
########################################
resource "aws_db_subnet_group" "mysql" {
  name       = "${var.environment}-mysql-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.environment}-mysql-subnet-group"
    Environment = var.environment
  }
}

########################################
# SECURITY GROUP
########################################
resource "aws_security_group" "mysql" {
  name        = "${var.environment}-mysql-sg"
  description = "Allow MySQL from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.eks_node_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-mysql-sg"
    Environment = var.environment
  }
}

########################################
# RDS MYSQL INSTANCE
########################################
resource "aws_db_instance" "mysql" {
  identifier = "${var.environment}-app-mysql"

  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = "gp2"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  vpc_security_group_ids = [aws_security_group.mysql.id]

  publicly_accessible     = false
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection
  backup_retention_period = 7

  tags = {
    Name        = "${var.environment}-mysql"
    Environment = var.environment
  }
}
