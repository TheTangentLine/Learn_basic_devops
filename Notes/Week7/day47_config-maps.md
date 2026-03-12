**Week 7, Day 47: ConfigMaps (Environment Injection)**

**The Scenario:** You shouldn't hardcode configurations (like a database URL) inside your container image. Just like in Docker, we need to inject them. In Kubernetes, we use a **ConfigMap.**

**Day 47 Mission: The Dynamic App**

**1. Create the ConfigMap**
Instead of a YAML file, we'll create this one from the command line for speed.

```Bash
kubectl create configmap app-config --from-literal=APP_COLOR=blue
```

**2. Update the Deployment**
We need to tell the Pods to read from this ConfigMap and turn it into an Environment Variable.
Edit your `deployment.yaml` and add the `env` section inside the container spec:

```YAML
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        env:
          - name: THE_COLOR
            valueFrom:
              configMapKeyRef:
                name: app-config
                key: APP_COLOR
```

**3. Update & Verify**

```Bash
kubectl apply -f deployment.yaml
# Pick a pod and check its environment
kubectl exec <POD_NAME> -- env | grep THE_COLOR
```

**Your Task:**
Run the `kubectl exec` command above.
**What is the output?**
