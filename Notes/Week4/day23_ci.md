**Week 4, Day 23: Continuous Integration (The Gatekeeper)**

**The Scenario:** Printing "Hello" is fun, but useless. The purpose of CI is to **block bad code**. If a developer pushes code that breaks the app, the pipeline should scream (Turn Red) and prevent merging.

We are going to simulate a Unit Test failure.

---

**Day 23 Mission: Red Light, Green Light**

We will create a Python app and a test file. We will configure the pipeline to run the test.

**1. The Application Code** In your `devops-lab` repo, create `app.py`:

```python
def add(a, b):
    return a + b
```

**2. The Test Code** Create `test_app.py`. We will use the built-in `unittest` framework (no install needed).

```python
import unittest
from app import add

class TestApp(unittest.TestCase):
    def test_add(self):
        self.assertEqual(add(2, 3), 5)  # This is correct
        self.assertEqual(add(10, 10), 0) # THIS IS A BUG! 10+10 is not 0.
```

_(We are intentionally planting a bug to see the CI fail)._

**3. The Workflow Update** Edit `.github/workflows/hello.yml`. Replace the steps with this logic:

```YAML
name: CI Pipeline

on: [push]

jobs:
test-code:
runs-on: ubuntu-latest
steps: - name: Checkout Code
uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'

      - name: Run Tests
        run: python -m unittest test_app.py
```

**4. The Trigger** Commit and push.

```bash
git add .
git commit -m "Add broken tests"
git push origin main
```

**Your Task:**

1. Go to the "Actions" tab. You will see a ❌ (Red Cross).
2. Click into it. Read the error log.
3. **Fix the code:** Edit `test_app.py` locally. Change `assertEqual(add(10, 10), 0)` to `assertEqual(add(10, 10), 20)`.
4. Push the fix.

**Paste the specific line from the FINAL successful log that says how many tests ran.** (e.g., `Ran X tests in 0.00Xs`).
