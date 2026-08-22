# Kubernetes Deployment Template

## Overview

Production-ready Kubernetes manifests including Deployment, Service, ConfigMap, Secret, Ingress, and HorizontalPodAutoscaler configurations.

## Complete Application Stack

### Namespace

```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: myapp
  labels:
    name: myapp
    environment: production
```

### ConfigMap

```yaml
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
  namespace: myapp
data:
  # Application configuration
  LOG_LEVEL: "info"
  ENVIRONMENT: "production"
  APP_NAME: "myapp"

  # Database configuration (non-sensitive)
  DATABASE_HOST: "postgres-service"
  DATABASE_PORT: "5432"
  DATABASE_NAME: "myapp"

  # Redis configuration
  REDIS_HOST: "redis-service"
  REDIS_PORT: "6379"

  # Feature flags
  FEATURE_X_ENABLED: "true"
  FEATURE_Y_ENABLED: "false"
```

### Secret

```yaml
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: myapp-secret
  namespace: myapp
type: Opaque
stringData:
  # Database credentials
  DATABASE_USER: postgres
  DATABASE_PASSWORD: changeme

  # API keys
  API_KEY: your-api-key
  SECRET_KEY: your-secret-key

  # Redis password
  REDIS_PASSWORD: redis-password

# Or use base64 encoded data:
# data:
#   DATABASE_PASSWORD: cGFzc3dvcmQ=  # base64 encoded
```

### Deployment

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: myapp
  labels:
    app: myapp
    version: v1.0.0
  annotations:
    deployment.kubernetes.io/revision: "1"
spec:
  replicas: 3

  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0

  selector:
    matchLabels:
      app: myapp

  template:
    metadata:
      labels:
        app: myapp
        version: v1.0.0
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8000"
        prometheus.io/path: "/metrics"

    spec:
      # Security context for pod
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 1000

      # Init containers (optional)
      initContainers:
        - name: init-db
          image: busybox:1.35
          command:
            - sh
            - -c
            - |
              until nc -z postgres-service 5432; do
                echo "Waiting for database..."
                sleep 2
              done

      containers:
        - name: myapp
          image: myregistry.io/myapp:v1.0.0
          imagePullPolicy: IfNotPresent

          ports:
            - name: http
              containerPort: 8000
              protocol: TCP
            - name: metrics
              containerPort: 9090
              protocol: TCP

          env:
            # From ConfigMap
            - name: LOG_LEVEL
              valueFrom:
                configMapKeyRef:
                  name: myapp-config
                  key: LOG_LEVEL

            - name: ENVIRONMENT
              valueFrom:
                configMapKeyRef:
                  name: myapp-config
                  key: ENVIRONMENT

            # From Secret
            - name: DATABASE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: myapp-secret
                  key: DATABASE_PASSWORD

            - name: API_KEY
              valueFrom:
                secretKeyRef:
                  name: myapp-secret
                  key: API_KEY

            # Pod metadata
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name

            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace

            - name: POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP

          # Environment from entire ConfigMap/Secret
          envFrom:
            - configMapRef:
                name: myapp-config
            - secretRef:
                name: myapp-secret

          # Resource limits and requests
          resources:
            requests:
              cpu: 250m
              memory: 512Mi
            limits:
              cpu: 1000m
              memory: 2Gi

          # Liveness probe (restart if unhealthy)
          livenessProbe:
            httpGet:
              path: /health/live
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            successThreshold: 1
            failureThreshold: 3

          # Readiness probe (remove from service if not ready)
          readinessProbe:
            httpGet:
              path: /health/ready
              port: http
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 3
            successThreshold: 1
            failureThreshold: 3

          # Startup probe (for slow-starting containers)
          startupProbe:
            httpGet:
              path: /health/startup
              port: http
            initialDelaySeconds: 0
            periodSeconds: 10
            timeoutSeconds: 3
            successThreshold: 1
            failureThreshold: 30

          # Volume mounts
          volumeMounts:
            - name: config
              mountPath: /app/config
              readOnly: true
            - name: data
              mountPath: /app/data
            - name: tmp
              mountPath: /tmp

          # Security context for container
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            runAsNonRoot: true
            runAsUser: 1000
            capabilities:
              drop:
                - ALL

      # Volumes
      volumes:
        - name: config
          configMap:
            name: myapp-config
        - name: data
          persistentVolumeClaim:
            claimName: myapp-pvc
        - name: tmp
          emptyDir: {}

      # Affinity and anti-affinity rules
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: app
                      operator: In
                      values:
                        - myapp
                topologyKey: kubernetes.io/hostname

      # Tolerations
      tolerations:
        - key: node-role.kubernetes.io/spot
          operator: Equal
          value: "true"
          effect: NoSchedule

      # Image pull secrets (if using private registry)
      imagePullSecrets:
        - name: regcred

      # Termination grace period
      terminationGracePeriodSeconds: 30
```

### Service

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
  namespace: myapp
  labels:
    app: myapp
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  type: ClusterIP  # or LoadBalancer, NodePort

  selector:
    app: myapp

  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: http
    - name: metrics
      protocol: TCP
      port: 9090
      targetPort: metrics

  sessionAffinity: None
```

### Ingress

