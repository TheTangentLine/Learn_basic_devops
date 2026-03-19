**StatefulSets (The Database Manager)**

**The Scenario:** You need to run a PostgreSQL cluster with 3 replicas. You try a Deployment, but it gives your Pods random names like `postgres-7c989d-abc1`. When a Pod dies and respawns, it gets a new random name, a new IP, and its old storage is gone. The other replicas have no idea who the "primary" is anymore. Replication breaks. For databases and any workload where **identity matters**, you need a **StatefulSet**.

---

**Mission: The Identity Test**

## 1. StatefulSet vs Deployment

| Feature | Deployment | StatefulSet |
|---------|-----------|-------------|
| Pod names | Random hash (`nginx-7c989d-abc1`) | Ordered index (`postgres-0`, `postgres-1`, `postgres-2`) |
| Pod identity | Interchangeable — any Pod can replace any other | Sticky — `postgres-0` is always `postgres-0`, even after restart |
| Creation order | All Pods created simultaneously | Sequential: 0 first, then 1, then 2 (each waits for previous to be Running) |
| Deletion order | All Pods deleted simultaneously | Reverse order: 2 first, then 1, then 0 |
| Storage | All Pods share the same PVC (or none) | Each Pod gets its **own** PVC via `volumeClaimTemplates` |
| Network identity | No stable DNS per Pod | Stable DNS: `<pod-name>.<headless-service>.<ns>.svc.cluster.local` |
| Use case | Stateless apps (web servers, APIs) | Stateful apps (databases, message queues, distributed systems) |

**Why Deployments fail for databases:** If `postgres-7c989d-abc1` (the primary) dies and respawns as `postgres-7c989d-xyz9`, the replicas can't find it — the DNS name changed, the IP changed, and the data volume is gone. StatefulSets guarantee that `postgres-0` is always `postgres-0`.

## 2. The Three Guarantees

**Guarantee 1: Stable Network Identity**

Each Pod gets a predictable DNS name that never changes, even across restarts:
```
postgres-0.db-headless.default.svc.cluster.local
postgres-1.db-headless.default.svc.cluster.local
postgres-2.db-headless.default.svc.cluster.local
```

This requires a **Headless Service** (`clusterIP: None`) — the StatefulSet's `serviceName` field points to it.

**Guarantee 2: Stable Persistent Storage**

Each Pod gets its own PersistentVolumeClaim through `volumeClaimTemplates`. When `postgres-1` dies and respawns, it reattaches to the **same** PVC (`pg-data-postgres-1`), so all its data is intact.

```
postgres-0  ──▶  pg-data-postgres-0 (PVC)  ──▶  PV (10Gi disk)
postgres-1  ──▶  pg-data-postgres-1 (PVC)  ──▶  PV (10Gi disk)
postgres-2  ──▶  pg-data-postgres-2 (PVC)  ──▶  PV (10Gi disk)
```

Deleting a Pod does NOT delete its PVC. Even deleting the entire StatefulSet keeps the PVCs (you must delete them manually).

**Guarantee 3: Ordered Deployment and Scaling**

- **Scale up:** `postgres-0` must be Running and Ready before `postgres-1` is created. `postgres-1` must be Running before `postgres-2` starts.
- **Scale down:** `postgres-2` is terminated first, then `postgres-1`, then `postgres-0`.
- **Why this matters:** In database replication, the primary (index 0) must be fully operational before replicas try to connect and sync.

## 3. The Full Manifest

**Headless Service (`db-headless-service.yaml`):**
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
  - port: 5432
    targetPort: 5432
```

**StatefulSet (`postgres-statefulset.yaml`):**
```YAML
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: db-headless          # REQUIRED: Links to the headless Service for DNS
  replicas: 3
  podManagementPolicy: OrderedReady # Default: sequential creation. Alternative: "Parallel"
  updateStrategy:
    type: RollingUpdate             # Default: updates Pods one at a time in reverse order
    rollingUpdate:
      partition: 0                  # Update all Pods. Set to 2 to only update postgres-2+
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
    spec:
      containers:
      - name: postgres
        image: postgres:16
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_PASSWORD
          value: "changeme"         # In production, use a Secret
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name   # Injects "postgres-0", "postgres-1", etc.
        volumeMounts:
        - name: pg-data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: pg-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

**Field-by-field breakdown:**

