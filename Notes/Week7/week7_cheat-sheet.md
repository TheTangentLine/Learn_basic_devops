**Week 7 Cheat Sheet: Kubernetes from Zero to Production**

This is the master reference for everything covered in Week 7. Every concept, every YAML field, every command — explained in detail.

---

# 1. MINIKUBE — The Local Playground

Minikube runs a single-node Kubernetes cluster inside a Docker container on your laptop. It simulates a real cluster for learning and development.

**Install:**
```Bash
brew install kubectl       # The CLI remote control for any K8s cluster
brew install minikube      # The local cluster simulator
```

**Start the cluster:**
```Bash
minikube start --driver=docker
```
- `--driver=docker`: Uses Docker Desktop as the virtualization backend (alternatives: `virtualbox`, `hyperkit`).
- This creates a single "node" (virtual server) that acts as both the control plane and worker node.

**Verify:**
```Bash
kubectl get nodes
```
- Output columns: `NAME` (node hostname), `STATUS` (Ready/NotReady), `ROLES` (control-plane), `AGE`, `VERSION` (K8s version).
- `Ready` = the node is healthy and can accept Pods.

**Useful Minikube commands:**
```Bash
minikube stop                  # Pause the cluster (preserves state)
minikube delete                # Destroy the cluster entirely
minikube dashboard             # Open the K8s web UI
minikube addons list           # Show available addons (ingress, metrics-server, etc.)
minikube addons enable <name>  # Enable an addon
minikube service <svc-name>    # Open a NodePort/LoadBalancer service in your browser
minikube ip                    # Get the cluster's IP address
```

---

# 2. PODS — The Smallest Unit

In Docker, the smallest unit is a **container**. In Kubernetes, it's a **Pod**. A Pod wraps one or more containers that share the same network namespace (same IP, same localhost) and storage volumes.

**Why not just run containers?** Kubernetes needs a higher-level abstraction to manage scheduling, networking, and lifecycle. The Pod is that abstraction.

**Full YAML anatomy:**
```YAML
apiVersion: v1           # API version — v1 for core resources (Pod, Service, ConfigMap, Secret)
kind: Pod                # Resource type
metadata:
  name: my-first-pod     # Unique name within the namespace
  labels:                # Key-value tags used for selection and organization
    app: nginx           # Services and Deployments use labels to find Pods
    tier: frontend       # You can add as many labels as you want
spec:
  containers:            # List of containers in this Pod
    - name: nginx-container    # Container name (for logs, exec)
      image: nginx:alpine      # Docker image to pull (registry/image:tag)
      ports:
        - containerPort: 80    # Informational — the port the container listens on
```

**Field-by-field breakdown:**

| Field | What It Does |
|-------|-------------|
| `apiVersion` | Tells K8s which API schema to use. `v1` = core. `apps/v1` = deployments. `networking.k8s.io/v1` = ingress. |
| `kind` | The resource type: Pod, Deployment, Service, ConfigMap, Secret, Ingress, etc. |
| `metadata.name` | The unique identifier. Used in `kubectl get`, `kubectl describe`, DNS. |
| `metadata.labels` | Key-value pairs. Not functional on their own — used by selectors to find this Pod. |
| `spec.containers[].name` | Each container in the Pod needs a unique name. Shows up in `kubectl logs <pod> -c <container>`. |
| `spec.containers[].image` | The Docker image. Format: `registry/image:tag`. Defaults to Docker Hub if no registry specified. |
| `spec.containers[].ports[].containerPort` | Purely informational metadata. The container actually listens on whatever port the app binds to — this field just documents it. |

**Pod lifecycle states:**

| Status | Meaning |
|--------|---------|
| `Pending` | Pod accepted but not yet scheduled to a Node (waiting for resources). |
| `ContainerCreating` | Scheduled to a Node, image is being pulled. |
| `Running` | At least one container is running. |
| `Succeeded` | All containers exited with code 0 (for Jobs). |
| `Failed` | All containers terminated, at least one with non-zero exit. |
| `CrashLoopBackOff` | Container keeps crashing and K8s is backing off before restarting. |
| `ImagePullBackOff` | K8s can't pull the container image (wrong name, no auth, etc.). |

