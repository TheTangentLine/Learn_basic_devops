**Week 7, Day 44: The Pod (The Atom)**

**The Scenario:** In Docker, the smallest unit is a **Container**.
In Kubernetes, the smallest unit is a **Pod**.
A Pod is a wrapper that holds one (or sometimes more) containers. Think of it as a "Peapod" holding the peas (containers). You cannot run a container directly in K8s; you must wrap it in a Pod.

---

**Day 44 Mission: The First Deployment**
**1. The Manifest (`pod.yaml`)**
Kubernetes speaks YAML. We don't usually use command-line flags (like `docker run -p...`). We describe the state we want in a file.

Create a file named `pod.yaml`:

```YAML
apiVersion: v1
kind: Pod
metadata:
  name: my-first-pod
  labels:
    app: nginx
spec:
  containers:
    - name: nginx-container
      image: nginx:alpine
      ports:
        - containerPort: 80
```

**2. The Apply**
Send this manifest to the cluster API.

```Bash
kubectl apply -f pod.yaml
```

**3. The Status**
Watch it get created.

```Bash
kubectl get pods
```

**Your Task:**

1. Run the apply command.

2. Run `kubectl get pods`.

3. Wait until the **STATUS** changes from `ContainerCreating` to `Running`.

**Paste the output of `kubectl get pods` showing the "Running" status.**

_(Next Step: A Pod is mortal. If it dies, it stays dead. We need something to bring it back to life...)_

**Output:**

```Plaintext
NAME           READY   STATUS    RESTARTS   AGE
my-first-pod   1/1     Running   0          12s
```
