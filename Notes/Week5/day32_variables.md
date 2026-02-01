**Week 5, Day 32: Variables (Reusability)**

**The Scenario:** Hardcoding values (like `8080` or `"tutorial"`) makes your code rigid. If you want to deploy a second environment (Staging), you have to copy-paste the whole file. Bad idea. We use **Variables** so the same code can deploy different things.

---

**Day 32 Mission: The Parameterized Build**

**1. Create** `variables.tf` Create a new file named `variables.tf` in the same folder. This is where we declare "inputs".

```Terraform
variable "container_name" {
  description = "Value of the name for the Docker container"
  type        = string
  default     = "tutorial_v2"
}

variable "internal_port" {
  description = "The port the app listens on internally"
  type        = number
  default     = 80
}
```

**2. Update** `main.tf` Modify your `main.tf` to use these variables instead of hardcoded strings.

- Syntax: `var.variable_name`

```Terraform
resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  # USE THE VARIABLE HERE:
  name  = var.container_name
  ports {
    internal = var.internal_port
    external = 8080
  }
}
```

**3. The Override** We can now change the infrastructure without touching the code. We pass the value at runtime. Run:

```Bash
terraform apply -var="container_name=custom_app_prod"
```

**Your Task:**

1. Run the command above.
2. Type `yes` to confirm.
3. Run `docker ps`.

**What is the NAME of the container now running?**

**Answer:** `custom_app_prod`
