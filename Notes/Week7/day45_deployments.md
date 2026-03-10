**Week 7, Day 45: Deployments (The Guardian)**

**The Scenario:** A Pod is fragile. If you manually delete it or if it crashes, it's gone. In production, we need **High Availability**.
We use a **Deployment**. A Deployment is a manager. You tell it: "I want 3 copies of this app running at all times." If one Pod dies, the Deployment notices and instantly spawns a new one to replace it.

---

**Day 45 Mission: The Immortality Test**

**1. The Manifest (`deployment.yaml`)**

Delete your old Pod first: `kubectl delete pod my-first-pod`.
Now create `deployment.yaml`:

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3 # THE MAGIC NUMBER: Always keep 3 running
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
```

**2. The Apply**

```Bash
kubectl apply -f deployment.yaml
```

**3. The Chaos Test**

1. Run `kubectl get pods`. You should see 3 Pods.
2. Pick one and kill it: `kubectl delete pod <POD_NAME>`
3. Immediately run `kubectl get pods` again.

**Your Task:**

Look at the output after the deletion.
**How many Pods are currently in the list?** (Look at the "AGE" column—one should be much younger than the others).

**Paste the output showing the "young" replacement Pod.**
Would you like me to show you how to scale these 3 Pods to 10 with a single command next?

**Output:**

```Plaintext
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-7c989d-abc1        1/1     Running   0          2m   # Old
nginx-deployment-7c989d-def2        1/1     Running   0          2m   # Old
nginx-deployment-7c989d-xyz3        1/1     Running   0          4s   # The New Replacement
```
