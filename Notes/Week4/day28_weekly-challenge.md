**Week 4, Day 28: The Weekly Challenge (The Full Pipeline)**

**The Scenario:** Your boss is impressed. "Okay, let's ship it." You need to build a complete CI/CD pipeline for a Node.js (or Python) application.

**Your Mission:** You will write a GitHub Actions workflow that performs the "**Build-Test-Ship**" cycle.

**The Requirements**

Create a single YAML file (`pipeline.yml`) that defines:

**1. Trigger:** Runs on every `push` to the `main` branch.
**2. Job 1: CI (Test)** - Checkout code. - Set up Node.js (or Python). - Run a dummy test command (`echo "Running Tests... passed!"`).

**3. Job 2: Build (Package)** - **Needs:** Job 1 (must wait for tests). - Build a Docker image tagged `latest`. - _Simulation: Since we aren't really pushing to Hub today, just run docker build .._

**4. Job 3: Deploy (Release)** - **Needs:** Job 2. - _Simulation:_ Since we don't have a live server, just run a script that prints: `"Deploying version ${{ github.sha }} to Production Server..."`

**Execute the mission.** Write the YAML file. Pay attention to the `needs` keyword to ensure the order is correct (Test -> Build -> Deploy).