**Key commands:**
```Bash
kubectl apply -f pod.yaml            # Create or update the Pod
kubectl get pods                      # List all Pods in current namespace
kubectl get pods -o wide              # Show Node, IP, and more columns
kubectl describe pod <name>           # Detailed info: events, status, conditions
kubectl logs <name>                   # Container stdout/stderr
kubectl logs <name> -c <container>    # Specific container in a multi-container Pod
kubectl exec <name> -- <command>      # Run a command inside the container
kubectl exec -it <name> -- /bin/sh    # Interactive shell into the container
kubectl delete pod <name>             # Kill the Pod (it stays dead unless managed by a Deployment)
```

---

# 3. DEPLOYMENTS — The Guardian

A Pod is mortal — if it crashes, it's gone. A **Deployment** is a manager that ensures a desired number of Pod replicas are always running. If a Pod dies, the Deployment creates a replacement.

**The chain:** Deployment -> creates a **ReplicaSet** -> creates **Pods**.
You almost never create ReplicaSets directly. The Deployment manages them for you.

**Full YAML anatomy:**
```YAML
apiVersion: apps/v1         # apps group — used for Deployments, StatefulSets, DaemonSets
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3               # Desired state: always keep exactly 3 Pods running
  selector:
    matchLabels:
      app: web               # The Deployment manages Pods with this label
  template:                  # Pod template — this IS the Pod spec, embedded inside
    metadata:
      labels:
        app: web             # MUST match selector.matchLabels above
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
```

**Field-by-field breakdown:**

| Field | What It Does |
|-------|-------------|
| `replicas` | How many Pod copies to maintain. K8s constantly reconciles actual count to this number. |
| `selector.matchLabels` | How the Deployment finds its Pods. Must match `template.metadata.labels`. |
| `template` | The Pod blueprint. Every Pod created by this Deployment uses this template. |
| `template.metadata.labels` | Labels applied to every Pod. Must match the selector or the Deployment rejects it. |

**Self-healing behavior:**
1. You set `replicas: 3`.
2. K8s creates 3 Pods.
3. You `kubectl delete pod <one-of-them>`.
4. The Deployment sees only 2 Pods matching its selector.
5. It immediately creates a new Pod to restore the count to 3.

**Key commands:**
```Bash
kubectl apply -f deployment.yaml                    # Create or update
kubectl get deployments                              # List deployments
kubectl get rs                                       # List ReplicaSets (managed by deployment)
kubectl scale deployment <name> --replicas=10        # Scale up/down instantly
kubectl rollout status deployment <name>             # Watch a rolling update
kubectl rollout undo deployment <name>               # Rollback to previous version
kubectl set image deployment/<name> <container>=<image:tag>  # Trigger a rolling update
```

---

# 4. SERVICES — Stable Networking for Pods

Pod IPs are ephemeral — they change on every restart. A **Service** provides a stable IP address and DNS name that sits in front of a group of Pods (selected by labels) and load-balances traffic between them.

## 4a. ClusterIP (Default — Internal Only)

A virtual IP that is only reachable from **inside** the cluster. Used for Pod-to-Pod communication (e.g., frontend calling backend).

```YAML
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  selector:
    app: backend            # Routes to Pods with this label
  ports:
    - protocol: TCP
      port: 80              # Port other Pods call (Service port)
      targetPort: 5000      # Port on the actual container
  type: ClusterIP           # Can be omitted — it's the default
```

**DNS:** Kubernetes creates `backend-service.default.svc.cluster.local`. Within the same namespace, you can just use `backend-service`.

**Full DNS format:** `<service-name>.<namespace>.svc.cluster.local`

**`port` vs `targetPort`:**
- `port`: The port exposed by the Service. Other Pods call this.
- `targetPort`: The port the container actually listens on. Can be different from `port`.
- Example: Service listens on 80, forwards to container on 5000.

## 4b. NodePort (External via Node IP)

Opens a **static port** (range 30000-32767) on every Node in the cluster. External traffic hits `<NodeIP>:<NodePort>` and gets forwarded to the Service, then to Pods.

