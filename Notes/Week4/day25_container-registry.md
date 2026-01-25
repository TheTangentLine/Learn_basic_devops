**Week 4, Day 25: Container Registry (The Warehouse)**

**The Scenario:** You built the image in the previous step, but that image was on a temporary GitHub runner. When the job finished, the runner was destroyed, and your image was deleted. To save it, we must **Push** it to a Registry (Docker Hub).

**Security Alert:** You cannot put your Docker Hub password in the `yaml` file. If you do, it becomes public, and hackers will steal your account. We must use **GitHub Secrets**.

---

**Day 25 Mission: Shipping the Goods**

**1. Set up Secrets**

1. Go to your GitHub Repo -> **Settings**.
2. On the left sidebar, look for **Secrets and variables -> Actions**.
3. Click **New repository secret**.
4. Add these two secrets:
   - Name: `DOCKER_USERNAME` -> **Value**: Your actual Docker Hub username.
   - Name: `DOCKER_PASSWORD` -> **Value**: Your Docker Hub password (or Access Token).

**2. The Workflow Update** We need to modify the `build-image` job to Login and Push. Edit `.github/workflows/hello.yml`:

```YAML
name: CI Pipeline

on: [push]

jobs:
  test-code:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Run Tests
        run: python -m unittest test_app.py

  build-and-push:
    needs: test-code
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      # NEW: Login to Docker Hub
      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      # NEW: Build AND Push
      - name: Build and Push
        run: |
          docker build -t ${{ secrets.DOCKER_USERNAME }}/my-app:latest .
          docker push ${{ secrets.DOCKER_USERNAME }}/my-app:latest
```

**3. The Push** Commit and push this change.

**Your Task:**

1. Wait for the Action to turn Green.
2. Go to **hub.docker.com** in your browser.
3. Check your repositories. You should see `my-app`.
4. Look at the "Tags".

**Paste the "Last updated" time shown on Docker Hub (e.g., "a few seconds ago").**
