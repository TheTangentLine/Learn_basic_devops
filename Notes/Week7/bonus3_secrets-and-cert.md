**Secrets & Certificates (The Vault)**

**The Scenario:** To use our IAM generated token from Day 50, the database demands a secure mTLS/SSL connection. This means our Node.js app needs the AWS RDS `.pem` root certificate file. We never bake certificates or passwords directly into our Docker images. Instead, we store the `.pem` file in a Kubernetes Secret and instruct Kubernetes to securely mount that secret as a physical file inside the Pod when it boots up.

---

**Day 52 Mission: The Vault Mount Test**

**1. The Manifest (`pod-with-secret.yaml`)**

Assume we already ran `kubectl create secret generic rds-cert-secret --from-file=global-bundle.pem` to store the certificate in the cluster. Now, we need to attach that vault to our Pod.

Create `pod-with-secret.yaml`:

```YAML
apiVersion: v1
kind: Pod
metadata:
  name: secure-db-app
spec:
  serviceAccountName: db-access-sa # Our IAM badge from Day 51
  containers:
  - name: app
    image: alpine:latest # Using Alpine linux just to test the file system
    command: ["sleep", "3600"]
    # THE MAGIC MOUNT: Tell the container where to put the files
    volumeMounts:
    - name: pem-vault
      mountPath: "/app/certs"
      readOnly: true
  # THE VAULT CONNECTION: Tell the Pod which Secret to grab
  volumes:
  - name: pem-vault
    secret:
      secretName: rds-cert-secret
```

**2. The Apply**

```Bash
kubectl apply -f pod-with-secret.yaml
```

**3. The Inspection Test**

1. Run `kubectl get pods` and wait for `secure-db-app` to show as `Running`.

2. We are going to "hack" into our own running container to see if the file is actually there. We will use the `exec` command to run `ls` inside the Pod.

3. Run: `kubectl exec secure-db-app -- ls -l /app/certs`

**Your Task:**

Look at the output from the `exec` command.
**Is the certificate file sitting in the directory?** (Notice how the Node.js application can now use fs.`readFileSync('/app/certs/global-bundle.pem')` just like a normal local file!).

**Paste the output showing the mounted file.**

**Output:**

```Plaintext
total 4
lrwxrwxrwx    1 root     root            24 Mar 12 12:00 global-bundle.pem -> ..data/global-bundle.pem
```
