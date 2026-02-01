**Week 5, Day 34: Modules (The Lego Bricks)**

**The Scenario:** Your `main.tf` is getting messy. You have 500 lines of code. In programming, we use Functions or Classes to organize code. In Terraform, we use Modules. You write a standard "Web Server" module once, and then reuse it 10 times.

---

**Day 34 Mission: Refactoring**

**1. The Folder Structure**
We will move our existing work into a module folder.

```bash
mkdir -p modules/webserver
mv main.tf variables.tf outputs.tf modules/webserver/
(Your root folder tf-lab should now be empty except for the modules folder and .terraform stuff).
```

**2. The New Root** `main.tf`
Create a new `main.tf` in your root folder tf-lab. This file will "call" the module.

```Terraform

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

# CALL THE MODULE
module "my_webserver" {
  source = "./modules/webserver"

  # Pass variables to the module
  container_name = "modular_nginx"
  internal_port  = 80
}
```

**3. Init and Apply**
Because we moved files, Terraform gets confused. We need to re-initialize.

```bash
terraform init
terraform apply -auto-approve
```

**Your Task:**

1. Run the commands.
2. Run docker ps.
   You should see a container named modular_nginx.

**Question:** If you wanted to create a second web server listening on port 9090 (assuming you expose the external port as a variable in the module too), what code would you add to your root main.tf?
