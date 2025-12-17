# Platform Components

This directory contains cluster-level platform components managed via GitOps with Argo CD.

## Directory Structure

```
platform/
└── istio/              # Service mesh (Istio 1.22.x)
    ├── app-of-apps.yaml
    ├── applications/
    ├── base/
    ├── istiod/
    ├── gateway/
    └── README.md
```

## Components

### Istio Service Mesh

- **Version**: 1.22.0
- **Namespace**: istio-system
- **Pattern**: App-of-Apps with 3 child applications
- **Documentation**: [istio/README.md](istio/README.md)

Components:
- istio-base (CRDs)
- istiod (control plane)
- istio-ingressgateway (ingress)

### Future Platform Components

Additional platform components can be added here:
- Monitoring (Prometheus, Grafana)
- Logging (Loki, Fluentd)
- Security (cert-manager, external-secrets)
- Networking (ingress-nginx, external-dns)

## Design Principles

1. **Separation of Concerns**: Platform components separated from application workloads
2. **GitOps First**: All changes tracked in Git
3. **App-of-Apps**: Each platform component uses the App-of-Apps pattern
4. **Automated Sync**: Auto-sync enabled with prune and self-heal
5. **Sync Waves**: Dependencies managed via sync wave annotations
6. **Production Ready**: High availability and security by default

## Getting Started

Each platform component has its own README with:
- Bootstrap commands
- Configuration options
- Troubleshooting guides
- Upgrade procedures

Start with the Istio README: [istio/README.md](istio/README.md)

## Prerequisites

- Kubernetes cluster (v1.26+)
- Argo CD installed in `argocd` namespace
- kubectl and argocd CLI tools
- Git repository access

## Management

### Deploy a Platform Component

```bash
# Apply the app-of-apps manifest
kubectl apply -f platform/<component>/app-of-apps.yaml

# Monitor deployment
kubectl get applications -n argocd -w
```

### Update a Component

```bash
# Make changes to manifests or values files
git add platform/<component>/
git commit -m "Update <component> configuration"
git push

# Argo CD will automatically sync
```

### Remove a Component

```bash
# Delete the app-of-apps (will cascade to children)
kubectl delete -f platform/<component>/app-of-apps.yaml

# Or use argocd CLI
argocd app delete <component-name> --cascade
```

## Best Practices

1. **Version Control**: Pin specific versions, never use `latest`
2. **Testing**: Test changes in non-production first
3. **Documentation**: Keep READMEs updated with changes
4. **Monitoring**: Monitor application health in Argo CD UI
5. **Backup**: Backup critical configurations before upgrades
6. **Review**: Peer review all platform changes
7. **Gradual Rollout**: Use canary upgrades for major changes

## Support

For component-specific issues, refer to the component's README.

For general GitOps or Argo CD questions, refer to:
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [GitOps Principles](https://opengitops.dev/)
