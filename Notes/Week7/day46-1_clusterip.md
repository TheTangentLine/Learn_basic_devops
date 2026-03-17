**Week 7, Day 46-1: ClusterIP (The Internal Hotline)**

**The Scenario:** You have a frontend app and a backend API, both running as Pods inside the cluster. The frontend needs to talk to the backend, but Pod IPs change every time they restart. You need a **stable internal address** that never changes. That's a **ClusterIP** Service — the default Service type. It creates a virtual IP that is only reachable from **inside** the cluster.

---

**Day 46-1 Mission: Wire Up the Backend**

**1. The Manifest (`clusterip-service.yaml`)**
Create `clusterip-service.yaml`. This gives your backend Pods a stable internal address that any other Pod in the cluster can call.

```YAML
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  selector:
    app: backend
  ports:
    - protocol: TCP
      port: 80         # Port other Pods will call
      targetPort: 5000  # Port your backend container listens on
  type: ClusterIP       # Default — can be omitted entirely
```

**2. Apply**

```Bash
kubectl apply -f clusterip-service.yaml
```

**3. Test Internal DNS**
Kubernetes automatically creates a DNS entry: `backend-service.<namespace>.svc.cluster.local`. From any other Pod in the same namespace, you can simply use `backend-service`.

```Bash
# Exec into any running pod and curl the backend
kubectl exec <FRONTEND_POD_NAME> -- curl http://backend-service:80
```

**Your Task:**

1. Apply the manifest.
2. Run `kubectl get svc` and confirm the `TYPE` column says `ClusterIP`.
3. Exec into another Pod and `curl http://backend-service:80`.

**Paste the output of `kubectl get svc` showing `backend-service`.**
(It should show a `CLUSTER-IP` like `10.96.x.x` and `EXTERNAL-IP` as `<none>`).
