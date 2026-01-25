**Week 4, Day 26: Continuous Deployment (CD)**

**The Scenario:** Your Docker image is safe in the Registry. Now you need to update your running server. Instead of you logging in and typing `docker pull`, the robot (GitHub Actions) will SSH into your server and do it for you.

_Note: To do this for real, you need a server with a Public IP (like an AWS EC2 or DigitalOcean Droplet). If you are on a local laptop, GitHub cannot "see" you. For today, we will write the code so you understand the pattern._

---

**Day 26 Mission: The Remote Command**

**1. The Auth Strategy** We use SSH Keys again, but in reverse.

- **Private Key**: Goes into **GitHub Secrets** (so the robot can act as you).
- **Public Key**: Goes onto the **Target Server** (in `~/.ssh/authorized_keys`).

**2. The Secrets** You would add these to GitHub:

- `SERVER_HOST`: The IP address (e.g., `1.2.3.4`).
- `SERVER_USER`: The username (e.g., `ubuntu`).
- `SSH_PRIVATE_KEY`: The content of your private key file.

**3. The Workflow Update** We add a `deploy` job. We use a famous pre-made action called `appleboy/ssh-action` to handle the connection.

Edit `.github/workflows/hello.yml` to add the final stage:

```YAML
  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Server
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            # 1. Stop the old container
            docker stop my-app || true
            docker rm my-app || true

            # 2. Login (optional if public repo)
            docker login -u ${{ secrets.DOCKER_USERNAME }} -p ${{ secrets.DOCKER_PASSWORD }}

            # 3. Pull the new image
            docker pull ${{ secrets.DOCKER_USERNAME }}/my-app:latest

            # 4. Start the new container
            docker run -d --name my-app -p 80:5000 ${{ secrets.DOCKER_USERNAME }}/my-app:latest
```

**Your Task (Conceptual):** Look at the `script` section above. Why do we use `|| true` after `docker stop`? (Think about what happens the very first time you run this pipeline).

**Answer:** The `|| true` operator (OR True) forces the command to return a success code (0) even if it fails. Without this, the very first time you deploy (when no container exists), `docker stop` would return an error, and the entire pipeline would abort immediately.
