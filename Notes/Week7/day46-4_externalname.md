**Week 7, Day 46-4: ExternalName (The Redirect Sign)**

**The Scenario:** Your app running inside Kubernetes needs to talk to an **external** managed database (like AWS RDS or a third-party API). You don't want to hardcode `my-db.us-east-1.rds.amazonaws.com` into every Pod. Instead, you create an **ExternalName** Service — a simple DNS alias. Pods call `external-db` and Kubernetes resolves it to the real external hostname. No proxying, no ClusterIP — just a CNAME redirect.

---

**Day 46-4 Mission: The DNS Alias**

**1. The Manifest (`externalname-service.yaml`)**
Create `externalname-service.yaml`. This creates a DNS shortcut inside the cluster.

```YAML
apiVersion: v1
kind: Service
metadata:
  name: external-db
spec:
  type: ExternalName
  externalName: my-db.us-east-1.rds.amazonaws.com
```

Notice: **no selector, no ports, no ClusterIP.** This Service doesn't route traffic — it just answers DNS queries with a CNAME record.

**2. Apply**

```Bash
kubectl apply -f externalname-service.yaml
```

**3. Verify the DNS Alias**

```Bash
kubectl get svc external-db
```

You'll see `TYPE` is `ExternalName`, `CLUSTER-IP` is empty, and `EXTERNAL-IP` shows the target hostname.

**4. Test Resolution**

```Bash
kubectl exec <ANY_POD> -- nslookup external-db
```

**Your Task:**

1. Apply the manifest.
2. Run `kubectl get svc external-db`.
3. Exec into a Pod and run `nslookup external-db`.

**Paste the output of `kubectl get svc` for `external-db`.**
(It should show `TYPE: ExternalName` and the external hostname under `EXTERNAL-IP`).
