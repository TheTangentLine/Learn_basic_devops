**Resource Requests & Limits (The Budget)**

**The Scenario:** You have a cluster with 4 CPU cores and 8 GB of RAM shared across many Pods. Without budgets, one greedy Pod can eat all the memory and crash everything else. **Requests** tell the scheduler: "I need at least this much to run." **Limits** tell the kernel: "Never let me use more than this."

---

**Mission: The OOMKill Test**

**1. Requests vs Limits**

| Field | Purpose | When It Matters |
|-------|---------|-----------------|
| `requests.cpu` | Minimum guaranteed CPU | **Scheduling** — K8s places the Pod on a Node that has this much free |
| `requests.memory` | Minimum guaranteed memory | **Scheduling** — same as CPU |
| `limits.cpu` | Maximum CPU allowed | **Runtime** — exceeding this causes CPU **throttling** (slows down, doesn't kill) |
| `limits.memory` | Maximum memory allowed | **Runtime** — exceeding this causes **OOMKilled** (container is killed immediately) |

CPU is measured in **millicores**: `500m` = 0.5 CPU cores. `1000m` = 1 full core.
Memory is measured in **Mi/Gi**: `128Mi` = 128 megabytes. `1Gi` = 1 gigabyte.

**2. QoS Classes**

Kubernetes assigns a Quality of Service class based on how you set requests and limits:

| QoS Class | Condition | Eviction Priority |
|-----------|-----------|-------------------|
| **Guaranteed** | `requests == limits` for all containers | Last to be evicted (highest priority) |
| **Burstable** | `requests < limits` (or only requests set) | Evicted after BestEffort |
| **BestEffort** | No requests or limits set at all | First to be evicted (lowest priority) |

**3. The Manifest (`limited-pod.yaml`)**

Create `limited-pod.yaml`:

```YAML
apiVersion: v1
kind: Pod
metadata:
  name: limited-app
spec:
  containers:
  - name: stress
    image: polinux/stress
    command: ["stress"]
    args: ["--vm", "1", "--vm-bytes", "200M", "--timeout", "60s"]
    resources:
      requests:
        cpu: "100m"       # Guarantee 0.1 CPU cores
        memory: "64Mi"    # Guarantee 64 MB
      limits:
        cpu: "200m"       # Cap at 0.2 CPU cores
        memory: "128Mi"   # Cap at 128 MB — but the app tries to use 200M!
```

The container tries to allocate 200 MB, but the limit is 128 Mi. The kernel will **OOMKill** it.

**4. Apply and Watch**

```Bash
kubectl apply -f limited-pod.yaml

# Watch the pod get OOMKilled
kubectl get pods limited-app -w
```

**5. Inspect the Kill**

```Bash
kubectl describe pod limited-app | grep -A 5 "Last State"
```

You'll see `Reason: OOMKilled` — proof that the memory limit was enforced.

**6. Check the QoS Class**

```Bash
kubectl get pod limited-app -o jsonpath='{.status.qosClass}'
```

Since `requests != limits`, this Pod is classified as **Burstable**.

**Your Task:**

1. Apply the manifest.
2. Watch the Pod status cycle through `Running` -> `OOMKilled` -> `CrashLoopBackOff`.
3. Run the `describe` command.

**Paste the output showing `OOMKilled` as the termination reason.**
