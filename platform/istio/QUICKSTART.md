# Quick Reference: Istio GitOps Bootstrap

## One-Time Setup

```bash
# 1. Update repository URL
export GIT_REPO="https://github.com/YOUR-ORG/kubernetes-deployment.git"
sed -i "s|https://github.com/YOUR-ORG/kubernetes-deployment.git|${GIT_REPO}|g" platform/istio/app-of-apps.yaml

# 2. Review cloud provider annotations (AWS/Azure/GCP)
vim platform/istio/applications/istio-ingressgateway.yaml

# 3. Commit to Git
git add platform/
git commit -m "Add Istio platform with GitOps"
git push origin main

# 4. Deploy to Argo CD
kubectl apply -f platform/istio/app-of-apps.yaml

# 5. Monitor deployment
kubectl get applications -n argocd -l app.kubernetes.io/part-of=istio-platform -w
```

## Verify Installation

```bash
# Check all pods are running
kubectl get pods -n istio-system

# Verify versions
kubectl get deployment -n istio-system -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.template.spec.containers[0].image}{"\n"}{end}'

# Check ingress gateway service
kubectl get svc istio-ingressgateway -n istio-system

# Test istiod readiness
kubectl exec -n istio-system deploy/istiod -- curl -s http://localhost:15014/ready
```

## Common Operations

```bash
# View Argo CD app status
argocd app list | grep istio

# Manual sync (if needed)
argocd app sync istio-platform

# Refresh and hard refresh
argocd app get istio-platform --refresh
argocd app get istio-platform --hard-refresh

# View application details
argocd app get istiod

# Check sync history
argocd app history istio-platform
```

## Upgrade Istio

```bash
# Update version in all applications
find platform/istio/applications -name "*.yaml" -exec sed -i 's/targetRevision: 1.22.0/targetRevision: 1.22.1/g' {} \;

# Commit and push
git add platform/istio/applications/
git commit -m "Upgrade Istio to 1.22.1"
git push

# Argo CD auto-syncs in wave order
```

## Troubleshooting

```bash
# Application won't sync
argocd app get <app-name> --show-operation
kubectl get events -n istio-system --sort-by='.lastTimestamp'

# Check logs
kubectl logs -n istio-system -l app=istiod --tail=100
kubectl logs -n istio-system -l app=istio-ingressgateway --tail=100

# Verify CRDs
kubectl get crds | grep istio.io

# Check webhooks
kubectl get validatingwebhookconfigurations | grep istio
kubectl get mutatingwebhookconfigurations | grep istio
```

## Emergency Rollback

```bash
# Rollback via Argo CD
argocd app rollback istio-platform

# Or disable auto-sync and manual revert
argocd app set istio-platform --sync-policy none
git revert <commit-hash>
git push
argocd app sync istio-platform
```

## File Structure Quick Reference

```
platform/istio/
├── app-of-apps.yaml                    # kubectl apply -f this file
├── applications/
│   ├── istio-base.yaml                 # Wave 1 - CRDs
│   ├── istiod.yaml                     # Wave 2 - Control plane
│   └── istio-ingressgateway.yaml       # Wave 3 - Gateway
├── base/values.yaml                    # Helm values (optional)
├── istiod/values.yaml                  # Helm values (reference)
├── gateway/values.yaml                 # Helm values (reference)
└── README.md                           # Full documentation
```

## Important Notes

- **Sync Order**: base → istiod → gateway (via sync waves)
- **Auto-Sync**: Enabled with prune and self-heal
- **Namespace**: istio-system (auto-created)
- **Load Balancer**: Internal by default (private subnet)
- **High Availability**: 2 replicas minimum, 5 maximum
- **Version**: 1.22.0 (stable, production-ready)

For detailed documentation, see [README.md](README.md)
