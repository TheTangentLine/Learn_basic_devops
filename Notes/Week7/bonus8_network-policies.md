**Network Policies (The Firewall)**

**The Scenario:** By default, every Pod in Kubernetes can talk to every other Pod — no restrictions. That's a security nightmare. If an attacker compromises your frontend Pod, they can freely reach your database Pods. A **NetworkPolicy** is a firewall rule: you define which Pods are allowed to send traffic **in** (ingress) and **out** (egress) based on labels, namespaces, or IP blocks.

---

**Mission: The Zero-Trust Test**

**1. The Default: Wide Open**

Without any NetworkPolicy, all Pods communicate freely. Let's prove it first, then lock it down.

```Bash
# Create two pods to test connectivity
kubectl run frontend --image=nginx:alpine --labels="role=frontend" --port=80
kubectl run backend --image=nginx:alpine --labels="role=backend" --port=80

# Expose backend so it has a DNS name
kubectl expose pod backend --port=80

# Test: frontend CAN reach backend
kubectl exec frontend -- curl -s --max-time 3 http://backend
# Expected: HTML response (success)
```

**2. The Deny-All Policy (`deny-all.yaml`)**

This policy selects the backend Pod and says: "No ingress traffic allowed from anyone."

```YAML
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-to-backend
spec:
  podSelector:
    matchLabels:
      role: backend       # Applies to pods with this label
  policyTypes:
  - Ingress               # We are restricting INCOMING traffic
  ingress: []             # Empty = deny all ingress
```

**3. Apply and Test the Block**

```Bash
kubectl apply -f deny-all.yaml

# Test: frontend can NO LONGER reach backend
kubectl exec frontend -- curl -s --max-time 3 http://backend
# Expected: timeout (connection blocked)
```

**4. The Allow Rule (`allow-frontend.yaml`)**

Now we selectively open a hole: "Only Pods with label `role: frontend` can reach the backend."

```YAML
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
spec:
  podSelector:
    matchLabels:
      role: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend    # ONLY frontend pods can reach backend
    ports:
    - protocol: TCP
      port: 80              # ONLY on port 80
```

**5. Apply and Test the Allow**

```Bash
kubectl apply -f allow-frontend.yaml

# Test: frontend CAN reach backend again
kubectl exec frontend -- curl -s --max-time 3 http://backend
# Expected: HTML response (success)

# Test: a random pod still CANNOT reach backend
kubectl run attacker --image=nginx:alpine --labels="role=attacker" --restart=Never
kubectl exec attacker -- curl -s --max-time 3 http://backend
# Expected: timeout (blocked — not labeled as frontend)
```

**6. Egress Rules (Bonus)**

You can also control **outgoing** traffic. This policy says: "The backend Pod can only send traffic to Pods labeled `role: database` on port 5432."

```YAML
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-egress
spec:
  podSelector:
    matchLabels:
      role: backend
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          role: database
    ports:
    - protocol: TCP
      port: 5432
  - to:                     # Allow DNS resolution (required or nothing works)
    ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
```

**Your Task:**

1. Create the two test pods and verify they can communicate.
2. Apply `deny-all.yaml` and prove the connection is blocked.
3. Apply `allow-frontend.yaml` and prove only the frontend can reconnect.

**Paste the output showing the curl timeout after deny-all, and the HTML response after allow-frontend.**
