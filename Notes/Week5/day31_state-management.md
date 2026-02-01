**Week 5, Day 31: State Management (The Brain)**

**The Scenario:** How does Terraform know that the container already exists? It creates a file called `terraform.tfstate`. This is its memory. If you delete this file, Terraform gets amnesia and will try to create a duplicate container (which will fail because the name is taken).

**The Power:** If you change your code, Terraform compares **Code vs. State** and figures out the minimal change needed.

---

**Day 31 Mission: The Modification**
We decide that Port 8000 is occupied. We need to move the app to **Port 8080**.

**1. Edit the Code** Open `main.tf`. Change the `external` port number:

```Terraform
resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "tutorial"
  ports {
    internal = 80
    external = 8080 # CHANGED from 8000 to 8080
  }
}
```

**2. The Plan** Run `terraform plan`. Terraform is smart. It knows it cannot just "change" a port on a running container. It must **destroy** the old one and **create** a new one.

**Your Task:** Run `terraform plan`. Look for the line containing the `~` symbol (which means "update/modify") or `-/+` (destroy and recreate).

**Paste the specific line that shows the port changing**. (It usually looks like: `external = 8000 -> 8080`).
