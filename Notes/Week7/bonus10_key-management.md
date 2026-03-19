**Key Management (The Locksmith)**

**The Scenario:** Your cluster handles many types of sensitive keys: TLS certificates for HTTPS, SSH keys for pulling private Git repos, API keys for third-party services, and encryption keys that protect your Secrets at rest. Each type has a different workflow, a different Kubernetes Secret type, and different best practices. This is the comprehensive guide to managing all of them.

---

**Mission: The Full Key Lifecycle**

## Part 1: TLS/SSL Certificates (HTTPS Termination)

**The problem:** Your app needs HTTPS. You need a TLS certificate (public) and a private key. Kubernetes has a dedicated Secret type for this.

**1a. Create a TLS Secret manually:**

```Bash
# Generate a self-signed cert for testing
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt -subj "/CN=myapp.local"

# Store it in Kubernetes
kubectl create secret tls myapp-tls \
  --cert=tls.crt \
  --key=tls.key
```

The Secret contains two keys: `tls.crt` (the certificate) and `tls.key` (the private key).

**1b. Use it in a Gateway for HTTPS termination:**

```YAML
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: secure-gateway
spec:
  gatewayClassName: nginx
  listeners:
  - name: https
    protocol: HTTPS
    port: 443
    tls:
      mode: Terminate                # Gateway handles TLS, backends get plain HTTP
      certificateRefs:
      - kind: Secret
        name: myapp-tls              # References our TLS Secret
    allowedRoutes:
      namespaces:
        from: All
```