```YAML
apiVersion: v1
kind: Service
metadata:
  name: my-web-service
spec:
  selector:
    app: web
  ports:
    - protocol: TCP
      port: 80              # Internal Service port
      targetPort: 80        # Container port
      # nodePort: 31000     # Optional — K8s assigns one from 30000-32767 if omitted
  type: NodePort
```

**How it works:** NodePort automatically creates a ClusterIP behind the scenes. Traffic flow: `<NodeIP>:31000` -> `ClusterIP:80` -> `Pod:80`.

**Minikube shortcut:** `minikube service my-web-service` — opens the URL in your browser.

## 4c. LoadBalancer (External via Cloud Provider)

Tells your cloud provider (AWS/GCP/Azure) to provision a **real, external load balancer** with a public IP. This costs money.

```YAML
apiVersion: v1
kind: Service
metadata:
  name: public-front-door
spec:
  selector:
    app: ingress-controller
  ports:
  - port: 80
    targetPort: 80
  - port: 443
    targetPort: 443
  type: LoadBalancer
```

**How it works:** LoadBalancer creates a NodePort, which creates a ClusterIP. The cloud LB sits in front and routes external traffic in. Traffic flow: `Internet` -> `Cloud LB (public IP)` -> `NodePort` -> `ClusterIP` -> `Pod`.

**EXTERNAL-IP:** Initially `<pending>` while the cloud provisions the LB. After 1-2 minutes, it shows a public IP (GCP) or URL (AWS ELB).

## 4d. ExternalName (DNS Alias)

Creates a **CNAME DNS record** inside the cluster that points to an external hostname. No proxying, no ClusterIP, no selector — just a DNS redirect.

```YAML
apiVersion: v1
kind: Service
metadata:
  name: external-db
spec:
  type: ExternalName
  externalName: my-db.us-east-1.rds.amazonaws.com
```

**Use case:** Your Pods call `external-db` instead of hardcoding the full RDS hostname. If the DB moves, you update one Service — not every Pod.

**What's different:** No `selector`, no `ports`, no `ClusterIP`. `kubectl get svc` shows `CLUSTER-IP` as empty.

## 4e. Headless Service (Per-Pod DNS)

A ClusterIP Service with `clusterIP: None`. Instead of one virtual IP, DNS returns the **individual IP addresses** of every Pod. Essential for **StatefulSets** where each Pod needs a unique identity.

```YAML
apiVersion: v1
kind: Service
metadata:
  name: db-headless
spec:
  clusterIP: None
  selector:
    app: database
  ports:
    - protocol: TCP
      port: 5432
      targetPort: 5432
```

**With a StatefulSet named `postgres`, each Pod gets stable DNS:**
- `postgres-0.db-headless.default.svc.cluster.local`
- `postgres-1.db-headless.default.svc.cluster.local`

**Normal Service vs Headless:**
- Normal: `nslookup backend-service` -> returns 1 virtual IP (10.96.x.x).
- Headless: `nslookup db-headless` -> returns N Pod IPs (10.244.0.5, 10.244.0.6, ...).

## 4f. Ingress (HTTP/HTTPS Router)

Not a Service type — it's a separate resource (`kind: Ingress`). It acts as a smart HTTP router that inspects the URL path or hostname and sends traffic to different internal Services.

**Requires an Ingress Controller** (like NGINX) to actually execute the rules. The Ingress resource is just the configuration.

```YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: myapp.local              # Match this hostname
    http:
      paths:
      - path: /                    # Route / to frontend
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
      - path: /api                 # Route /api to backend
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 80
```

**`pathType` options:**
- `Prefix`: Matches the URL prefix (e.g., `/api` matches `/api`, `/api/users`, `/api/v2/data`).
- `Exact`: Matches the exact URL only (e.g., `/api` matches only `/api`, not `/api/users`).
- `ImplementationSpecific`: Depends on the Ingress Controller.

**Minikube setup:**
```Bash
minikube addons enable ingress                                    # Install NGINX Ingress Controller
echo "$(minikube ip) myapp.local" | sudo tee -a /etc/hosts       # Map hostname to Minikube IP
```

## Service Types Comparison

