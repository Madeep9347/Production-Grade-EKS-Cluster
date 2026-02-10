terraform {
    backend "s3" {
        bucket = "terraform-eks-clusterstatefile"
        region = "ap-south-1"
        key = "stage-eks/terraform.tfstate"
        use_lockfile = true
      
    }
}
