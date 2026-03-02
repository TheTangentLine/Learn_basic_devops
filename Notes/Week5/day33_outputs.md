**Week 5, Day 33: Outputs (The Receipt)**

**The Scenario:** sTerraform creates a bunch of stuff (IP addresses, Instance IDs, DNS names). You usually don't know these values until after the creation finishes. You need Terraform to print these values out so your other scripts (or your human eyes) can use them.

---

**Day 33 Mission: Reporting Back**

**1. Create** `outputs.tf` Create this file in the same folder.

```Terraform
output "container_id" {
    description = "ID of the Docker container"
    value = docker_container.nginx.id
}

output "image_id" {
    description = "ID of the Docker image"
    value = docker_image.nginx.id
}
```

**2. Apply to see Output** You don't need to change infrastructure to see outputs, but you must run apply (or refresh) to update the state. Run:

```bash

terraform apply -auto-approve
(Note: -auto-approve skips the "type yes" prompt. Use carefully!)
```

**3. The Result** At the very bottom of the terminal, you will see a green section called Outputs.

**Your Task:** Paste the first 4 characters of the container_id printed in your terminal (e.g., a1b2).
