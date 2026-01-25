**Week 4, Day 22: CI/CD Concepts & YAML**

**The Scenario:** You push code.

- **CI (Integration):** A robot automatically runs your tests. If they fail, it blocks the merge.
- **CD (Deployment):** If CI passes, the robot automatically pushes the code to the server.

**The Structure:** GitHub Actions live in your repo at `.github/workflows/name.yml`.

**Key Terms:**

- **Workflow:** The whole file.
- **Event:** What triggers it (e.g., `on: push`).
- **Job:** A group of tasks (e.g., "Build", "Test").
- **Step:** A single command (e.g., "Run npm install").
- **Runner:** The temporary server GitHub lends you to run these commands (usually Ubuntu).

---

**Day 22 Mission: Hello GitHub Actions**

We will create a pipeline that triggers whenever you push code.

**1. Create the Repo** Create a new **public** repository on GitHub named `devops-lab`. Clone it to your machine: `git clone https://github.com/<your-user>/devops-lab.git`

**2. The Workflow File** Inside the folder, create the directory structure:

```bash
mkdir -p .github/workflows
```

Create a file named `hello.yml`:

```YAML
name: First Pipeline

on: [push]  # Trigger on any push

jobs:
  say-hello:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3 # Standard action to download your code

      - name: Run a Script
        run: echo "Hello DevOps World! The date is $(date)"

      - name: List Files
        run: ls -la
```

**3. Push it**

```bash
git add .
git commit -m "Add workflow"
git push origin main
```

**Your Task:**

1. Push the code.
2. Go to your GitHub repository page in the browser.
3. Click the "**Actions**" tab at the top.
4. Click on "First Pipeline".
5. Click on the "say-hello" job.
6. Expand the "Run a Script" step.

**Paste the exact output text you see in the "Run a Script" log.**

**Answer:** `Hello DevOps World! The date is $(date)`
