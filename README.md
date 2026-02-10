![Image](https://github.com/user-attachments/assets/adb915d3-3f1d-4ea9-ad19-e465bfc3a0c7)

# EKS Platform using Terraform

This repository provisions a **production-ready AWS EKS platform** using **Terraform**, following best practices for modularity, environment separation, and GitOps.

It is suitable for **small to medium production workloads**, internal platforms, and startup-scale infrastructure.

---

## 📌 Features

- Fully managed **EKS cluster**
- Environment separation: **dev / stage / prod**
- Modular Terraform design
- VPC with public & private subnets across AZs
- NAT Gateway, Internet Gateway, route tables
- EKS Add-ons:
  - AWS Load Balancer Controller (IRSA)
  - Cluster Autoscaler (IRSA)
  - Metrics Server
  - EBS CSI Driver (IRSA)
- GitOps-ready with **ArgoCD**
- Bastion host for cluster access
- RDS MySQL (private, non-public)
- MongoDB module (optional)
- IAM roles with least-privilege intent

---

## 🗂 Repository Structure

```text
.
├── envs/
│   ├── dev/
│   ├── stage/
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       ├── provider.tf
│       └── provider-k8s.tf
│
├── modules/
│   ├── vpc/
│   ├── iam/
│   ├── eks/
│   ├── addons/
│   ├── argocd/
│   ├── ec2/
│   ├── rds-mysql/
│   └── mongodb/
│
└── README.md
```

---

## 🌍 Environments

Each environment (`dev`, `stage`, `prod`) has:

- Its **own Terraform state**
- Separate variables
- Identical module usage

This enables safe promotion of infrastructure changes across environments.

---

## ⚙️ Prerequisites

- Terraform **~> 1.5**
- AWS CLI v2
- AWS credentials configured (`~/.aws/credentials`)
- kubectl (compatible with EKS version)
- Helm

---

## 🔐 Terraform Version Locking

```hcl
terraform {
  required_version = "~> 1.5"
}
```

---

## 🚀 Deployment Order

1. VPC & networking  
2. IAM roles  
3. EKS cluster & managed node groups  
4. EKS add-ons (ALB Controller, Autoscaler, Metrics Server)  
5. ArgoCD  
6. Databases (RDS / MongoDB)  
7. Bastion host  

---

## 🏗 How to Deploy

```bash
cd envs/prod
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

---

## ☸️ EKS Access

```bash
aws eks update-kubeconfig   --region ap-south-1   --name prod-eks-cluster

kubectl get nodes
kubectl get pods -A
```

---

## 📦 Installed EKS Add-ons

| Add-on | Installed | Notes |
|------|---------|------|
| AWS Load Balancer Controller | ✅ | Uses IRSA |
| Cluster Autoscaler | ✅ | Uses IRSA + node tags |
| Metrics Server | ✅ | Required for HPA |
| EBS CSI Driver | ✅ | Managed EKS add-on |
| ArgoCD | ✅ | GitOps-ready |

---

## 🧹 Destroying Infrastructure

```bash
terraform destroy
```

---

## 📝 Notes

- All Helm charts are version-pinned
- Remote Terraform backend (S3 + DynamoDB) is recommended
- This repository follows Infrastructure as Code and GitOps principles