**Liveness & Readiness Probes (The Health Inspector)**

**The Scenario:** Your Pod is "Running" according to `kubectl get pods`, but the app inside has crashed, frozen, or is still loading. Kubernetes doesn't know — it only sees the container process is alive. **Probes** are health checks that Kubernetes runs on a schedule. They answer three questions: "Is it alive?" (Liveness), "Is it ready for traffic?" (Readiness), and "Has it finished starting?" (Startup).

---

**Mission: The Self-Healing App**

**1. The Three Probes**

| Probe | Question | On Failure |
|-------|----------|------------|
| **Liveness** | "Is the container still alive?" | K8s **kills and restarts** the container |
| **Readiness** | "Is it ready to serve traffic?" | K8s **removes it from Service endpoints** (no traffic routed, but container stays alive) |
| **Startup** | "Has it finished booting?" | K8s **waits** — liveness/readiness probes are paused until startup succeeds |

**2. Probe Types**

- `httpGet`: Sends an HTTP GET. Success = 200-399 status code.
- `tcpSocket`: Opens a TCP connection. Success = port is open.
- `exec`: Runs a command inside the container. Success = exit code 0.

**3. The Manifest (`probed-deployment.yaml`)**

Create `probed-deployment.yaml` with all three probes:

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: healthy-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: healthy
  template:
    metadata:
      labels:
        app: healthy
    spec:
      containers:
      - name: app
        image: nginx:alpine
        ports:
        - containerPort: 80
        startupProbe:
          httpGet:
            path: /
            port: 80
          failureThreshold: 30   # Try 30 times before giving up
          periodSeconds: 2       # Every 2 seconds (= 60s max startup time)
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 0   # Starts immediately after startup probe passes
          periodSeconds: 10        # Check every 10 seconds
          failureThreshold: 3      # 3 consecutive failures = restart
          timeoutSeconds: 1        # Each check must respond within 1s
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 0
          periodSeconds: 5         # Check every 5 seconds
          failureThreshold: 1      # 1 failure = remove from Service immediately
          successThreshold: 1      # 1 success = add back to Service
```

**Key Fields Explained:**
- `initialDelaySeconds`: Wait this long before the first probe check.
- `periodSeconds`: How often to run the probe.
- `failureThreshold`: How many consecutive failures before taking action.
- `successThreshold`: How many consecutive successes to be considered healthy again (only relevant for readiness).
- `timeoutSeconds`: Max wait for a single probe response.

**4. Apply**

```Bash
kubectl apply -f probed-deployment.yaml
```

**5. The Crash Simulation**

Exec into a Pod and break the liveness check by removing the default NGINX page:

```Bash
# Get a pod name
kubectl get pods -l app=healthy

# Break the health endpoint
kubectl exec <POD_NAME> -- rm /usr/share/nginx/html/index.html

# Watch K8s detect the failure and restart
kubectl get pods -l app=healthy -w
```

**Your Task:**

1. Apply the manifest.
2. Delete the `index.html` inside a Pod.
3. Watch the RESTARTS column increment.

**Paste the output of `kubectl get pods` showing the restart count go from 0 to 1.**
