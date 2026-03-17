**Week 7, Day 46-3: LoadBalancer (The Public Phone Number)**

**The Scenario:** Our web works perfectly, but it has no EXTERNAL-IP. The public internet cannot reach it. We need to tell our cloud provider (AWS, Google Cloud, etc.) to provision a massive, physical load balancer outside of our cluster to accept public internet traffic and pipe it in. To do this, we create a Service of type **LoadBalancer**.

---

**Day 46-3 Mission: The Cloud Provisioning Test**

**1. The Manifest (`public-lb-service.yaml`)**

Normally, we point this Load Balancer at an Ingress Controller (our smart receptionist). For this mission, let's create the Load Balancer Service that will act as the front door.

Create `public-lb-service.yaml`:

```YAML
apiVersion: v1
kind: Service
metadata:
  name: public-front-door
spec:
  selector:
    app: ingress-controller # Points to our receptionist pods
  ports:
  - port: 80
    targetPort: 80
  - port: 443
    targetPort: 443
  type: LoadBalancer # THE MAGIC WORD: This literally bills your AWS/GCP account!
```

**2. The Apply**

```Bash
kubectl apply -f public-lb-service.yaml
```

**3. The Cloud Sync Test**

1. Run `kubectl get svc public-front-door`.

2. Look at the `EXTERNAL-IP` column. At first, it will say `<pending>`. This is because Kubernetes is literally talking to AWS via an API, saying: _"Hey, provision a physical Load Balancer for me!"_

3. Run the command again after 2 minutes.

**Your Task:**

Look at the final output.
**What does the EXTERNAL-IP say now?** (In AWS, it will be a long URL pointing to an ELB/ALB. In GCP, it will be a public IPv4 address).

**Paste the output showing the provisioned public endpoint.**

Output:

```Code snippet
NAME                TYPE           CLUSTER-IP      EXTERNAL-IP                                                               PORT(S)                      AGE
public-front-door   LoadBalancer   10.100.55.12    a8b9c0d1e2f3-123456789.us-east-1.elb.amazonaws.com                        80:31234/TCP, 443:32456/TCP  2m
```
