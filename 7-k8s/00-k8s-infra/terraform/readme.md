


################### Desired Archecture ###########
Terraform
   │
   ├── IAM Role
   │      └── Instance Profile
   │
   ├── Security Group
   │
   └── EC2 Workstation (t3.micro)
           │
           ├── AWS CLI
           ├── kubectl
           ├── eksctl
           ├── Docker
           ├── k9s
           └── kubectx/kubens
                    │
                    └── eksctl
                          │
                          └── EKS Cluster
                               └── 2 × t3.small Spot
###########################################################
                     AWS
                      │
          ┌───────────┴───────────┐
          │                       │
      IAM Role              Security Group
          │                       │
          │                       │
          └───────────┬───────────┘
                      │
                EC2 Workstation
                   t3.micro
                      │
          ┌───────────┼────────────┐
          │           │            │
       AWS CLI     kubectl       Docker
          │
       eksctl
          │
          ▼
    ┌─────────────────┐
    │ EKS roboshop    │
    │ us-east-1       │
    └────────┬────────┘
             │
       managed nodegroup
             │
       ┌─────┴─────┐
       │           │
   t3.small     t3.small
     Spot         Spot
#####################################Terraform Flow ###########
terraform apply
       ↓
Workstation created
       ↓
IAM role attached
       ↓
Tools installed
       ↓
SSH into workstation
       ↓
aws sts get-caller-identity
       ↓
eksctl create cluster -f eksctl.yaml
       ↓
aws eks update-kubeconfig
       ↓
kubectl get nodes
       ↓
2 × t3.small → Ready