| Field | What It Does |
|-------|-------------|
| `serviceName` | **Required.** Must match the name of a headless Service. Generates stable DNS names for each Pod. |
| `replicas` | Number of ordered Pods to maintain. |
| `podManagementPolicy` | `OrderedReady` (default): sequential creation/deletion. `Parallel`: all Pods created/deleted at once (use for workloads that don't need ordering). |
| `updateStrategy.type` | `RollingUpdate` (default): updates Pods one at a time in reverse order (highest index first). `OnDelete`: Pods only update when manually deleted. |
| `updateStrategy.rollingUpdate.partition` | Only Pods with index >= partition are updated. Set to `replicas` to prevent any updates (canary testing). |
| `volumeClaimTemplates` | Template for auto-creating one PVC per Pod. PVC name format: `<template-name>-<statefulset-name>-<index>`. |

## 4. Data Synchronization Patterns

Kubernetes does NOT handle database replication for you. The StatefulSet provides **identity and storage**. YOU (or an Operator) must configure how data flows between replicas.

### Pattern A: Primary/Replica (Leader/Follower)

The most common pattern. `postgres-0` is the primary (accepts writes). `postgres-1` and `postgres-2` are read replicas that stream changes from the primary.

```
                   Writes
Client  ────────▶  postgres-0 (PRIMARY)
                      │
                      │  WAL stream (Write-Ahead Log)
                      ├──────────▶  postgres-1 (REPLICA - read only)
                      │
                      └──────────▶  postgres-2 (REPLICA - read only)
                                         ▲
                                    Reads (load balanced)
```

**How replicas know who is primary:** By convention, index 0 is the primary. Replicas are configured to connect to `postgres-0.db-headless` for streaming replication.

### Pattern B: Init Container (Bootstrap Sync)

When a **new replica** joins the cluster (e.g., you scale from 2 to 3), it needs a **full copy** of the primary's data before it can start streaming incremental changes. An **init container** runs before the main container and copies the data.

```YAML
spec:
  initContainers:
  - name: clone-from-primary
    image: postgres:16
    command:
    - bash
    - -c
    - |
      if [ "$POD_NAME" != "postgres-0" ]; then
        echo "I am a replica. Cloning data from primary..."
        pg_basebackup -h postgres-0.db-headless -U replicator -D /data -Fp -Xs -P
      else
        echo "I am the primary. No cloning needed."
      fi
    env:
    - name: POD_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
    volumeMounts:
    - name: pg-data
      mountPath: /data
  containers:
  - name: postgres
    image: postgres:16
    # ... main container starts after init container finishes
```

**How it works:**
1. Init container checks the Pod name.
2. If it's NOT `postgres-0`, it runs `pg_basebackup` to clone the primary's data directory.
3. Once the clone is complete, the init container exits.
4. The main postgres container starts with a full data copy and begins streaming incremental changes (WAL) from the primary.

### Pattern C: Sidecar Container (Continuous Sync)

A **sidecar** container runs alongside the main database container and continuously streams replication data. This is common when the database itself doesn't have built-in streaming replication.

```YAML
spec:
  containers:
  - name: postgres
    image: postgres:16
    ports:
    - containerPort: 5432
    volumeMounts:
    - name: pg-data
      mountPath: /var/lib/postgresql/data
  - name: replication-agent
    image: custom-replication-agent:latest
    env:
    - name: PRIMARY_HOST
      value: "postgres-0.db-headless"
    - name: ROLE
      valueFrom:
        fieldRef:
          fieldPath: metadata.name    # Determines primary vs replica
    volumeMounts:
    - name: pg-data
      mountPath: /var/lib/postgresql/data
```

The sidecar detects whether it's running on the primary or a replica, then either streams WAL out (primary) or receives WAL in (replica).

### Pattern D: Kubernetes Operators (The Autopilot)

In production, you rarely configure replication manually. **Operators** are custom controllers that understand the database's replication protocol and handle everything automatically:

| Operator | Database | What It Automates |
|----------|----------|-------------------|
| **CloudNativePG** | PostgreSQL | Streaming replication, automated failover, backups, point-in-time recovery |
| **Zalando Postgres Operator** | PostgreSQL | Patroni-based HA, connection pooling, S3 backups |
| **Percona Operator** | MySQL/MongoDB | Group replication, automated scaling, encrypted backups |
| **Strimzi** | Kafka | Broker management, topic operators, rack awareness |
| **Redis Operator** | Redis | Sentinel-based HA, cluster mode, automatic sharding |

**How Operators work:**
1. You install the Operator (a Pod running a custom controller).
2. You create a Custom Resource (CR) like `kind: Cluster` (CloudNativePG).
3. The Operator reads the CR and creates the StatefulSet, headless Service, PVCs, replication config, and monitoring — all automatically.
4. If the primary dies, the Operator promotes a replica to primary and reconfigures the others.

```YAML
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: my-postgres
spec:
  instances: 3
  storage:
    size: 10Gi
  # That's it. CloudNativePG handles replication, failover, backups, everything.
```

### Sync Patterns Summary

| Pattern | When to Use | Complexity | Who Manages Replication? |
|---------|-------------|------------|--------------------------|
| **Init Container** | Bootstrap a new replica with a full data copy | Medium | You (custom scripts) |
| **Sidecar** | Continuous replication for databases without built-in streaming | High | You (custom agent) |
| **Built-in Streaming** | PostgreSQL, MySQL — use native replication protocol | Medium | You (database config) |
| **Operator** | Production — fully automated replication, failover, backups | Low (for you) | The Operator |

## 5. Apply and Test

```Bash
kubectl apply -f db-headless-service.yaml
kubectl apply -f postgres-statefulset.yaml
```

**Watch ordered creation:**
```Bash
kubectl get pods -l app=database -w
```

You'll see `postgres-0` go to Running first, then `postgres-1`, then `postgres-2` — each waiting for the previous one.

**Verify each Pod has its own PVC:**
```Bash
kubectl get pvc
```

Output:
```Plaintext
NAME                    STATUS   VOLUME       CAPACITY   ACCESS MODES   AGE
pg-data-postgres-0      Bound    pv-abc123    10Gi       RWO            2m
pg-data-postgres-1      Bound    pv-def456    10Gi       RWO            1m
pg-data-postgres-2      Bound    pv-ghi789    10Gi       RWO            30s
```

**Test identity persistence:**
```Bash
# Delete the last replica
kubectl delete pod postgres-2

# Watch it respawn with the SAME name and SAME PVC
kubectl get pods -l app=database -w
kubectl get pvc
```

`postgres-2` comes back as `postgres-2` (not a random name), bound to the same `pg-data-postgres-2` PVC.

**Your Task:**

1. Apply the headless Service and StatefulSet.
2. Watch the Pods come up in order with `kubectl get pods -w`.
3. Run `kubectl get pvc` to verify 3 separate PVCs.
4. Delete `postgres-2` and verify it respawns with the same name.

**Paste the output of `kubectl get pvc` showing the three individual PVCs, and the `kubectl get pods` output showing `postgres-2` respawned with a young AGE.**
