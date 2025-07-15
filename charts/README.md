# Sroodle Helm Chart

This Helm chart deploys the Sroodle Rails application to a Kubernetes cluster.

## Prerequisites

- Kubernetes cluster with kubectl configured
- Helm 3.x
- Container image built and pushed to a registry

## Installation

1. **Build and push the container image:**
   ```bash
   # Build the image (from sroodle directory)
   docker build -t $APP_REGISTRY/sroodle:latest .
   
   # Push to your registry
   docker push $APP_REGISTRY/sroodle:latest
   ```

2. **Create the Rails master key secret:**
   ```bash
   # Get the master key from config/master.key
   kubectl create secret generic sroodle-secrets \
     --from-literal=rails-master-key="$(cat config/master.key)"
   ```

3. **Install the Helm chart:**
   ```bash
   # Install with default values
   helm install sroodle ./charts
   
   # Or install with custom values
   helm install sroodle ./charts \
     --set image.repository=$APP_REGISTRY/sroodle \
     --set image.tag=latest \
     --set ingress.enabled=true \
     --set ingress.hosts[0].host=sroodle.yourdomain.com
   ```

## Configuration

### Key Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Container image repository | `sroodle` |
| `image.tag` | Container image tag | `latest` |
| `replicaCount` | Number of replicas | `1` |
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `ingress.enabled` | Enable ingress | `false` |
| `persistence.enabled` | Enable persistent storage | `true` |
| `persistence.size` | Storage size | `10Gi` |

### Environment Variables

The chart sets the following environment variables by default:
- `RAILS_ENV=production`
- `RAILS_LOG_TO_STDOUT=true`
- `SOLID_QUEUE_IN_PUMA=true`

The `RAILS_MASTER_KEY` is provided via Kubernetes secret.

### Persistent Storage

The chart creates a PersistentVolumeClaim for SQLite databases and uploaded files. The storage is mounted at `/rails/storage` in the container.

## Database Management

Since this Rails app uses SQLite, the databases are stored in the persistent volume. To run database migrations:

```bash
# Get pod name
kubectl get pods -l app.kubernetes.io/name=sroodle

# Run migrations
kubectl exec -it <pod-name> -- bin/rails db:migrate
```

## Scaling Considerations

SQLite doesn't support multiple concurrent writers, so:
- Keep `replicaCount: 1` for production
- Use `ReadWriteOnce` access mode for storage
- Consider migrating to PostgreSQL for multi-replica deployments

## Ingress Configuration

To enable external access:

```yaml
ingress:
  enabled: true
  className: "nginx"  # or your ingress class
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: sroodle.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: sroodle-tls
      hosts:
        - sroodle.yourdomain.com
```

## Monitoring

The deployment includes liveness and readiness probes that check the root path (`/`) of the application.

## Troubleshooting

1. **Check pod logs:**
   ```bash
   kubectl logs -l app.kubernetes.io/name=sroodle
   ```

2. **Check pod status:**
   ```bash
   kubectl describe pod -l app.kubernetes.io/name=sroodle
   ```

3. **Access the application shell:**
   ```bash
   kubectl exec -it <pod-name> -- bash
   ```

4. **Check Rails console:**
   ```bash
   kubectl exec -it <pod-name> -- bin/rails console
   ```