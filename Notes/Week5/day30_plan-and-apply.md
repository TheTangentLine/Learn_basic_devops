**Week 5, Day 30: Plan & Apply (The Magic Button)**

**The Scenario:** You have defined the infrastructure in a file (`main.tf`), but nothing exists yet. Terraform has a two-step safety mechanism:

1. **Plan**: "Here is what I would do if you let me." (Read-only).
2. **Apply**: "Okay, I'm doing it." (Write).

---

**Day 30 Mission: Spawning Infrastructure**

**1. The Dry Run (`plan`)** This compares your code against reality. Since reality is "empty", it will propose creating everything. Run:

```Bash
terraform plan
```

_Look at the output_. You will see `+` signs (green) next to `docker_container.nginx`. This means "Create". At the bottom, it should say: **Plan: 2 to add, 0 to change, 0 to destroy**.

**2. The Execution (`apply`)** Now we commit. Run:

```Bash
terraform apply
```

- It will show the plan again and pause.
- It asks: `Do you want to perform these actions?`
- Type `yes` and hit Enter.

**3. Verification** Terraform says "Apply complete!". Let's check if it's lying. Run:

```Bash
docker ps
```

**Your Task:**

1. Run the commands above.
2. Look at the `docker ps` output.
3. What specific port on your localhost is mapped to the container? (e.g., `0.0.0.0:???? -> 80/tcp`).

**Answer:** `8000`
