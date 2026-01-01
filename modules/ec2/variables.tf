variable "ami" {
  type = string
}

variable "key_pair" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "env" {
  type = string
}

variable "instance_type" {
  type=string
  
}