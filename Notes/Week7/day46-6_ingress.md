**Week 7, Day 46-6: Ingress (The Smart Receptionist)**

**The Scenario:** You have multiple Services inside your cluster — a frontend, a backend API, maybe an admin panel. You could create a LoadBalancer for each one, but that means paying for multiple public IPs. Instead, you put **one** Ingress in front of everything. It acts like a smart receptionist: it looks at the incoming URL and routes `/api` to the backend Service, `/admin` to the admin Service, and `/` to the frontend Service — all through a single public entry point.

---

**Day 46-6 Mission: The URL Router**

**1. Enable the Ingress Controller (Minikube)**
Ingress is just a set of routing rules. It needs an **Ingress Controller** (like NGINX) to actually execute them. On Minikube:

```Bash
minikube addons enable ingress
```

Wait for it to spin up:

```Bash
kubectl get pods -n ingress-nginx
```

**2. The Manifest (`ingress.yaml`)**
Create `ingress.yaml`. This routes traffic based on the URL path.

```YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: myapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 80
```

**3. Apply**

```Bash
kubectl apply -f ingress.yaml
```

**4. The Local DNS Trick**
Since we're on Minikube, we need to map `myapp.local` to the Minikube IP:

```Bash
echo "$(minikube ip) myapp.local" | sudo tee -a /etc/hosts
```

**5. Test It**

```Bash
curl http://myapp.local/
curl http://myapp.local/api
```

**Your Task:**

1. Enable the ingress addon and wait for the controller pods to be `Running`.
2. Apply the Ingress manifest.
3. Run `kubectl get ingress`.

**Paste the output of `kubectl get ingress`.**
(It should show `app-ingress` with the host `myapp.local` and the Minikube IP under `ADDRESS`).
