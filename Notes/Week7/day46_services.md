**Week 7, Day 46: Services (The Front Door)**

**The Scenario:** You have 3 Pods, but their IP addresses are internal and change every time a Pod is recreated. How does a user reach your app?
You need a **Service**. A Service is a stable IP and DNS name that sits in front of your Pods and load balances traffic between them.

---

**Day 46 Mission: Expose the App**

**1. The Manifest (`service.yaml`)**
Create `service.yaml`. This "selector" tells the service to look for any Pod with the label `app: web`.

```YAML
apiVersion: v1
kind: Service
metadata:
  name: my-web-service
spec:
  selector:
    app: web
  ports:
    - protocol: TCP
      port: 80         # Port on the Service
      targetPort: 80   # Port on the Pod
  type: NodePort       # Exposes the service on the Node's IP
```

**2. Apply**

```Bash
kubectl apply -f service.yaml
```

**3. The Minikube Shortcut**
Normally, you'd need a Cloud Load Balancer, but since we are on Minikube, we use a helper command to open the tunnel.

```Bash
minikube service my-web-service
```

**Your Task:**

1. Run the command. It should open your browser automatically.
2. In your terminal, `run kubectl get svc`.

**Paste the "PORT(S)" column for `my-web-service`.**
(It should look like `80:3XXXX/TCP`).
