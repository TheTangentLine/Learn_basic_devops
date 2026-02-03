**Week 5, Day 35: The Weekly Challenge (The Full Stack)**

**The Scenario:** You are the Lead Cloud Engineer. The team needs a development stack consisting of a **Database (Redis)** and a **Backend Application**. They must communicate over a private network. You must use Terraform to provision this state.

**Your Mission:** Create a single `main.tf` file that sets up the entire environment.

**Requirements**

1. **Provider:** Docker.
2. **Resource 1:** The Network
   - Type: `docker_network`
   - Name: `dev_network`
3. **Resource 2:** The Database
   - Image: `redis:alpine`
   - Container Name: `my_redis`
   - Network: Connect to `dev_network`.

4. **Resource 3: The App**
   - Image: `python:3.9-slim`
   - Container Name: `my_app`
   - Command: `["python3", "-m", "http.server", "5000"]` (Simulating a running app)
   - Network: Connect to `dev_network`.
   - **Dependency:** This container should not start until the Redis container is ready (Use `depends_on`).

**Execute the mission.** Write the `main.tf` file. _Hint: To attach a network in Terraform, you use the `networks_advanced` block inside the `docker_container` resource._

```Terraform
networks_advanced {
    name = docker_network.dev_network.name
}
```

Paste your full `main.tf` code here.
