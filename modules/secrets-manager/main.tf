##MYSQL
resource "aws_secretsmanager_secret" "mysql" {
  name = "${var.env}/mysql"

  tags = {
    Environment = var.env
    Service     = "mysql"
  }
}

resource "aws_secretsmanager_secret_version" "mysql" {
  secret_id = aws_secretsmanager_secret.mysql.id

  secret_string = jsonencode({
    username = var.mysql_username
    password = var.mysql_password
  })
}

#DocumentDB
resource "aws_secretsmanager_secret" "documentdb" {
  name = "${var.env}/documentdb"

  tags = {
    Environment = var.env
    Service     = "documentdb"
  }
}

resource "aws_secretsmanager_secret_version" "documentdb" {
  secret_id = aws_secretsmanager_secret.documentdb.id

  secret_string = jsonencode({
    username = var.docdb_username
    password = var.docdb_password
  })
}