```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  namespace: myapp
  annotations:
    # Cert manager
    cert-manager.io/cluster-issuer: "letsencrypt-prod"

    # Nginx ingress controller
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "50m"
    nginx.ingress.kubernetes.io/rate-limit: "100"

    # AWS ALB (alternative)
    # alb.ingress.kubernetes.io/scheme: internet-facing
    # alb.ingress.kubernetes.io/target-type: ip
spec:
  ingressClassName: nginx

  tls:
    - hosts:
        - myapp.example.com
        - www.myapp.example.com
      secretName: myapp-tls

  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: myapp-service
                port:
                  number: 80

    - host: www.myapp.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: myapp-service
                port:
                  number: 80
```

### Horizontal Pod Autoscaler

```yaml
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
  namespace: myapp
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

    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80

    # Custom metrics (requires metrics server)
    - type: Pods
      pods:
        metric:
          name: http_requests_per_second
        target:
          type: AverageValue
          averageValue: "1000"

  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 50
          periodSeconds: 60
        - type: Pods
          value: 2
          periodSeconds: 60
      selectPolicy: Min

    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
        - type: Percent
          value: 100
          periodSeconds: 30
        - type: Pods
          value: 4
          periodSeconds: 30
      selectPolicy: Max
```

### PersistentVolumeClaim

```yaml
# pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myapp-pvc
  namespace: myapp
spec:
  accessModes:
    - ReadWriteOnce

  resources:
    requests:
      storage: 10Gi

  storageClassName: standard  # or gp2, fast-ssd, etc.
```

### ServiceAccount

```yaml
# serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: myapp-sa
  namespace: myapp

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: myapp-role
  namespace: myapp
rules:
  - apiGroups: [""]
    resources: ["configmaps", "secrets"]
    verbs: ["get", "list"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: myapp-rolebinding
  namespace: myapp
subjects:
  - kind: ServiceAccount
    name: myapp-sa
    namespace: myapp
roleRef:
  kind: Role
  name: myapp-role
  apiGroup: rbac.authorization.k8s.io
```

## Kustomization (Optional)

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: myapp

resources:
  - namespace.yaml
  - configmap.yaml
  - secret.yaml
  - deployment.yaml
  - service.yaml
  - ingress.yaml
  - hpa.yaml
  - pvc.yaml
  - serviceaccount.yaml

# Common labels
commonLabels:
  app: myapp
  managed-by: kustomize

# Image transformation
images:
  - name: myapp
    newName: myregistry.io/myapp
    newTag: v1.0.0

# ConfigMap generator
configMapGenerator:
  - name: myapp-env-config
    envs:
      - config.env

# Secret generator
secretGenerator:
  - name: myapp-env-secret
    envs:
      - secret.env
```

## Deployment Commands

```bash
# =============================================================================
# Basic Operations
# =============================================================================

# Apply all manifests
kubectl apply -f .

# Apply specific file
kubectl apply -f deployment.yaml

# Apply with kustomize
kubectl apply -k .

# Delete resources
kubectl delete -f deployment.yaml

# =============================================================================
# Deployment Management
# =============================================================================

# View deployments
kubectl get deployments -n myapp

# Describe deployment
kubectl describe deployment myapp -n myapp

# View pods
kubectl get pods -n myapp

# View pod logs
kubectl logs -f pod-name -n myapp

# View logs from all pods
kubectl logs -f -l app=myapp -n myapp

# Execute command in pod
kubectl exec -it pod-name -n myapp -- /bin/bash

# =============================================================================
# Updates and Rollbacks
# =============================================================================

# Update image
kubectl set image deployment/myapp myapp=myregistry.io/myapp:v1.1.0 -n myapp

# View rollout status
kubectl rollout status deployment/myapp -n myapp

# View rollout history
kubectl rollout history deployment/myapp -n myapp

# Rollback to previous version
kubectl rollout undo deployment/myapp -n myapp

# Rollback to specific revision
kubectl rollout undo deployment/myapp --to-revision=2 -n myapp

# Restart deployment
kubectl rollout restart deployment/myapp -n myapp

# =============================================================================
# Scaling
# =============================================================================

# Manual scale
kubectl scale deployment/myapp --replicas=5 -n myapp

# Autoscale
kubectl autoscale deployment/myapp --min=3 --max=10 --cpu-percent=70 -n myapp

# =============================================================================
# Debugging
# =============================================================================

# Port forward to pod
kubectl port-forward pod-name 8000:8000 -n myapp

# Port forward to service
kubectl port-forward service/myapp-service 8080:80 -n myapp

# View events
kubectl get events -n myapp --sort-by='.lastTimestamp'

# View resource usage
kubectl top pods -n myapp
kubectl top nodes
```

## Best Practices

### 1. Resource Management
- Always set resource requests and limits
- Monitor actual usage and adjust
- Use vertical pod autoscaler for recommendations

### 2. Health Checks
- Implement all three probes: liveness, readiness, startup
- Use different endpoints for each probe
- Set appropriate timeouts and thresholds

### 3. Security
- Run as non-root user
- Use read-only root filesystem
- Drop all capabilities
- Use network policies

### 4. High Availability
- Use pod anti-affinity for spreading replicas
- Set appropriate replica counts (minimum 3 for production)
- Implement graceful shutdown

### 5. Configuration Management
- Use ConfigMaps for configuration
- Use Secrets for sensitive data
- Consider external secret management (Vault, AWS Secrets Manager)

## Related Templates

- `docker-compose-template.md` - Local development environment
- `helm-chart-template.md` - Kubernetes package manager
- `terraform-kubernetes-template.md` - Infrastructure as code