| Type | Scope | Use Case | Gets External IP? | Key Config |
|------|-------|----------|-------------------|------------|
| **ClusterIP** | Internal only | Pod-to-Pod (frontend -> backend) | No | `type: ClusterIP` (default) |
| **NodePort** | External via Node IP | Dev/testing, static port 30000-32767 | No (uses Node IP + port) | `type: NodePort` |
| **LoadBalancer** | External via cloud LB | Production public-facing services | Yes (cloud-provisioned) | `type: LoadBalancer` |
| **ExternalName** | DNS alias | External databases, third-party APIs | No (CNAME only) | `type: ExternalName` + `externalName` |
| **Headless** | Internal, per-Pod DNS | StatefulSets, individual Pod addressing | No | `clusterIP: None` |
| **Ingress** | External HTTP/HTTPS | Path/host-based routing, single entry point | Yes (via controller + LB) | `kind: Ingress` + `rules` |

## Traffic Flow

```
Internet
   │
   ▼
LoadBalancer  ──▶  Provisions a cloud LB (public IP)
   │
   ▼
Ingress  ──▶  Routes by host/path (myapp.com/api -> backend, / -> frontend)
   │
   ├──▶  ClusterIP (frontend-service)  ──▶  Frontend Pods
   │
   ├──▶  ClusterIP (backend-service)   ──▶  Backend Pods
   │
   └──▶  Headless (db-headless)        ──▶  Individual DB Pods (postgres-0, postgres-1)

ExternalName (external-db)  ──▶  DNS redirect to my-db.us-east-1.rds.amazonaws.com
```

---

# 5. CONFIGMAPS — Non-Sensitive Configuration

A ConfigMap stores **non-sensitive** key-value pairs (feature flags, UI settings, URLs) and injects them into Pods as environment variables or mounted files.

**Create from command line:**
```Bash
kubectl create configmap app-config --from-literal=APP_COLOR=blue --from-literal=APP_MODE=dark
```

**Create from YAML:**
```YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_COLOR: "blue"
  APP_MODE: "dark"
  config.json: |          # You can store entire files as values
    {"theme": "dark", "lang": "en"}
```

**Inject as environment variable:**
```YAML
env:
  - name: THE_COLOR           # Env var name inside the container
    valueFrom:
      configMapKeyRef:
        name: app-config      # ConfigMap name
        key: APP_COLOR        # Key within the ConfigMap
```

**Inject all keys at once:**
```YAML
envFrom:
  - configMapRef:
      name: app-config        # Every key in app-config becomes an env var
```

**Mount as a file:**
```YAML
volumeMounts:
  - name: config-vol
    mountPath: /etc/config    # Files appear here
volumes:
  - name: config-vol
    configMap:
      name: app-config        # Each key becomes a filename, value becomes file content
```

**Key commands:**
```Bash
kubectl create configmap <name> --from-literal=KEY=VALUE     # Create from CLI
kubectl create configmap <name> --from-file=<filepath>        # Create from file
kubectl get configmaps                                        # List all
kubectl describe configmap <name>                             # See key-value pairs
kubectl delete configmap <name>                               # Remove
```

---

# 6. SECRETS — Sensitive Configuration

Secrets store **sensitive** data: passwords, API keys, TLS certificates, SSH keys. They are Base64-encoded (NOT encrypted by default — encryption at rest must be configured separately in production).

**Why not just use ConfigMaps?** Secrets have stricter access controls, are stored in tmpfs (RAM) on nodes, and are not printed in `kubectl describe pod` output.

**Create from command line:**
```Bash
kubectl create secret generic db-user-pass --from-literal=password='SuperSecret123'
kubectl create secret generic rds-cert-secret --from-file=global-bundle.pem
```

**Create from YAML (values must be Base64-encoded):**
```YAML
apiVersion: v1
kind: Secret
metadata:
  name: db-user-pass
type: Opaque            # Generic secret type
data:
  password: U3VwZXJTZWNyZXQxMjM=    # echo -n 'SuperSecret123' | base64
```

**Or use `stringData` to avoid manual encoding:**
```YAML
apiVersion: v1
kind: Secret
metadata:
  name: db-user-pass
type: Opaque
stringData:
  password: SuperSecret123    # K8s encodes it for you
```

**Inject as environment variable:**
```YAML
env:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: db-user-pass
        key: password
```

