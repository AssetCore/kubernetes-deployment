# GitHub Container Registry (GHCR) Setup

This guide explains how to deploy the AssetCore Helm chart using images from GitHub Container Registry.

## Prerequisites

1. Access to the AssetCore organization packages: https://github.com/orgs/AssetCore/packages
2. A GitHub Personal Access Token (PAT) with `read:packages` permission
3. Kubernetes cluster with Helm 3 installed

## Create GHCR Pull Secret

Before deploying the Helm chart, create a Kubernetes secret to authenticate with GHCR:

```bash
# Replace with your GitHub username and token
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=YOUR_GITHUB_USERNAME \
  --docker-password=YOUR_GITHUB_TOKEN \
  --docker-email=YOUR_EMAIL \
  -n default
```

Or create the secret in a specific namespace:

```bash
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=YOUR_GITHUB_USERNAME \
  --docker-password=YOUR_GITHUB_TOKEN \
  --docker-email=YOUR_EMAIL \
  -n assetcore
```

## Image Configuration

The Helm chart is configured to pull images from:
- `ghcr.io/assetcore/apigateway:latest`
- `ghcr.io/assetcore/assetregistry:latest`
- `ghcr.io/assetcore/auditcompliance:latest`
- `ghcr.io/assetcore/identityaccess:latest`
- `ghcr.io/assetcore/maintenancescheduler:latest`
- `ghcr.io/assetcore/notification:latest`

Images are pulled with `Always` policy to ensure the latest version is used.

## Deploy the Helm Chart

### Development Environment

```bash
helm install assetcore ./assetcore \
  -f assetcore/values.yaml \
  -f assetcore/values-dev.yaml \
  -n assetcore \
  --create-namespace
```

### Staging Environment

```bash
helm install assetcore ./assetcore \
  -f assetcore/values.yaml \
  -f assetcore/values-staging.yaml \
  -n assetcore-staging \
  --create-namespace
```

### Production Environment

```bash
helm install assetcore ./assetcore \
  -f assetcore/values.yaml \
  -f assetcore/values-prod.yaml \
  -n assetcore-prod \
  --create-namespace
```

## Upgrade Existing Deployment

```bash
helm upgrade assetcore ./assetcore \
  -f assetcore/values.yaml \
  -f assetcore/values-dev.yaml \
  -n assetcore
```

## Verify Deployment

Check if pods are running:

```bash
kubectl get pods -n assetcore
```

Check if images are being pulled correctly:

```bash
kubectl describe pod <pod-name> -n assetcore | grep -A 5 "Image:"
```

View logs:

```bash
kubectl logs -f deployment/assetregistry -n assetcore
```

## Troubleshooting

### ImagePullBackOff Error

If you see `ImagePullBackOff` errors:

1. Verify the secret exists:
   ```bash
   kubectl get secret ghcr-secret -n assetcore
   ```

2. Check if the secret is correctly configured:
   ```bash
   kubectl get secret ghcr-secret -n assetcore -o yaml
   ```

3. Verify GitHub token has correct permissions

4. Check if images exist in GHCR:
   - Visit: https://github.com/orgs/AssetCore/packages

### Update Pull Secret

If you need to update the credentials:

```bash
kubectl delete secret ghcr-secret -n assetcore

kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=NEW_USERNAME \
  --docker-password=NEW_TOKEN \
  --docker-email=NEW_EMAIL \
  -n assetcore
```

Then restart the deployments:

```bash
kubectl rollout restart deployment -n assetcore
```

## Using Specific Image Tags

To use a specific version instead of `latest`, override in your values file or via command line:

```bash
helm install assetcore ./assetcore \
  --set services.assetregistry.image.tag=v1.0.0 \
  --set services.auditcompliance.image.tag=v1.0.0 \
  -n assetcore
```

Or update `values.yaml`:

```yaml
services:
  assetregistry:
    image:
      repository: ghcr.io/assetcore/assetregistry
      tag: v1.0.0  # Specific version
```

## Public vs Private Images

If your GHCR images are **public**, you can skip creating the `ghcr-secret` and remove the `imagePullSecrets` from `values.yaml`:

```yaml
# Comment out or remove this line
# imagePullSecrets:
#   - name: ghcr-secret
```

If images are **private** (default), keep the secret configuration as described above.
