# AssetCore Kubernetes Deployment

This repository contains Kubernetes manifests and Helm charts for deploying the AssetCore microservices platform.

## Architecture

The AssetCore platform consists of the following microservices:

- **AssetRegistry** - Core asset management and CRUD operations
- **AuditCompliance** - Audit logging and compliance tracking
- **IdentityAccess** - Authentication and authorization (Asgardeo integration)
- **MaintenanceScheduler** - Scheduled maintenance operations
- **Notification** - Email and notification services

## Prerequisites

- Kubernetes cluster (v1.20+)
- Helm 3.0+
- kubectl configured to connect to your cluster
- Docker images for all services built and pushed to a registry

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd kubernetes-deployment
```

### 2. Build and Push Docker Images

Build Docker images for all services and push them to your container registry:

```bash
# Example for AssetRegistry service
cd ../Asset-Registry-and-Tracking-System-/src/Services/AssetRegistry
docker build -t your-registry/assetregistry:latest .
docker push your-registry/assetregistry:latest

# Repeat for other services...
```

### 3. Configure Values

Edit the appropriate values file for your environment:

- `assetcore/values-dev.yaml` - Development environment
- `assetcore/values-staging.yaml` - Staging environment  
- `assetcore/values-prod.yaml` - Production environment

Update the following sections:

```yaml
services:
  assetregistry:
    image:
      repository: "your-registry/assetregistry"
      tag: "latest"
    
    secrets:
      data:
        DB_USERNAME: "your-db-username"
        DB_PASSWORD: "your-db-password"

  identityaccess:
    secrets:
      data:
        AsgardeoSettings__ClientId: "your-asgardeo-client-id"
        AsgardeoSettings__ClientSecret: "your-asgardeo-secret"

  notification:
    secrets:
      data:
        EmailSettings__Username: "your-email@domain.com"
        EmailSettings__Password: "your-app-password"

ingress:
  hosts:
    - host: your-domain.com
```

### 4. Deploy to Development

```bash
chmod +x deploy.sh
./deploy.sh -e dev
```

### 5. Deploy to Other Environments

```bash
# Staging
./deploy.sh -e staging

# Production  
./deploy.sh -e prod
```

## Deployment Scripts

### deploy.sh

Main deployment script with the following options:

```bash
./deploy.sh -e <environment> [options]

Options:
  -e, --environment   Environment (dev/staging/prod)
  -n, --namespace     Custom namespace
  -r, --release       Helm release name
  -d, --dry-run       Perform dry run
  -u, --upgrade       Upgrade existing deployment
  -h, --help          Show help
```

Examples:
```bash
# Deploy to development
./deploy.sh -e dev

# Upgrade staging deployment
./deploy.sh -e staging -u

# Dry run for production
./deploy.sh -e prod -d

# Deploy to custom namespace
./deploy.sh -e dev -n custom-namespace
```

### manage.sh

Management script for ongoing operations:

```bash
./manage.sh -a <action> -e <environment> [options]

Actions:
  status      - Show deployment status
  logs        - Show application logs  
  restart     - Restart pods
  scale       - Scale deployments
  delete      - Delete deployment
  rollback    - Rollback deployment
  history     - Show deployment history
  test        - Run connectivity tests
```

Examples:
```bash
# Check status
./manage.sh -a status -e prod

# View logs for specific service
./manage.sh -a logs -e dev -s assetregistry

# Restart all pods
./manage.sh -a restart -e staging

# Scale to 5 replicas
./manage.sh -a scale -e prod --replicas 5

# Test connectivity
./manage.sh -a test -e dev
```

## Manual Deployment

If you prefer to use Helm directly:

### Development
```bash
helm install assetcore ./assetcore \
  --namespace assetcore-dev \
  --values ./assetcore/values-dev.yaml \
  --create-namespace
```

### Staging
```bash
helm install assetcore ./assetcore \
  --namespace assetcore-staging \
  --values ./assetcore/values-staging.yaml \
  --create-namespace
```

### Production
```bash
helm install assetcore ./assetcore \
  --namespace assetcore-prod \
  --values ./assetcore/values-prod.yaml \
  --create-namespace