**Mount as a file (more secure — avoids env var leaking into logs):**
```YAML
volumeMounts:
  - name: secret-volume
    mountPath: "/etc/secrets"
    readOnly: true              # Always set to true for secrets
volumes:
  - name: secret-volume
    secret:
      secretName: db-user-pass  # File at /etc/secrets/password contains the value
```

**Secret types:**

| Type | Use |
|------|-----|
| `Opaque` | Generic (default). Any key-value pairs. |
| `kubernetes.io/tls` | TLS cert + key. Requires `tls.crt` and `tls.key`. |
| `kubernetes.io/dockerconfigjson` | Docker registry credentials for pulling private images. |
| `kubernetes.io/basic-auth` | Username + password. |
| `kubernetes.io/ssh-auth` | SSH private key. |

**Key commands:**
```Bash
kubectl create secret generic <name> --from-literal=KEY=VALUE
kubectl create secret generic <name> --from-file=<filepath>
kubectl get secrets
kubectl describe secret <name>          # Shows keys but NOT values
kubectl get secret <name> -o yaml       # Shows Base64-encoded values
echo "U3VwZXJTZWNyZXQxMjM=" | base64 --decode    # Decode a value
```

---

# 7. NAMESPACES — Virtual Cluster Isolation

Namespaces divide one physical cluster into multiple virtual clusters. Each namespace is an isolated scope for names — you can have a `web-service` in both `dev` and `prod` namespaces without conflict.

**Default namespaces:**

| Namespace | Purpose |
|-----------|---------|
| `default` | Where your resources go if you don't specify a namespace. |
| `kube-system` | Kubernetes system components (DNS, scheduler, controller-manager). |
| `kube-public` | Readable by everyone, even unauthenticated. Rarely used. |
| `kube-node-lease` | Node heartbeat data. Internal. |

**Key commands:**
```Bash
kubectl create namespace dev                          # Create a namespace
kubectl create namespace prod
kubectl get namespaces                                 # List all namespaces
kubectl apply -f deployment.yaml -n dev                # Deploy to specific namespace
kubectl get pods -n dev                                # List pods in a namespace
kubectl get pods --all-namespaces                      # List pods across ALL namespaces
kubectl get pods -A                                    # Shorthand for --all-namespaces
kubectl config set-context --current --namespace=dev   # Change default namespace for your session
```

**Cross-namespace DNS:** A Pod in the `dev` namespace can reach a Service in `prod` using the full DNS name: `backend-service.prod.svc.cluster.local`.

---

# 8. PRODUCTION PATTERNS — Bonus Topics

## 8a. Passwordless Database Auth (IAM Tokens)

Instead of hardcoding database passwords, use **IAM Authentication**. The AWS SDK generates a temporary, cryptographically signed token (SigV4) that expires in 15 minutes. No password stored anywhere.

```JavaScript
import { Signer } from "@aws-sdk/rds-signer";

const signer = new Signer({
  hostname: "db-cluster.us-east-1.rds.amazonaws.com",
  port: 5432,
  region: "us-east-1",
  username: "iam_db_user",
});

const token = await signer.getAuthToken();
// token is a massive SigV4-signed URL string — pass it as the password field
```

**The token contains:** `X-Amz-Date` (when generated), `X-Amz-Expires=900` (15-minute TTL), `X-Amz-Signature` (cryptographic proof).

## 8b. Pod Identities (ServiceAccounts)

By default, every Pod uses the `default` ServiceAccount, which has no permissions. To give a Pod a specific identity:

```YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: db-access-sa
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/app-db-role
```

```YAML
spec:
  serviceAccountName: db-access-sa    # Pod "wears" this identity badge
  containers:
  - name: app
    image: my-node-app:latest
```

**EKS Pod Identity chain:** Pod -> ServiceAccount -> IAM Role (via OIDC federation) -> AWS permissions.

## 8c. Secret Mounts for Certificates

Store `.pem` certificate files in Kubernetes Secrets and mount them as files inside the Pod:

```Bash
kubectl create secret generic rds-cert-secret --from-file=global-bundle.pem
```

```YAML
volumeMounts:
  - name: pem-vault
    mountPath: "/app/certs"
    readOnly: true
volumes:
  - name: pem-vault
    secret:
      secretName: rds-cert-secret
# App reads: fs.readFileSync('/app/certs/global-bundle.pem')
```

