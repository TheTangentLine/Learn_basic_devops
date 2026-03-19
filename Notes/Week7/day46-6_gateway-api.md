**Week 7, Day 46-6: Gateway API (The Smart Receptionist)**

**The Scenario:** You have multiple Services inside your cluster — a frontend, a backend API, maybe an admin panel. You could create a LoadBalancer for each one, but that means paying for multiple public IPs. Instead, you put **one** Gateway in front of everything. It looks at the incoming URL and routes `/api` to the backend Service, `/admin` to the admin Service, and `/` to the frontend Service — all through a single public entry point.

> **Why not Ingress?** The old `kind: Ingress` resource and its most popular controller (ingress-nginx) are officially **retiring by March 2026**. The NGINX Ingress Controller had chronic security vulnerabilities, only one or two volunteer maintainers, and couldn't handle modern protocols like gRPC or WebSocket natively. The Kubernetes community built the **Gateway API** as the modern, official replacement.

---

**Day 46-6 Mission: The URL Router**

**The 3-Resource Model:**
The Gateway API splits routing into three layers with clear separation of responsibility:
- **GatewayClass** — "Which controller?" (managed by infra team)
- **Gateway** — "Which ports and protocols do we listen on?" (managed by cluster operators)
- **HTTPRoute** — "Where does each URL go?" (managed by app developers)

**1. Install the Gateway API CRDs**

Gateway API isn't built into Kubernetes by default — you install the definitions first:

```Bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml
```

**2. Install a Gateway Controller**

The Gateway API is just rules — you need a controller to execute them. We'll use **NGINX Gateway Fabric** (the modern successor to NGINX Ingress):

```Bash
kubectl apply -f https://github.com/nginx/nginx-gateway-fabric/releases/download/v1.6.2/nginx-gateway.yaml
```

Wait for it to spin up:

```Bash
kubectl get pods -n nginx-gateway
```

**3. The GatewayClass (`gateway-class.yaml`)**

This tells Kubernetes which controller to use:

```YAML
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx
spec:
  controllerName: gateway.nginx.org/nginx-gateway-controller
```

**4. The Gateway (`gateway.yaml`)**

This creates the actual listener — the entry point that accepts traffic:

```YAML
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: main-gateway
spec:
  gatewayClassName: nginx       # References the GatewayClass above
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
        from: All               # Accept routes from any namespace
```

**5. The HTTPRoute (`http-routes.yaml`)**

This defines the actual routing rules — where each URL path goes:

```YAML
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: app-routes
spec:
  parentRefs:
  - name: main-gateway          # Attach to our Gateway
  hostnames:
  - "myapp.local"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /api
    backendRefs:
    - name: backend-service      # Route /api to backend
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: frontend-service     # Route / to frontend
      port: 80
```

**6. Apply Everything**

```Bash
kubectl apply -f gateway-class.yaml
kubectl apply -f gateway.yaml
kubectl apply -f http-routes.yaml
```

**7. The Local DNS Trick**

Since we're on Minikube, map `myapp.local` to the Minikube IP:

```Bash
echo "$(minikube ip) myapp.local" | sudo tee -a /etc/hosts
```

**8. Test It**

```Bash
curl http://myapp.local/
curl http://myapp.local/api
```

**Your Task:**

1. Install the Gateway API CRDs and NGINX Gateway Fabric.
2. Apply all three manifests (GatewayClass, Gateway, HTTPRoute).
3. Run `kubectl get gateways` and `kubectl get httproutes`.

**Paste the output of `kubectl get gateways` showing `main-gateway` with a programmed status.**

**Why Gateway API > Ingress:**

| Feature | Old Ingress | Gateway API |
|---------|-------------|-------------|
| Protocols | HTTP/HTTPS only | HTTP, HTTPS, TCP, UDP, gRPC |
| Routing | Path and host only | Path, headers, query params, method |
| Traffic splitting | Not supported | Built-in (canary/blue-green) |
| Cross-namespace | No | Yes (secure by default) |
| Role separation | None | GatewayClass / Gateway / Route |
| Status | Retiring March 2026 | Actively developed, GA since K8s 1.29 |
