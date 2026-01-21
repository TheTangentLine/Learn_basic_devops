**Week 3, Day 15: Dockerfiles Deep Dive**

**The Scenario:** You know `docker run`. That's just consuming software. Now you need to package software. A bad Dockerfile runs as `root` (insecure) and is 1GB large (slow). A good one runs as a `user` and is 50MB.

**Key Instructions:**

- `FROM`: The base OS (e.g., `node:18`, `python:3.9-slim`).
- `WORKDIR`: `cd` inside the container. Always use this.
- `COPY`: copy files from laptop -> container.
- `RUN`: Run commands during the build (e.g., `npm install`).
- `CMD`: The command that runs when the container starts.

**Day 15 Mission: The Non-Root User**

Running as root inside a container is a security risk. If a hacker breaks out, they have root on your server.

**1. Create a** `Dockerfile` Create a folder `docker-lab`. Inside, create a file named `Dockerfile` (no extension).

**2. The Challenge Content** We want to use `python:3.9-slim`. We want to create a user named `appuser`, and run the app as that user.

Copy this (study the User section):

```dockerfile

# Base Image

FROM python:3.9-slim

# Create a group and user

RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Set working directory

WORKDIR /app

# Copy files

COPY . .

# CHANGE PERMISSIONS (Crucial!)

# We must give the new user ownership of the files

RUN chown -R appuser:appgroup /app

# Switch to the user

USER appuser

# Command to keep container running (for testing)

CMD ["python3", "-c", "import time; print('Running as user...'); time.sleep(100)"]
```

**3. Build & Run**

```bash
docker build -t secure-app .
docker run -d --name my-secure-app secure-app
```

---

**Your Task:** Verify that the process is **NOT** running as root. Run this command: `docker exec my-secure-app whoami`

**Paste the output**. (It should say appuser, not root).
