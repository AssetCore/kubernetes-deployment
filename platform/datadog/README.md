# Datadog Agent Setup

This directory contains the configuration for deploying the Datadog Agent to the cluster using the Datadog Operator.

## Prerequisites

1. **Datadog API Key**: You need a valid Datadog API key
2. **Datadog Operator**: The operator will be installed via the ArgoCD application

## Setup Steps

### 1. Create the Datadog Secret

Update the secret with your actual Datadog API key:

```bash
# Edit the secret.yaml file with your API key
kubectl apply -f secret.yaml
```

Or create it directly:

```bash
kubectl create namespace datadog
kubectl create secret generic datadog-secret \
  --from-literal=api-key=<YOUR_API_KEY> \
  -n datadog
```

### 2. Deploy via ArgoCD

Apply the ArgoCD application:

```bash
kubectl apply -f argocd-application.yaml
```

### 3. Deploy the DatadogAgent Resource

Once the operator is running, apply the DatadogAgent resource:

```bash
kubectl apply -f datadog-agent.yaml
```

## Configuration

### Cluster Name
Update the `clusterName` in `datadog-agent.yaml` to match your cluster:
- `asset-registry-cluster` (default)
- Update to `asset-registry-dev`, `asset-registry-staging`, or `asset-registry-prod` as needed

### Datadog Site
Update the `site` field based on your Datadog region:
- `datadoghq.com` (US1)
- `datadoghq.eu` (EU)
- `us3.datadoghq.com` (US3)
- `us5.datadoghq.com` (US5)
- `ap1.datadoghq.com` (AP1)
- `ddog-gov.com` (US1-FED)

## Features Enabled

- **APM (Application Performance Monitoring)**: Trace collection enabled
- **Log Collection**: Container log collection enabled
- **NPM (Network Performance Monitoring)**: Network monitoring enabled
- **Kube State Metrics**: Kubernetes state metrics collection

## Verification

Check the Datadog agent status:

```bash
# Check operator deployment
kubectl get deployment -n datadog datadog-operator

# Check DatadogAgent resource
kubectl get datadogagent -n datadog

# Check agent pods
kubectl get pods -n datadog

# View agent logs
kubectl logs -n datadog -l app.kubernetes.io/name=datadog-agent-node
```

## Integration with Istio

The Datadog agent will automatically discover and monitor services running in the Istio service mesh. Ensure the Istio pods have the necessary annotations for metrics scraping.

## Troubleshooting

### Agent Not Starting
```bash
kubectl describe datadogagent datadog -n datadog
```

### Check Operator Logs
```bash
kubectl logs -n datadog deployment/datadog-operator
```

### Verify Secret
```bash
kubectl get secret datadog-secret -n datadog
```
