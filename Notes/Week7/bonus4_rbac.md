**RBAC (The Permission System)**

**The Scenario:** In bonus2, we created a ServiceAccount — an identity badge for a Pod. But the badge alone doesn't grant any power. We need a **permission slip** that says exactly what the badge holder is allowed to do. That's **RBAC** (Role-Based Access Control). It works as a chain: **ServiceAccount** (who you are) -> **Role** (what's allowed) -> **RoleBinding** (connects who to what).

---

**Mission: The Least-Privilege Test**

**1. The ServiceAccount (`rbac-demo.yaml`)**

First, create the identity. This is the badge a Pod will wear.

```YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: readonly-sa
  namespace: default
```

**2. The Role**

A Role defines **what actions** (verbs) are allowed on **which resources**, scoped to a single namespace.

```YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
- apiGroups: [""]         # "" = core API group (pods, services, secrets, etc.)
  resources: ["pods"]     # Which resource type
  verbs: ["get", "list"]  # What actions are allowed (NOT create, delete, update)
```

Common verbs: `get`, `list`, `watch`, `create`, `update`, `patch`, `delete`.
Common apiGroups: `""` (core), `"apps"` (deployments), `"networking.k8s.io"` (ingress).

**3. The RoleBinding**

This is the glue. It says: "The ServiceAccount `readonly-sa` is granted the permissions defined in the Role `pod-reader`."

```YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods-binding
  namespace: default
subjects:
- kind: ServiceAccount
  name: readonly-sa
  namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

**4. ClusterRole & ClusterRoleBinding**

A **Role** is namespace-scoped. A **ClusterRole** is cluster-wide — it works across all namespaces and also covers non-namespaced resources (like nodes).

```YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-reader
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-nodes-binding
subjects:
- kind: ServiceAccount
  name: readonly-sa
  namespace: default
roleRef:
  kind: ClusterRole
  name: node-reader
  apiGroup: rbac.authorization.k8s.io
```

**5. Apply Everything**

```Bash
kubectl apply -f rbac-demo.yaml
```

**6. The Permission Test**

Use `kubectl auth can-i` to check permissions without running anything dangerous:

```Bash
# Can this ServiceAccount list pods?
kubectl auth can-i list pods --as=system:serviceaccount:default:readonly-sa
# Expected: yes

# Can this ServiceAccount delete pods?
kubectl auth can-i delete pods --as=system:serviceaccount:default:readonly-sa
# Expected: no
```

**Your Task:**

1. Apply all four manifests (ServiceAccount, Role, RoleBinding, ClusterRole + ClusterRoleBinding).
2. Run both `kubectl auth can-i` commands above.

**Paste the output showing `yes` for list and `no` for delete.**

The RBAC chain:
```
ServiceAccount (who) --[RoleBinding]--> Role (what + where)
ServiceAccount (who) --[ClusterRoleBinding]--> ClusterRole (what, everywhere)
```
