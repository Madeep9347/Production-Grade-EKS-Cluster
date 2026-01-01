terraform {
    backend "s3" {
        bucket = "terraform-eks-clusterstatefile"
        region = "ap-south-1"
        key = "eks/terraform.tfstate"
        use_lockfile = true
      
    }
}