                              🌍 INTERNET
                                  │
                                  │ HTTPS :443
                                  ▼
                         ┌───────────────────┐
                         │    Route 53 DNS   │
                         └─────────┬─────────┘
                                   │
                                   ▼
                         ┌───────────────────┐
                         │      AWS ALB      │
                         │  Internet-facing  │
                         │    HTTPS :443     │
                         │   ACM Certificate │
                         └─────────┬─────────┘
                                   │
                                   ▼
                    ┌────────────────────────────┐
                    │       Gateway API          │
                    │                            │
                    │ GatewayClass → AWS LBC     │
                    │ Gateway → roboshop         │
                    └────────────┬───────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
                    ▼                         ▼
              HTTPRoute APP1            HTTPRoute APP2
                    │                         │
                    ▼                         ▼
               Service app1              Service app2
                    │                         │
                    ▼                         ▼
             Target Group               Target Group
             targetType=IP              targetType=IP
                    │                         │
                    ▼                         ▼
              ┌───────────┐             ┌───────────┐
              │ APP1 PODS │             │ APP2 PODS │
              │           │             │           │
              │ Pod 1     │             │ Pod 1     │
              │ Pod 2     │             │ Pod 2     │
              └───────────┘             └───────────┘
# Gateway
```bash
# Standard Gateway API CRDs (REQUIRED), built against v1.5.0
kubectl apply --server-side=true -f \
  https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.0/standard-install.yaml

# LBC AWS-specific CRDs (LoadBalancerConfiguration, TargetGroupConfiguration, ListenerRuleConfiguration)
kubectl apply -f \
  https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/refs/heads/main/config/crd/gateway/gateway-crds.yaml
```

The controller enables its Gateway reconcilers only at startup, based on whether the Gateway CRDs exist. If the controller was installed before these CRDs (which is the normal order — controller in the Ingress session, CRDs now), it isn't watching Gateways yet. Restart it once so it re-detects them:

```bash
kubectl -n kube-system rollout restart deploy aws-load-balancer-controller
kubectl -n kube-system rollout status  deploy aws-load-balancer-controller
```
######## Application YAML dependency file #########
Namespace: roboshop
        │
        ▼
┌─────────────────┐
│   Deployment    │
│      app1       │
└────────┬────────┘
         │
         │ creates Pods
         ▼
┌─────────────────┐
│    Service      │
│      app1       │
└────────┬────────┘
         │
         ├─────────────────────┐
         │                     │
         ▼                     ▼
┌───────────────────┐   ┌─────────────────┐
│ TargetGroupConfig │   │    HTTPRoute    │
│       app1        │   │      app1       │
└────────┬──────────┘   └────────┬────────┘
         │                       │
         │                       │ depends on
         │                       ▼
         │                 ┌─────────────┐
         │                 │   Gateway   │
         │                 │  roboshop   │
         │                 └─────────────┘
         │
         ▼
   AWS Target Group
         │
         ▼
       ALB
#################
Installation steps 
1. Deployment
       ↓
2. Service
       ↓
3. TargetGroupConfiguration
       ↓
4. HTTPRoute
##########
                         🌍 INTERNET
                              │
                              ▼
                         AWS ALB
                              │
                              ▼
                    ┌─────────────────┐
                    │ Gateway roboshop│
                    └────────┬────────┘
                             │
                   ┌─────────┴─────────┐
                   │                   │
                   ▼                   ▼
             HTTPRoute APP1      HTTPRoute APP2
                   │                   │
                   ▼                   ▼
              Service app1        Service app2
                   │                   │
                   ▼                   ▼
                Pods APP1            Pods APP2