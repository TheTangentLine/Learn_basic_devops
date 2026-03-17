**Week 7, Day 46-5: Headless Service (The Direct Line)**

**The Scenario:** You're running a **StatefulSet** — a database cluster where each Pod is unique (e.g., `postgres-0` is the primary, `postgres-1` is a replica). A normal ClusterIP Service gives you one virtual IP and load-balances randomly. But you need to reach **each Pod individually** by name. A **Headless Service** (`clusterIP: None`) skips the virtual IP entirely and instead returns the IP addresses of every individual Pod via DNS.

---

**Day 46-5 Mission: The Direct Pod DNS**

**1. The Manifest (`headless-service.yaml`)**
Create `headless-service.yaml`. The key is `clusterIP: None`.

```YAML
apiVersion: v1
kind: Service
metadata:
  name: db-headless
spec:
  clusterIP: None        # THE KEY: Makes it headless
  selector:
    app: database
  ports:
    - protocol: TCP
      port: 5432
      targetPort: 5432
```

With a StatefulSet named `postgres` and this headless Service, each Pod gets a stable DNS name:
- `postgres-0.db-headless.default.svc.cluster.local`
- `postgres-1.db-headless.default.svc.cluster.local`

**2. Apply**

```Bash
kubectl apply -f headless-service.yaml
```

**3. Verify It's Headless**

```Bash
kubectl get svc db-headless
```

The `CLUSTER-IP` column should say `None`.

**4. Test Pod DNS Resolution**

```Bash
kubectl exec <ANY_POD> -- nslookup db-headless
```

Instead of returning a single IP, it will return **multiple A records** — one for each Pod matched by the selector.

**Your Task:**

1. Apply the manifest.
2. Run `kubectl get svc db-headless` and confirm `CLUSTER-IP` is `None`.
3. Exec into a Pod and run `nslookup db-headless`.

**Paste the `nslookup` output showing multiple Pod IPs.**
(You should see individual Pod IPs like `10.244.0.5`, `10.244.0.6`, etc.)
