#EKS
env          = "stage"
cluster_name = "stage-eks-cluster"
vpc_cidr     = "10.10.0.0/16"

kubernetes_version = "1.33"
instance_types = ["t3.medium"]
desired_size = 2
min_size = 1
max_size = 4

#EC2
ami               = "ami-02b8269d5e85954ef"
key_pair          = "heliosolutions"
instance_type     = "t3.micro"


# MySQL
mysql_db_name             = "ecommerce"
mysql_instance_class      = "db.t3.micro"
mysql_skip_final_snapshot = true
mysql_deletion_protection = false
db_username               = "stageuser"
db_password               = "stagepassword"

# DocumentDB
documentdb_name           = "stage-documentdb"
docdb_username            = "docdbadmin"
docdb_password            = "docdbpassword"
docdb_skip_final_snapshot = true