## 8d. RBAC (Role-Based Access Control)

The full permission chain: **ServiceAccount** (who) -> **Role** (what actions on what resources) -> **RoleBinding** (connects who to what).

**Role** (namespace-scoped):
```YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
- apiGroups: [""]           # "" = core API group
  resources: ["pods"]       # Which resources
  verbs: ["get", "list"]    # Which actions (NOT create, delete, update)
```

**RoleBinding** (connects ServiceAccount to Role):
```YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods-binding
subjects:
- kind: ServiceAccount
  name: readonly-sa
  namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

**ClusterRole / ClusterRoleBinding** — same but cluster-wide (all namespaces + non-namespaced resources like Nodes).

**Common verbs:** `get`, `list`, `watch`, `create`, `update`, `patch`, `delete`.
**Common apiGroups:** `""` (core: pods, services, secrets), `"apps"` (deployments), `"networking.k8s.io"` (ingress, network policies).

**Test permissions:**
```Bash
kubectl auth can-i list pods --as=system:serviceaccount:default:readonly-sa       # yes
kubectl auth can-i delete pods --as=system:serviceaccount:default:readonly-sa     # no
```

## 8e. Liveness, Readiness & Startup Probes

| Probe | Question | On Failure |
|-------|----------|------------|
| **Liveness** | Is the container alive? | K8s kills and restarts it |
| **Readiness** | Is it ready for traffic? | K8s removes it from Service endpoints |
| **Startup** | Has it finished booting? | Liveness/readiness probes are paused |

**Probe types:**
- `httpGet`: Sends HTTP GET. Success = 200-399.
- `tcpSocket`: Opens TCP connection. Success = port is open.
- `exec`: Runs a command. Success = exit code 0.

**All timing fields:**

| Field | Default | Meaning |
|-------|---------|---------|
| `initialDelaySeconds` | 0 | Wait before first probe |
| `periodSeconds` | 10 | How often to probe |
| `timeoutSeconds` | 1 | Max time to wait for response |
| `failureThreshold` | 3 | Consecutive failures before action |
| `successThreshold` | 1 | Consecutive successes to be healthy (readiness only) |

**Example:**
```YAML
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 10
  failureThreshold: 3
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  periodSeconds: 5
  failureThreshold: 1
startupProbe:
  httpGet:
    path: /healthz
    port: 8080
  failureThreshold: 30
  periodSeconds: 2         # 30 x 2 = 60s max startup time
```

## 8f. Resource Requests & Limits

| Field | Purpose | Enforcement |
|-------|---------|-------------|
| `requests.cpu` | Minimum guaranteed CPU | Scheduling (Node must have this free) |
| `requests.memory` | Minimum guaranteed memory | Scheduling |
| `limits.cpu` | Maximum CPU | Runtime — exceeding causes **throttling** |
| `limits.memory` | Maximum memory | Runtime — exceeding causes **OOMKilled** |

**Units:** CPU in millicores (`500m` = 0.5 core). Memory in Mi/Gi (`128Mi`, `1Gi`).

```YAML
resources:
  requests:
    cpu: "100m"
    memory: "64Mi"
  limits:
    cpu: "200m"
    memory: "128Mi"
```

**QoS classes (eviction priority):**

| Class | Condition | Eviction Order |
|-------|-----------|----------------|
| **Guaranteed** | requests == limits for all containers | Last (safest) |
| **Burstable** | requests < limits | Middle |
| **BestEffort** | No requests or limits | First (most likely to be evicted) |

## 8g. Horizontal Pod Autoscaler (HPA)

Automatically scales Pod replicas based on real-time CPU/memory metrics.

**Requires:** metrics-server (`minikube addons enable metrics-server`).
**Requires:** `resources.requests` set on the target Deployment (HPA compares actual usage vs requested).

```YAML
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: scaled-app
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50    # Scale up when avg CPU > 50% of requests
```

**Shortcut command:**
```Bash
kubectl autoscale deployment scaled-app --min=1 --max=10 --cpu-percent=50
```

**Monitor:**
```Bash
kubectl get hpa -w    # Watch TARGETS and REPLICAS in real time
```

## 8h. Network Policies (Pod Firewalls)

By default, all Pods can communicate with all other Pods. NetworkPolicies add firewall rules.

**Deny all ingress to a Pod:**
```YAML
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-to-backend
spec:
  podSelector:
    matchLabels:
      role: backend
  policyTypes:
  - Ingress
  ingress: []               # Empty = deny all incoming traffic
