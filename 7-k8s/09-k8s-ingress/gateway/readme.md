# Internet
   │
   │ HTTPS :443
   ▼
┌─────────────────────────────┐
│          AWS ALB            │
│                             │
│ *.azdevopsvenkat.site       │
└──────────────┬──────────────┘
               │
               │ Listener Rule
               │ app1.azdevopsvenkat.site
               ▼
┌─────────────────────────────┐
│       Target Group          │
│                             │
│ 10.0.11.230:80              │
│ 10.0.12.243:80              │
└──────────────┬──────────────┘
               │
               ▼
          app1 Service
               │
        ┌──────┴──────┐
        ▼             ▼
      Pod 1         Pod 2
=======================
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