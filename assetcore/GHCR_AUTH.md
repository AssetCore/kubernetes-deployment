# Instructions for GHCR Authentication

## Option 1: Manual Secret Creation (Quick)

```bash
# Create GitHub Personal Access Token
# 1. Go to https://github.com/settings/tokens
# 2. Click "Generate new token (classic)"
# 3. Select scope: read:packages
# 4. Copy the token

# Create Docker registry secret
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=<YOUR_GITHUB_USERNAME> \
  --docker-password=<YOUR_GITHUB_TOKEN> \
  --docker-email=<YOUR_EMAIL> \
  -n assetcore-dev

# Verify
kubectl get secret ghcr-secret -n assetcore-dev
```

## Option 2: Add Secret to Helm Chart (Recommended)

Create base64 encoded .dockerconfigjson:

```bash
# Generate the docker config
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=<USERNAME> \
  --docker-password=<TOKEN> \
  --docker-email=<EMAIL> \
  --dry-run=client -o jsonpath='{.data.\.dockerconfigjson}'
```

Then add to your Helm chart templates or use Sealed Secrets / External Secrets Operator.

## Option 3: Make Images Public

If these are public projects:
1. Go to package settings in GitHub
2. Change visibility to Public
3. Remove imagePullSecrets from values.yaml

## After Creating Secret

Restart deployments:
```bash
kubectl rollout restart deployment -n assetcore-dev
```

Pods should now pull images successfully and show 2/2 READY (app + istio-proxy).