```

**Allow only from specific Pods:**
```YAML
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
spec:
  podSelector:
    matchLabels:
      role: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 80
```

**Egress rules (outgoing traffic):**
```YAML
egress:
- to:
  - podSelector:
      matchLabels:
        role: database
  ports:
  - protocol: TCP
    port: 5432
- to:                       # Always allow DNS or nothing works
  ports:
  - protocol: UDP
    port: 53
```

---

# 9. KUBECTL COMMAND REFERENCE

## Create & Apply

| Command | Description |
|---------|-------------|
| `kubectl apply -f <file.yaml>` | Create or update a resource from a YAML file |
| `kubectl create namespace <name>` | Create a namespace |
| `kubectl create configmap <name> --from-literal=K=V` | Create a ConfigMap from CLI |
| `kubectl create secret generic <name> --from-literal=K=V` | Create a Secret from CLI |
| `kubectl create secret generic <name> --from-file=<path>` | Create a Secret from a file |

## Inspect

| Command | Description |
|---------|-------------|
| `kubectl get nodes` | List all cluster nodes |
| `kubectl get pods` | List Pods in current namespace |
| `kubectl get pods -n <ns>` | List Pods in a specific namespace |
| `kubectl get pods -A` | List Pods across all namespaces |
| `kubectl get pods -o wide` | Show extra columns (Node, IP) |
| `kubectl get pods -l app=web` | Filter by label selector |
| `kubectl get pods -w` | Watch for real-time changes |
| `kubectl get svc` | List Services |
| `kubectl get deployments` | List Deployments |
| `kubectl get rs` | List ReplicaSets |
| `kubectl get ingress` | List Ingress resources |
| `kubectl get hpa` | List Horizontal Pod Autoscalers |
| `kubectl get configmaps` | List ConfigMaps |
| `kubectl get secrets` | List Secrets |
| `kubectl get namespaces` | List Namespaces |
| `kubectl get networkpolicies` | List Network Policies |
| `kubectl describe <resource> <name>` | Detailed info with events |
| `kubectl get <resource> <name> -o yaml` | Full YAML output |
| `kubectl get <resource> <name> -o jsonpath='{.field}'` | Extract a specific field |

## Debug

| Command | Description |
|---------|-------------|
| `kubectl logs <pod>` | View container logs |
| `kubectl logs <pod> -c <container>` | Logs from a specific container |
| `kubectl logs <pod> -f` | Follow logs in real time |
| `kubectl exec <pod> -- <cmd>` | Run a command inside a Pod |
| `kubectl exec -it <pod> -- /bin/sh` | Interactive shell |
| `kubectl port-forward <pod> 8080:80` | Forward local port to Pod port |
| `kubectl auth can-i <verb> <resource> --as=system:serviceaccount:<ns>:<sa>` | Test RBAC permissions |

## Modify & Delete

| Command | Description |
|---------|-------------|
| `kubectl scale deployment <name> --replicas=N` | Scale a Deployment |
| `kubectl autoscale deployment <name> --min=1 --max=10 --cpu-percent=50` | Create HPA |
| `kubectl set image deployment/<name> <container>=<image:tag>` | Rolling update |
| `kubectl rollout undo deployment <name>` | Rollback |
| `kubectl delete <resource> <name>` | Delete a specific resource |
| `kubectl delete -f <file.yaml>` | Delete everything defined in a YAML file |

## Minikube-Specific

| Command | Description |
|---------|-------------|
| `minikube start --driver=docker` | Start the cluster |
| `minikube stop` | Pause the cluster |
| `minikube delete` | Destroy the cluster |
| `minikube dashboard` | Open K8s web UI |
| `minikube service <svc>` | Open a Service in browser |
| `minikube ip` | Get the cluster IP |
| `minikube addons enable ingress` | Enable NGINX Ingress Controller |
| `minikube addons enable metrics-server` | Enable metrics for HPA |
