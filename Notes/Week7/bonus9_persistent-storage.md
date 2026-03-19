**Persistent Storage & Volumes (The Filing Cabinet)**

**The Scenario:** By default, a container's filesystem is **ephemeral** — when the Pod dies, all data inside it is lost forever. If you're running a database, a file upload service, or anything that stores state, you need storage that **survives Pod restarts**. Kubernetes solves this with **Volumes**, **PersistentVolumes (PV)**, and **PersistentVolumeClaims (PVC)**.

---

**Mission: The Data Survival Test**

**1. Volume Types — From Ephemeral to Persistent**

| Type | Lifetime | Use Case |
|------|----------|----------|
| `emptyDir` | Dies with the Pod | Temp files, caches, scratch space shared between containers in the same Pod |
| `hostPath` | Tied to the Node | Dev/testing only — accesses the Node's filesystem directly |
| `persistentVolumeClaim` | Survives Pod restarts | Production databases, uploads, anything that must persist |
| Cloud volumes (EBS, EFS, GCE PD) | Independent of cluster | Provisioned by cloud provider, attached/detached as needed |

**2. The Core Concepts**

**PersistentVolume (PV):** A piece of storage that has been provisioned — either manually by an admin, or dynamically by a StorageClass. It's a **cluster-wide** resource (not namespaced).

**PersistentVolumeClaim (PVC):** A **request** for storage made by a Pod. It says: "I need 5Gi of ReadWriteOnce storage." Kubernetes finds a matching PV and binds them together.

**StorageClass:** A blueprint for **dynamic provisioning**. Instead of an admin pre-creating PVs, you define a StorageClass that says: "When someone requests storage, automatically create an AWS EBS gp3 volume."

```
Pod --> PVC ("I need 5Gi") --> PV (actual disk) --> Physical storage (EBS, NFS, local)
                                    ▲
                              StorageClass (auto-creates PV if needed)
```

**3. Access Modes**

| Mode | Short | Meaning |
|------|-------|---------|
| `ReadWriteOnce` | RWO | One Node can mount it read-write. Most common for databases. |
| `ReadOnlyMany` | ROX | Many Nodes can mount it read-only. Good for shared config/assets. |
| `ReadWriteMany` | RWX | Many Nodes can mount it read-write. Requires NFS or EFS. |

**4. Reclaim Policies**

What happens to the PV when the PVC is deleted?

| Policy | Behavior |
|--------|----------|
| `Retain` | PV and data are kept. Admin must manually clean up. Safest for production. |
| `Delete` | PV and the underlying storage (e.g., EBS volume) are automatically deleted. Default for dynamic provisioning. |

**5. The Manifests**

**StorageClass (`storageclass.yaml`):**
```YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-storage
provisioner: k8s.io/minikube-hostpath   # Minikube's built-in provisioner
reclaimPolicy: Retain
volumeBindingMode: Immediate            # Bind PV as soon as PVC is created
```

In production (AWS), the provisioner would be `ebs.csi.aws.com` and you'd specify `parameters.type: gp3`.

**PersistentVolumeClaim (`pvc.yaml`):**
```YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-data
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast-storage    # Use our StorageClass for dynamic provisioning
  resources:
    requests:
      storage: 1Gi                  # Request 1 gigabyte
```

**Pod with PVC mounted (`pod-with-storage.yaml`):**
```YAML
apiVersion: v1
kind: Pod
metadata:
  name: storage-test
spec:
  containers:
  - name: app
    image: alpine:latest
    command: ["sleep", "3600"]
    volumeMounts:
    - name: data-vol
      mountPath: /data              # The PVC appears as a directory here
  volumes:
  - name: data-vol
    persistentVolumeClaim:
      claimName: app-data           # References the PVC above
```

**6. StatefulSet + volumeClaimTemplates**

For StatefulSets (databases), each replica needs its **own** PVC. Instead of creating them manually, use `volumeClaimTemplates`:

```YAML
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  replicas: 3
  selector:
    matchLabels:
      app: database
  serviceName: db-headless
  template:
    metadata:
      labels:
        app: database
    spec:
      containers:
      - name: postgres
        image: postgres:16
        volumeMounts:
        - name: pg-data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:             # Each replica gets its own PVC automatically
  - metadata:
      name: pg-data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: fast-storage
      resources:
        requests:
          storage: 10Gi
```

This creates: `pg-data-postgres-0`, `pg-data-postgres-1`, `pg-data-postgres-2` — one PVC per replica, each bound to its own PV.

**7. Apply and Test**

```Bash
kubectl apply -f storageclass.yaml
kubectl apply -f pvc.yaml
kubectl apply -f pod-with-storage.yaml
```

**8. The Survival Test**

```Bash
# Write a file to the persistent volume
kubectl exec storage-test -- sh -c "echo 'I survived' > /data/proof.txt"

# Delete the Pod (the PVC stays)
kubectl delete pod storage-test

# Recreate the Pod (it binds to the same PVC)
kubectl apply -f pod-with-storage.yaml

# Read the file — it's still there!
kubectl exec storage-test -- cat /data/proof.txt
```

**Your Task:**

1. Apply the StorageClass, PVC, and Pod.
2. Write a file to `/data/proof.txt` inside the Pod.
3. Delete the Pod, recreate it, and read the file again.

**Paste the output of `cat /data/proof.txt` showing `I survived` after the Pod was recreated.**

**Key commands:**
```Bash
kubectl get pv                    # List PersistentVolumes
kubectl get pvc                   # List PersistentVolumeClaims
kubectl get storageclass          # List StorageClasses (or 'kubectl get sc')
kubectl describe pvc app-data     # See binding status, capacity, access modes
```
