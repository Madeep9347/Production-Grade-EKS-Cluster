variable "env" {
  type = string
}

variable "mysql_username" {
  type      = string
  sensitive = true
}

variable "mysql_password" {
  type      = string
  sensitive = true
}

variable "docdb_username" {
  type      = string
  sensitive = true
}

variable "docdb_password" {
  type      = string
  sensitive = true
}