**1c. cert-manager (Auto-Provisioning with Let's Encrypt):**

In production, you don't manage certificates manually. **cert-manager** watches for Certificate resources and automatically provisions and renews TLS certs from Let's Encrypt.

```Bash
# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.1/cert-manager.yaml
```

```YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@example.com
    privateKeySecretRef:
      name: letsencrypt-prod-key
    solvers:
    - http01:
        gatewayHTTPRoute:
          parentRefs:
          - name: main-gateway

---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: myapp-cert
spec:
  secretName: myapp-tls-auto          # cert-manager creates this Secret automatically
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
  - myapp.example.com
```

cert-manager automatically renews the cert before it expires. No manual intervention needed.

---

## Part 2: SSH Keys (Private Git Repos)

**The problem:** Your container needs to clone a private Git repository at startup (e.g., a config repo or a sidecar pulling code). You need to inject an SSH deploy key.

**2a. Create the SSH Secret:**

```Bash
kubectl create secret generic git-ssh-key \
  --from-file=ssh-privatekey=~/.ssh/deploy_key \
  --type=kubernetes.io/ssh-auth
```

**2b. Mount it into the Pod:**

```YAML
spec:
  containers:
  - name: app
    image: alpine/git
    command: ["git", "clone", "git@github.com:org/repo.git", "/app"]
    volumeMounts:
    - name: ssh-key
      mountPath: /root/.ssh
      readOnly: true
  volumes:
  - name: ssh-key
    secret:
      secretName: git-ssh-key
      defaultMode: 0400              # SSH requires strict permissions (read-only by owner)
```

`defaultMode: 0400` is critical — SSH refuses to use a key file with loose permissions.

---

## Part 3: API Keys and Tokens (Third-Party Services)

**The problem:** Your app calls Stripe, Twilio, SendGrid, or any external API that requires a secret key.

**3a. Store the API key:**

```Bash
kubectl create secret generic stripe-api-key \
  --from-literal=STRIPE_SECRET_KEY='sk_live_abc123...'
```

**3b. Inject as environment variable (quick but less secure):**

```YAML
env:
- name: STRIPE_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: stripe-api-key
      key: STRIPE_SECRET_KEY
```

**3c. Inject as file (more secure — avoids env var leaks in logs/crash dumps):**

```YAML
volumeMounts:
- name: api-keys
  mountPath: /etc/secrets/stripe
  readOnly: true
volumes:
- name: api-keys
  secret:
    secretName: stripe-api-key
# App reads: fs.readFileSync('/etc/secrets/stripe/STRIPE_SECRET_KEY', 'utf8').trim()
```

---

## Part 4: Encryption at Rest (Protecting Secrets in etcd)

**The problem:** By default, Kubernetes Secrets are only Base64-encoded in etcd — **not encrypted**. Anyone with access to etcd can decode them. In production, you must enable encryption at rest.

**4a. Kubernetes EncryptionConfiguration:**

On self-managed clusters, you create an encryption config file for the API server:

```YAML
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
- resources:
  - secrets
  providers:
  - aescbc:
      keys:
      - name: key1
        secret: <base64-encoded-32-byte-key>    # openssl rand -base64 32
  - identity: {}   # Fallback: read unencrypted secrets that existed before encryption
```

The API server flag: `--encryption-provider-config=/etc/kubernetes/encryption-config.yaml`

**4b. Cloud KMS Integration (AWS/GCP):**

On managed clusters, you delegate encryption to a cloud Key Management Service:

- **AWS EKS:** Enable envelope encryption with AWS KMS. EKS encrypts each Secret with a unique data encryption key (DEK), and the DEK is encrypted with your KMS master key.
- **GCP GKE:** Enable application-layer encryption with Cloud KMS in the cluster settings.

```Bash
# AWS EKS: Enable KMS encryption
aws eks associate-encryption-config \
  --cluster-name my-cluster \
  --encryption-config '[{"resources":["secrets"],"provider":{"keyArn":"arn:aws:kms:us-east-1:123456789:key/abc-123"}}]'
```

---

## Part 5: Sealed Secrets (GitOps-Safe Secrets)

**The problem:** You want to store your Kubernetes manifests in Git (GitOps), but you can't commit plain Secrets — they're just Base64-encoded. **Sealed Secrets** by Bitnami encrypts Secrets so they can only be decrypted by the controller running in your cluster.

**5a. Install:**

```Bash
# Install the controller in the cluster
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.27.3/controller.yaml

# Install the CLI tool
brew install kubeseal
```

**5b. Seal a Secret:**

```Bash
# Create a normal Secret manifest (don't apply it!)
kubectl create secret generic db-password \
  --from-literal=password='SuperSecret123' \
  --dry-run=client -o yaml > secret.yaml

# Encrypt it with kubeseal
kubeseal --format=yaml < secret.yaml > sealed-secret.yaml

# sealed-secret.yaml is safe to commit to Git!
cat sealed-secret.yaml
```

**5c. The SealedSecret manifest looks like:**

```YAML
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: db-password
spec:
  encryptedData:
    password: AgBf7G3x...   # Encrypted — only your cluster's controller can decrypt this
```

**5d. Apply it:**

```Bash
kubectl apply -f sealed-secret.yaml
# The controller decrypts it and creates a regular Secret automatically
kubectl get secrets   # db-password appears as a normal Secret
```

**Workflow:**
```
Developer creates Secret YAML
    │
    ▼
kubeseal encrypts it → SealedSecret YAML
    │
    ▼
Commit to Git safely
    │
    ▼
GitOps tool (ArgoCD/Flux) applies SealedSecret to cluster
    │
    ▼
Sealed Secrets controller decrypts → creates real Secret
```

---

**Your Task:**

1. Create a TLS Secret using `openssl` and `kubectl create secret tls`.
2. Run `kubectl get secret myapp-tls -o yaml` and confirm it has `tls.crt` and `tls.key` fields.

**Paste the output showing the TLS Secret with both keys present.**

**Key Management Summary:**

| Key Type | Secret Type | Best Practice |
|----------|-------------|---------------|
| TLS certs | `kubernetes.io/tls` | Use cert-manager for auto-provisioning and renewal |
| SSH keys | `kubernetes.io/ssh-auth` | Mount as file with `defaultMode: 0400` |
| API keys | `Opaque` | Mount as file (not env var) to avoid log leaks |
| Encryption at rest | N/A | Enable KMS on managed clusters (EKS/GKE) |
| GitOps secrets | `SealedSecret` | Use Bitnami Sealed Secrets for safe Git commits |
