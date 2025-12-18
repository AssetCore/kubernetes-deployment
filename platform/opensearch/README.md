# OpenSearch Configuration

This directory contains the OpenSearch configuration for application monitoring.

## Resources

- **opensearch-config.yaml**: Contains ConfigMap and Secret for OpenSearch connection

## Configuration

- **OpenSearch URI**: https://3.150.64.215:9200
- **Namespace**: default

## Deployment

Deploy using ArgoCD:

```bash
kubectl apply -f argocd-application.yaml
```

Or manually apply:

```bash
kubectl apply -f opensearch-config.yaml
```

## Security Note

⚠️ The credentials in `opensearch-config.yaml` use `stringData` for readability. In production, consider:
- Using external secret management (e.g., Sealed Secrets, External Secrets Operator)
- Base64 encoding sensitive data
- Restricting namespace access with RBAC
