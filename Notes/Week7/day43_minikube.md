_Goal: "Docker Compose is great for 1 server. How do I manage 1,000 servers?"_

Kubernetes (K8s) is the industry standard for container orchestration. It is complex, verbose, and powerful.

We will start simple.

**Week 7, Day 43: Minikube (The Playground)**
**The Scenario:** Installing a real Kubernetes cluster is hard.
We will use **Minikube**, which runs a tiny, single-node cluster inside a Docker container on your laptop.

---

**Day 43 Mission: The Cluster Launch**
**1. Install Tools**
You need two things:

1. **kubectl** (The remote control): `brew install kubectl` (or `choco install kubernetes-cli`).
2. **minikube** (The cluster): `brew install minikube` (or `choco install minikube`).

**2. Start the Engines**
Run this command to create the cluster (it uses your Docker Desktop as the driver):

```Bash
minikube start --driver=docker
```

_Wait 1-2 minutes._

**3. The Checkup**
Verify your "nodes" (servers).

```Bash
kubectl get nodes
```

**Your Task:**
Run `kubectl get nodes`.
**Paste the status of your node (e.g., `Ready`).**