```

## Environment-Specific Configurations

### Development
- Single replica for most services
- Resource limits reduced
- Debug logging enabled
- TLS disabled for local development
- No autoscaling or monitoring

### Staging
- 1-2 replicas per service
- Moderate resource allocation
- Autoscaling enabled
- Basic monitoring
- TLS enabled with staging certificates

### Production
- 2-3+ replicas per service
- Production-grade resources
- Full autoscaling configuration
- Comprehensive monitoring and alerting
- TLS with production certificates
- Pod disruption budgets
- Network policies

## Features

### Security
- Non-root containers with read-only filesystems
- Security contexts with dropped capabilities
- Network policies for traffic isolation
- RBAC with minimal permissions
- Secrets management for sensitive data

### High Availability
- Multiple replicas across availability zones
- Pod anti-affinity rules
- Pod disruption budgets
- Rolling updates with zero downtime
- Health checks and readiness probes

### Observability
- Prometheus metrics collection
- Service monitoring with alerts
- Structured logging
- Distributed tracing ready
- Health endpoints for all services

### Autoscaling
- Horizontal Pod Autoscaler (HPA)
- CPU and memory-based scaling
- Custom metrics support
- Configurable scaling policies

### Networking
- Ingress with TLS termination
- Service mesh ready
- Rate limiting and security headers
- Load balancing across pods

## Monitoring and Alerting

The deployment includes Prometheus ServiceMonitor and PrometheusRule resources for monitoring:

### Metrics Collected
- HTTP request rates and latencies
- Error rates and status codes
- Resource utilization (CPU, memory)
- Application-specific metrics

### Default Alerts
- High error rate (>5%)
- High latency (>500ms p95)
- Pod crash looping
- High resource utilization (>80%)

### Accessing Metrics
```bash
# Port-forward to access Prometheus
kubectl port-forward -n monitoring svc/prometheus 9090:9090

# View metrics at http://localhost:9090
```

## Troubleshooting

### Common Issues

1. **Image Pull Errors**
   ```bash
   # Check if images exist in registry
   kubectl describe pod <pod-name> -n <namespace>
   ```

2. **Service Not Ready**
   ```bash
   # Check pod logs
   kubectl logs <pod-name> -n <namespace>
   
   # Check events
   kubectl get events -n <namespace> --sort-by=.metadata.creationTimestamp
   ```

3. **Database Connection Issues**
   ```bash
   # Verify database connectivity
   kubectl exec -it <pod-name> -n <namespace> -- /bin/sh
   # Inside pod: test connection to database service
   ```

4. **Configuration Issues**
   ```bash
   # Check ConfigMap and Secret contents
   kubectl get configmap -n <namespace> -o yaml
   kubectl get secret -n <namespace> -o yaml
   ```

### Getting Support

1. Check deployment status: `./manage.sh -a status -e <env>`
2. Review pod logs: `./manage.sh -a logs -e <env> -s <service>`
3. Test connectivity: `./manage.sh -a test -e <env>`
4. Check Helm deployment: `helm status assetcore -n <namespace>`

## Updating the Deployment

### Rolling Updates
```bash
# Update image tag in values file, then upgrade
./deploy.sh -e <environment> -u
```

### Configuration Changes
```bash
# Edit values file, then upgrade
./deploy.sh -e <environment> -u
```

### Rollback
```bash
# Rollback to previous version
./manage.sh -a rollback -e <environment>

# View deployment history
./manage.sh -a history -e <environment>
```

## Best Practices

1. **Always test in development first**
2. **Use specific image tags, not 'latest'**
3. **Review changes with dry-run before deploying**
4. **Monitor deployments after updates**
5. **Keep secrets in external secret management systems**
6. **Regularly update and patch container images**
7. **Use resource requests and limits**
8. **Implement proper health checks**
9. **Plan for disaster recovery**
10. **Document custom configurations**

## Contributing

1. Make changes to Helm templates or values
2. Test changes in development environment
3. Validate with `helm lint ./assetcore`
4. Submit pull request with detailed description

## License

[License information here]