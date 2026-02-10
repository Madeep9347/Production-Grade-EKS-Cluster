output "endpoint" {
  value = aws_docdb_cluster.this.endpoint
}

output "port" {
  value = 27017
}
