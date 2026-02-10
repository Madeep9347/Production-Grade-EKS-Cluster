output "mysql_secret_arn" {
  value = aws_secretsmanager_secret.mysql.arn
}

output "documentdb_secret_arn" {
  value = aws_secretsmanager_secret.documentdb.arn
}
