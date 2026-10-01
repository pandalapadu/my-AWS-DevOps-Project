# Argo CD -- Complete EKS GitOps Reference

## 1. Environment

  ------------------------------------------------------------------------------------------------
  Item                                Value
  ----------------------------------- ------------------------------------------------------------
  AWS Region                          `us-east-1`

  EKS Cluster                         `roboshop-dev`

  Argo CD Namespace                   `argocd`

  Git Repository                      `https://github.com/pandalapadu/argocd.git`
  ------------------------------------------------------------------------------------------------

## 2. Configure kubectl

``` bash
aws eks update-kubeconfig --region us-east-1 --name roboshop-dev
kubectl get nodes
kubectl config current-context
```

## 3. Install Argo CD

Create the namespace:

``` bash
kubectl create namespace argocd
```

Install Argo CD:

``` bash
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Verify:

``` bash
kubectl get pods -n argocd
kubectl get all -n argocd
kubectl get svc -n argocd
```

## 4. Access Argo CD UI
For initial testing:
``` bash
Install Argo CD to Clasic LoadBalancer for accessing : 
kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"LoadBalancer"}}'
```
get the Loadbalancer and access by browser : https: <Loadbalancer URL>
Open:
``` text
https://<Loadbalancer URL>
```
Login with `admin` and the initial password.

## 5. Initial Admin Password

``` bash
kubectl -n argocd get secret argocd-initial-admin-secret   -o jsonpath="{.data.password}" | base64 -d

```
Username:

``` text
admin
```



## 6. Argo CD CLI
installation of CLI:
``` bash 
curl -sSL -o /tmp/argocd-linux-amd64 \
  https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 /tmp/argocd-linux-amd64 /usr/local/bin/argocd
rm -f /tmp/argocd-linux-amd64
```
Check the client:

``` bash
argocd version --client
```

Login:

``` bash
argocd login localhost:8080   --username admin   --password '<PASSWORD>'   --insecure
```

Useful commands:

``` bash
argocd account get-user-info
argocd app list
argocd app get <APP_NAME>
argocd app sync <APP_NAME>
argocd app get <APP_NAME> --refresh
argocd app history <APP_NAME>
argocd app rollback <APP_NAME> <ID>
argocd app delete <APP_NAME>
argocd version
```

## 7. Argo CD Architecture

  ------------------------------------------------------------------------
  Component                            Purpose
  ------------------------------------ -----------------------------------
  `argocd-server`                      API server and Web UI

  `argocd-application-controller`      Reconciles desired and actual state

  `argocd-repo-server`                 Connects to Git and generates
                                       manifests

  `argocd-applicationset-controller`   Generates Applications from
                                       ApplicationSets

  `argocd-dex-server`                  Authentication/identity integration

  `argocd-redis`                       Internal caching

  `argocd-notifications-controller`    Notifications
  ------------------------------------------------------------------------

## 8. GitOps Model

``` text
Git Repository = Desired State
        |
        v
     Argo CD
        |
        | Reconciliation / Sync
        v
    Kubernetes / EKS
        |
        v
   Actual State
```

Argo CD continuously compares the desired state stored in Git with the
actual Kubernetes state.

## 9. Roboshop CI/CD + GitOps Flow

``` text
Developer
    |
    v
GitHub
    |
    v
Jenkins
    |
    +-- Build
    +-- Test
    +-- SonarQube
    +-- Security Scan
    +-- Docker Build
    |
    v
Amazon ECR
    |
    v
Git deployment configuration
    |
    v
Argo CD
    |
    v
EKS
    |
    +-- catalogue
    +-- user
    +-- cart
    +-- shipping
    +-- payment
    +-- frontend
```

Jenkins performs CI/build activities. Argo CD performs GitOps-based
Kubernetes deployment and reconciliation.

## 10. Suggested Repository Structure

``` text
my-AWS-DevOps-Project/
|
+-- 9-ArgocD/
|   |
|   +-- 9-01-argocd-install/
|   |
|   +-- 9-02-argocd-applications/
|   |   +-- catalogue.yaml
|   |   +-- user.yaml
|   |   +-- cart.yaml
|   |   +-- shipping.yaml
|   |   +-- payment.yaml
|   |   +-- frontend.yaml
|   |
|   +-- 9-03-argocd-project/
|       +-- roboshop-project.yaml
```

## 11. Argo CD Application

An Application defines the Git source, revision, path, destination
cluster/namespace, and synchronization behavior.

Example:

``` yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: catalogue
  namespace: argocd
spec:
  project: default

  source:
    repoURL: https://github.com/pandalapadu/my-AWS-DevOps-Project.git
    targetRevision: main
    path: <KUBERNETES_MANIFEST_PATH>

  destination:
    server: https://kubernetes.default.svc
    namespace: catalogue

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Replace `<KUBERNETES_MANIFEST_PATH>` with the actual manifest or Helm
path.

Apply it:

``` bash
kubectl apply -f catalogue.yaml
```

Verify:

``` bash
kubectl get applications -n argocd
argocd app list
argocd app get catalogue
```

## 12. Sync, Prune and Self-Heal

Manual sync:

``` bash
argocd app sync catalogue
```

Automated sync:

``` yaml
syncPolicy:
  automated:
    prune: true
    selfHeal: true
```

`prune: true` allows Argo CD to remove resources no longer defined in
Git.

`selfHeal: true` allows Argo CD to reconcile managed resources after
manual drift.

## 13. Application Status

Important sync states:

``` text
Synced
OutOfSync
Unknown
```

Important health states:

