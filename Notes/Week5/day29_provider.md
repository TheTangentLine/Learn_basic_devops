**Week 5, Day 29: The Provider**

**The Scenario:** Terraform is a tool that talks to Cloud Providers (AWS, Azure, Google, or even local Docker). You describe what you want, and Terraform figures out how to create it.

We don't want to pay for AWS yet, so we will use the Docker Provider. We will use Terraform to manage Docker containers instead of typing `docker run`.

**1. Install Terraform**

- **Mac:** `brew tap hashicorp/tap && brew install hashicorp/tap/terraform`
- **Windows:** `choco install terraform`
- **Linux:** `sudo apt-get install terraform`

**2. The Configuration File** (`main.tf`) Create a folder `tf-lab`. Inside, create `main.tf`. Copy this exactly:

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

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "tutorial"
  ports {
    internal = 80
    external = 8000
  }
}
```

**3. The Initialization** Terraform needs to download the "driver" for Docker. Run:

```Bash
terraform init
```

**Your Task:** Run `terraform init`. **Paste the green success message you see at the bottom.**
