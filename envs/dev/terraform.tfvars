#EKS
env          = "dev"
cluster_name = "dev-eks-cluster"
vpc_cidr     = "10.10.0.0/16"

kubernetes_version = "1.33"
instance_types = ["t3a.medium"]
desired_size = 1
min_size = 1
max_size = 4

#EC2
ami               = "ami-02b8269d5e85954ef"
key_pair          = "heliosolutions"
instance_type     = "t3.micro"   ##bastionhost


# MySQL
mysql_db_name             = "ecommerce"
mysql_instance_class      = "db.t3.micro"
mysql_skip_final_snapshot = true
mysql_deletion_protection = false
db_username               = "devuser"
db_password               = "devpassword"

# DocumentDB
documentdb_name           = "dev-documentdb"
docdb_username            = "docdbadmin"
docdb_password            = "docdbpassword"
docdb_skip_final_snapshot = true

