**Week 4, Day 24: Building Artifacts**

**The Scenario:** Your tests passed. Great. But you can't deploy "source code" to a server easily. You deploy **artifacts** (binaries, JARs, or Docker Images). We are going to tell GitHub Actions to build a Docker image immediately after the tests pass.

---

**Day 24 Mission: The Pipeline Build**

**1. The Dockerfile** In your `devops-lab` repo, create a `Dockerfile` (if you don't have one there yet):

```Dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY app.py .
CMD ["python", "-c", "import app; print(app.add(5,5))"]
```

**2. The Workflow Update** We will add a "Build" job. Note: Jobs run in parallel by default. We need `needs: test-code` to ensure we only build IF tests pass.

Overwrite `.github/workflows/hello.yml`:

```YAML
name: CI Pipeline

on: [push]

jobs:
  # JOB 1: TEST
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

  # JOB 2: BUILD (Runs only if test-code succeeds)
  build-image:
    needs: test-code
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Build Docker Image
        run: docker build -t my-app:${{ github.sha }} .

      - name: Verify Build
        run: docker images
```

**3. The Push** Commit and push the new files.

```bash
git add .
git commit -m "Add build step"
git push origin main
```

**Your Task:**

1. Go to the "Actions" tab.
2. You should now see two circles connected by a line (Test -> Build).
3. Click "build-image" -> "Verify Build".

**Paste the size of the image named `my-app` shown in the logs.**(Approximate size is fine).

**Answer:** The image size for `python:3.9-slim` plus your code is typically around **125MB**.
