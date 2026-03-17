**Horizontal Pod Autoscaler (The Elastic Band)**

**The Scenario:** At 3 AM, your app gets 10 requests per minute. At noon, it gets 10,000. You could run 50 replicas 24/7 (expensive), or you could let Kubernetes **automatically scale** the number of Pods based on real-time CPU or memory usage. That's the **Horizontal Pod Autoscaler (HPA)**.

---

**Mission: The Auto-Scale Test**

**1. Prerequisites: Metrics Server**

HPA needs to read real-time CPU/memory metrics. On Minikube:

```Bash
minikube addons enable metrics-server

# Verify it's running (may take a minute)
kubectl get pods -n kube-system | grep metrics-server
```

**2. The Target Deployment (`scaled-app.yaml`)**

Create `scaled-app.yaml`. The Deployment **must** have `resources.requests` set — HPA compares actual usage against the requested amount.

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scaled-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: scaled
  template:
    metadata:
      labels:
        app: scaled
    spec:
      containers:
      - name: app
        image: nginx:alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "50m"    # HPA uses this as the baseline (100% = 50m)
          limits:
            cpu: "200m"
```

**3. The HPA Manifest (`hpa.yaml`)**

Create `hpa.yaml`:

```YAML
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: scaled-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: scaled-app            # Which Deployment to scale
  minReplicas: 1                # Never go below 1 Pod
  maxReplicas: 10               # Never go above 10 Pods
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50  # Target: keep average CPU at 50% of requests
```

When average CPU usage across all Pods exceeds 50% of the requested `50m` (i.e., above `25m`), HPA adds more Pods. When it drops, HPA removes them.

**4. The Shortcut (Alternative)**

Instead of a YAML file, you can create an HPA in one command:

```Bash
kubectl autoscale deployment scaled-app --min=1 --max=10 --cpu-percent=50
```

**5. Apply**

```Bash
kubectl apply -f scaled-app.yaml
kubectl apply -f hpa.yaml
```

**6. Generate Load**

Open a second terminal and flood the app with requests:

```Bash
kubectl run load-gen --image=busybox --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://scaled-app; done"
```

**7. Watch the Magic**

```Bash
# Watch HPA react in real time
kubectl get hpa scaled-app-hpa -w
```

You'll see `TARGETS` climb above 50%, then `REPLICAS` increase from 1 to 2, 3, 4...

**8. Cool Down**

```Bash
kubectl delete pod load-gen
# Wait 5 minutes — HPA scales back down automatically
kubectl get hpa scaled-app-hpa -w
```

**Your Task:**

1. Enable metrics-server, apply the deployment and HPA.
2. Generate load and watch `kubectl get hpa -w`.
3. Delete the load generator and watch it scale back down.

**Paste the output of `kubectl get hpa` showing replicas above 1 during load.**
