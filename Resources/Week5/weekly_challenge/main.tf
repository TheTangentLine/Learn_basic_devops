terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

# 1. THE NETWORK (The Foundation)
resource "docker_network" "dev_network" {
  name = "dev_network"
}

# 2. THE DATABASE (Redis)
# First, define the image we need
resource "docker_image" "redis_image" {
  name         = "redis:alpine"
  keep_locally = false
}

# Then, create the container
resource "docker_container" "my_redis" {
  image = docker_image.redis_image.image_id
  name  = "my_redis"
  
  # Attach to the custom network
  networks_advanced {
    name = docker_network.dev_network.name
  }
}

# 3. THE APP (Python)
resource "docker_image" "python_image" {
  name         = "python:3.9-slim"
  keep_locally = false
}

resource "docker_container" "my_app" {
  image = docker_image.python_image.image_id
  name  = "my_app"
  
  # Run a dummy command to keep it alive
  command = ["python3", "-m", "http.server", "5000"]

  # Attach to the SAME network
  networks_advanced {
    name = docker_network.dev_network.name
  }

  # CRITICAL: Wait for Redis to be created first
  depends_on = [
    docker_container.my_redis
  ]
}