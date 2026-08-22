# Kubernetes Deployment Patterns

## Overview

Common Kubernetes patterns for deployments, scaling, configuration, and operational best practices.

## Deployment Patterns

### Rolling Update (Default)
**Use**: Standard deployments
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
```

### Recreate
**Use**: Database migrations, incompatible versions
```yaml
strategy:
  type: Recreate
```

### Blue-Green
**Use**: Zero-downtime, easy rollback
```yaml
# Blue deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-blue
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: blue

---
# Green deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-green
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: green

---
# Service switches between blue/green
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    app: myapp
    version: blue  # Change to 'green' to switch
```

## Health Check Patterns

### Liveness Probe
**Purpose**: Restart unhealthy containers
```yaml
livenessProbe:
  httpGet:
    path: /health/live
    port: 8000
  initialDelaySeconds: 30
  periodSeconds: 10
  failureThreshold: 3
```

### Readiness Probe
**Purpose**: Remove from service if not ready
```yaml
readinessProbe:
  httpGet:
    path: /health/ready
    port: 8000
  initialDelaySeconds: 10
  periodSeconds: 5
```

### Startup Probe
**Purpose**: Handle slow-starting containers
```yaml
startupProbe:
  httpGet:
    path: /health/startup
    port: 8000
  periodSeconds: 10
  failureThreshold: 30  # 5 minutes total
```

## Resource Management

### Requests vs Limits
```yaml
resources:
  requests:     # Guaranteed resources
    cpu: 250m
    memory: 512Mi
  limits:       # Maximum allowed
    cpu: 1000m
    memory: 2Gi
```

### QoS Classes
- **Guaranteed**: requests = limits
- **Burstable**: requests < limits
- **BestEffort**: no requests/limits

## Configuration Patterns

### ConfigMap for Non-Sensitive Data
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DATABASE_HOST: postgres
  LOG_LEVEL: info
```

### Secret for Sensitive Data
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
stringData:
  DATABASE_PASSWORD: changeme
  API_KEY: secret-key
```

### Environment Variables
```yaml
env:
  # Direct value
  - name: LOG_LEVEL
    value: "info"

  # From ConfigMap
  - name: DATABASE_HOST
    valueFrom:
      configMapKeyRef:
        name: app-config
        key: DATABASE_HOST

  # From Secret
  - name: API_KEY
    valueFrom:
      secretKeyRef:
        name: app-secret
        key: API_KEY
```

## Scaling Patterns

### Horizontal Pod Autoscaler
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 3
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

### Pod Disruption Budget
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: myapp-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: myapp
```

## Storage Patterns

### StatefulSet
**Use**: Databases, ordered deployments
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 3
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 10Gi
```

### PersistentVolumeClaim
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-storage
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

## Networking Patterns

### Service Types

**ClusterIP** (Internal only):
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  type: ClusterIP
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 8000
```

**LoadBalancer** (External):
```yaml
spec:
  type: LoadBalancer
```

**NodePort** (Development):
```yaml
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: 8000
      nodePort: 30000
```

### Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - myapp.example.com
      secretName: myapp-tls
  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: myapp
                port:
                  number: 80
```

## Security Patterns

### Pod Security Context
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
```

### NetworkPolicy
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: myapp-netpol
spec:
  podSelector:
    matchLabels:
      app: myapp
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend
      ports:
        - protocol: TCP
          port: 8000
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: postgres
      ports:
        - protocol: TCP
          port: 5432
```

## Best Practices

### Labels
```yaml
metadata:
  labels:
    app: myapp
    version: v1.2.3
    environment: production
    team: backend
```

### Annotations
```yaml
metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8000"
```

### Affinity Rules
```yaml
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
            - key: app
              operator: In
              values:
                - myapp
        topologyKey: kubernetes.io/hostname
```

## Common Commands

```bash
# Deployments
kubectl get deployments
kubectl describe deployment myapp
kubectl rollout status deployment/myapp
kubectl rollout history deployment/myapp
kubectl rollout undo deployment/myapp

# Pods
kubectl get pods
kubectl logs -f pod-name
kubectl exec -it pod-name -- /bin/bash
kubectl port-forward pod-name 8000:8000

# Scaling
kubectl scale deployment myapp --replicas=5
kubectl autoscale deployment myapp --min=3 --max=10 --cpu-percent=70

# Configuration
kubectl create configmap myapp-config --from-file=config.yml
kubectl create secret generic myapp-secret --from-literal=password=secret

# Debugging
kubectl describe pod pod-name
kubectl get events --sort-by='.lastTimestamp'
kubectl top pods
kubectl top nodes
```

## Resources

- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Google Kubernetes Engine Best Practices](https://cloud.google.com/kubernetes-engine/docs/best-practices)
