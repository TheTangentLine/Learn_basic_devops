**Pod Identities (The VIP Badge)**

**The Scenario:** In a Kubernetes cluster (like EKS), multiple Pods share the same underlying EC2 Worker Node. If we give the EC2 node an IAM Role with database access, every Pod on that machine gets access. That is dangerous. Instead, we create a **ServiceAccount**. We tell Kubernetes: "Create an identity badge. Only the Pods wearing this specific badge are allowed to assume the AWS IAM Role."

---

**Day 51 Mission: The Badge Assignment Test**

**1. The Manifests (`db-pod.yaml`)**

We will create the ServiceAccount (the badge) and the Pod (the worker), and link them together.

Create `db-pod.yaml`:

```YAML
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: db-access-sa
  # In EKS, this annotation links the K8s badge to the AWS IAM Role!
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/app-db-role

---
apiVersion: v1
kind: Pod
metadata:
  name: secure-db-app
spec:
  serviceAccountName: db-access-sa # THE MAGIC LINK: The Pod puts on the badge
  containers:
  - name: app
    image: my-node-app:latest
```

**2. The Apply**

```Bash
kubectl apply -f db-pod.yaml
```

**3. The Inspection Test**

1. Run `kubectl get pods` to ensure `secure-db-app` is running.
2. We need to prove the Pod actually "put on" the badge. We will inspect the running Pod's details.
3. Run: `kubectl get pod secure-db-app -o yaml | grep serviceAccountName`

**Your Task:**

Look at the output from the inspection command.
**What ServiceAccount is the Pod currently using**? (If you don't specify one, it defaults to `default`, which has no permissions).

**Paste the output showing the attached ServiceAccount.**
Would you like me to show you how to securely inject `.pem` certificates into this Pod using a Kubernetes Secret next?

**Output:**

```Plaintext
  serviceAccountName: db-access-sa
```
