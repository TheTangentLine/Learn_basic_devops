**Week 7, Day 48: Secrets (The Vault)**

**The Scenario:** ConfigMaps are for public data (like theme colors or UI labels). They are stored in plain text. You **never** put passwords, API keys, or database credentials in a ConfigMap.
For those, we use **Secrets**. Kubernetes encodes Secrets (Base64) and, in many production environments, encrypts them at rest.

---

**Day 48 Mission: The Locked Door**
We will create a Secret for a "DB Password" and mount it as a file inside the Pod. Mounting secrets as files is often considered more secure than environment variables because environment variables can sometimes leak into logs.

**1. Create the Secret**
Run this in your terminal:

```Bash
kubectl create secret generic db-user-pass --from-literal=password='SuperSecret123'
```

**2. Update the Deployment (`deployment.yaml`)**
We will now "mount" this secret as a volume. This makes the secret appear as a text file inside the container at `/etc/secrets/password`.

Overwrite your `deployment.yaml` with this:

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
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
        volumeMounts:
        - name: secret-volume
          mountPath: "/etc/secrets"
          readOnly: true
      volumes:
      - name: secret-volume
        secret:
          secretName: db-user-pass
```

**3. Apply and Verify**

```Bash
kubectl apply -f deployment.yaml
# Wait for the pod to restart, then read the file inside it
kubectl exec $(kubectl get pod -l app=web -o name) -- cat /etc/secrets/password
```

**Your Task:**
Run the `kubectl exec` command above.
**What text is printed in your terminal?**