``` text
Healthy
Progressing
Degraded
Suspended
Missing
Unknown
```

## 14. ApplicationSet

ApplicationSet can generate multiple Applications from a common
definition.

``` text
ApplicationSet
      |
      +-- catalogue
      +-- user
      +-- cart
      +-- shipping
      +-- payment
      +-- frontend
```

This is useful when managing multiple services or environments.

## 15. Argo CD Project

An `AppProject` provides boundaries for:

-   Allowed Git repositories
-   Allowed destination clusters
-   Allowed namespaces
-   Allowed Kubernetes resource types

For Roboshop, a dedicated project can group the application resources.

``` text
Argo CD
   |
   +-- Roboshop Project
         |
         +-- catalogue
         +-- user
         +-- cart
         +-- shipping
         +-- payment
         +-- frontend
```

## 16. Image Tagging

Prefer traceable image tags instead of relying only on `latest`.

Examples:

``` text
catalogue:1.0.0
catalogue:1.0.1
catalogue:<GIT_COMMIT_SHA>
```

A GitOps deployment can update the desired image tag in Git and Argo CD
can synchronize it to EKS.

## 17. Rollback

Git-based rollback:

``` text
Current:
catalogue:1.0.2

Previous:
catalogue:1.0.1
```

Revert the deployment configuration in Git:

``` text
catalogue:1.0.2
       |
       | Git revert
       v
catalogue:1.0.1
       |
       v
Argo CD
       |
       v
EKS
```

Argo CD also maintains application history for rollback operations.

## 18. Terraform + Argo CD Separation

Recommended responsibility split:

``` text
Terraform
   |
   +-- VPC
   +-- Subnets
   +-- Security Groups
   +-- IAM
   +-- EKS
   +-- Node Groups
   +-- ECR
   |
   v
EKS
   |
   v
Argo CD
   |
   +-- Kubernetes Applications
```

Terraform manages infrastructure. Argo CD manages Kubernetes application
delivery.

## 19. Troubleshooting

### Argo CD pods are not Running

``` bash
kubectl get pods -n argocd
kubectl describe pod <POD_NAME> -n argocd
kubectl logs <POD_NAME> -n argocd
```

### UI is not accessible

``` bash
kubectl get svc -n argocd
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open:

``` text
https://localhost:8080
```

### Application is OutOfSync

``` bash
argocd app get <APP_NAME>
argocd app get <APP_NAME> --refresh
argocd app sync <APP_NAME>
kubectl get all -n <NAMESPACE>
```

### Application is Degraded

``` bash
argocd app get <APP_NAME>
kubectl get all -n <NAMESPACE>
kubectl get pods -n <NAMESPACE>
kubectl describe pod <POD_NAME> -n <NAMESPACE>
kubectl logs <POD_NAME> -n <NAMESPACE>
```

## 20. Complete Command Cheat Sheet

``` bash
# EKS
aws eks update-kubeconfig --region us-east-1 --name roboshop-dev
kubectl get nodes

# Namespace
kubectl create namespace argocd

# Install
kubectl apply -n argocd   -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Verify
kubectl get pods -n argocd
kubectl get all -n argocd
kubectl get svc -n argocd

# Password
kubectl -n argocd get secret argocd-initial-admin-secret   -o jsonpath="{.data.password}" | base64 -d

# UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# CLI
argocd login localhost:8080   --username admin   --password '<PASSWORD>'   --insecure

# Applications
argocd app list
argocd app get <APP_NAME>
argocd app sync <APP_NAME>
argocd app history <APP_NAME>
argocd app rollback <APP_NAME> <ID>
```

## 21. Learning Checklist

-   [ ] Connect kubectl to EKS
-   [ ] Create `argocd` namespace
-   [ ] Install Argo CD
-   [ ] Verify Argo CD pods
-   [ ] Get initial admin password
-   [ ] Access Argo CD UI
-   [ ] Install/configure Argo CD CLI
-   [ ] Connect GitHub repository
-   [ ] Create Argo CD Project
-   [ ] Create first Argo CD Application
-   [ ] Deploy catalogue
-   [ ] Deploy user
-   [ ] Deploy cart
-   [ ] Deploy shipping
-   [ ] Deploy payment
-   [ ] Deploy frontend
-   [ ] Enable automated sync
-   [ ] Understand prune
-   [ ] Understand self-heal
-   [ ] Understand OutOfSync
-   [ ] Understand application health
-   [ ] Use ApplicationSet
-   [ ] Perform rollback
-   [ ] Troubleshoot failed synchronization
-   [ ] Integrate Jenkins + ECR + Argo CD
-   [ ] Move Argo CD installation to Terraform/Helm for reproducibility

## 22. Final Mental Model

``` text
Terraform
   =
Infrastructure

Jenkins
   =
CI / Build / Test / Scan / Image

SonarQube
   =
Code Quality

ECR
   =
Container Image Registry

Git
   =
Desired Kubernetes State

Argo CD
   =
GitOps Deployment / Reconciliation

EKS
   =
Kubernetes Runtime
```

Overall:

``` text
                 TERRAFORM
                     |
                     v
              AWS / EKS INFRA
                     |
                     v
                  JENKINS
                     |
          +----------+----------+
          |                     |
          v                     v
      SonarQube                ECR
          |                     |
          +----------+----------+
                     |
                     v
                   GIT
                     |
                     v
                 ARGO CD
                     |
                     v
                   EKS
                     |
       +-------------+-------------+
       |             |             |
   catalogue        user          cart
       |             |             |
   shipping        payment      frontend
```
