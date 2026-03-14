**Week 7, Day 49: Namespaces (The Apartment Complex)**

**The Scenario:** You are working on two projects: `Project-A` and `Project-B`. If you put everything in the same space, the names will clash (you can't have two services named `web-service`).
**Namespaces** allow you to slice your single cluster into multiple virtual clusters.

---

**Day 49 Mission: The Great Divide**

**1. Create the Namespaces**

```Bash
kubectl create namespace dev
kubectl create namespace prod
```

**2. Deploy to a Specific Space**

You can use the `-n` flag to tell Kubernetes where to put your resources.

```Bash
kubectl apply -f deployment.yaml -n dev
```

**3. The Visibility Test**
If you run `kubectl get pods`, you will see nothing! This is because `kubectl` looks at the `default` namespace unless you tell it otherwise.

**Your Task:**

1. Run `kubectl get pods`. (Should be empty or show old pods).
2. Run `kubectl get pods -n dev`.
3. **What is the status of the pod in the `dev` namespace?**
