**Week 7, Day 46 Summary: Kubernetes Services at a Glance**

---

## Service Types Comparison

| Type | Scope | Use Case | Gets External IP? | Key Config |
|------|-------|----------|-------------------|------------|
| **ClusterIP** | Internal only | Pod-to-Pod communication (e.g., frontend -> backend) | No | `type: ClusterIP` (default) |
| **NodePort** | External via Node IP | Dev/testing, exposing on a static port (30000-32767) | No (uses Node IP + port) | `type: NodePort` |
| **LoadBalancer** | External via cloud LB | Production public-facing services on AWS/GCP/Azure | Yes (cloud-provisioned IP or URL) | `type: LoadBalancer` |
| **ExternalName** | DNS alias | Mapping an internal name to an external hostname (e.g., RDS) | No (just a CNAME) | `type: ExternalName` + `externalName: ...` |
| **Headless** | Internal, per-Pod DNS | StatefulSets needing individual Pod addresses | No | `clusterIP: None` |
| **Ingress** | External HTTP/HTTPS | Path/host-based routing to multiple Services via one entry point | Yes (via Ingress Controller + LB) | `kind: Ingress` + rules |

---

## How They Connect

```
Internet
   │
   ▼
LoadBalancer  ──▶  Provisions a cloud LB (public IP)
   │
   ▼
Ingress  ──▶  Routes by host/path (myapp.com/api -> backend, / -> frontend)
   │
   ├──▶  ClusterIP (frontend-service)  ──▶  Frontend Pods
   │
   ├──▶  ClusterIP (backend-service)   ──▶  Backend Pods
   │
   └──▶  Headless (db-headless)        ──▶  Individual DB Pods (postgres-0, postgres-1)

ExternalName (external-db)  ──▶  DNS redirect to my-db.us-east-1.rds.amazonaws.com
```

---

## Quick Reference

- **Default type?** ClusterIP — if you omit `type`, you get ClusterIP.
- **Cheapest external access?** NodePort — no cloud cost, but limited port range.
- **Production external access?** LoadBalancer + Ingress — one LB, smart routing.
- **Talking to outside services?** ExternalName — clean DNS alias, no hardcoding.
- **StatefulSet databases?** Headless — each Pod gets its own DNS name.
