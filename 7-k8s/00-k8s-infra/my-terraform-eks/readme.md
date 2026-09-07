                         Terraform
                            │
             ┌──────────────┴──────────────┐
             │                             │
             ▼                             ▼
       Workstation EC2                  IAM Role
          t3.micro                         │
             │                             │
             │                             │
             └─────────────┬───────────────┘
                           │
                     Temporary AWS
                     credentials
                           │
                           ▼
                        eksctl
                           │
                           ▼
                    EKS roboshop
                           │
                 ┌─────────┴─────────┐
                 │                   │
                 ▼                   ▼
          Control Plane         Node Group
             ACTIVE               managed
                                   │
                              ┌────┴────┐
                              ▼         ▼
                          t3.small   t3.small
                              │         │
                              └────┬────┘
                                   │
                              Kubernetes
                                Ready

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