### **Month 1: The System & The Pipeline**

#### **Week 1: Linux "Under the Hood"**

_Goal: Move from "using Linux" to "administrating Linux."_

- **Day 1: Shell Efficiency.** Learn input/output redirection (`>`, `>>`, `|`), and chaining commands (`&&`, `;`). **Task:** Combine `ls`, `grep`, and output redirection to create a file listing all `.log` files in `/var/log`.
- **Day 2: Permissions & Users.** Understanding `rwx`, `chown`, `chmod` (octal vs symbolic), and the `sudoers` file. **Task:** Create a new user, give them specific read-only access to a directory, and deny them `sudo` access.
- **Day 3: Process Management.** `ps aux`, `top`/`htop`, `kill`, and background jobs (`&`, `bg`, `fg`). **Task:** Start a long-running process, background it, find its PID, and kill it gracefully.
- **Day 4: Systemd & Services.** This is how production apps run. Learn `systemctl` (start, stop, enable, status) and unit files. **Task:** Write a custom `.service` file that runs a simple Python script on boot.
- **Day 5: Networking CLI.** `curl` (headers, payloads), `ping`, `telnet`/`nc` (checking ports), `nslookup`. **Task:** Use `curl -v` to debug a request to Google and explain the handshake.
- **Day 6: Bash Scripting (Logic).** Variables, loops (`for`, `while`), and conditionals (`if`). **Task:** Write a script that checks if a specific process (e.g., Nginx) is running; if not, start it.
- **Day 7: Weekly Challenge.** Create a script that backs up a specific folder to a `/backup` directory with a timestamp in the filename, then deletes backups older than 7 days using `find`.

#### **Week 2: Networking & Web Servers**

_Goal: Understand how traffic hits your app._

- **Day 8: HTTP & DNS.** DNS records (A, CNAME), HTTP status codes (2xx, 3xx, 4xx, 5xx), and headers. **Task:** Buy a cheap domain (or simulate one with `/etc/hosts`) and point it to your local machine.
- **Day 9: Nginx Basics.** Install Nginx. Understand `nginx.conf`, server blocks, and static file serving. **Task:** Serve a static HTML "Hello World" page using Nginx.
- **Day 10: Reverse Proxy.** The most common DevOps pattern. **Task:** Run a NodeJS/Python app on localhost:3000. Configure Nginx on port 80 to proxy traffic to port 3000.
- **Day 11: SSL/TLS.** HTTPS, certificates, and Let's Encrypt (Certbot). **Task:** Generate a self-signed certificate and configure Nginx to force HTTPS.
- **Day 12: SSH Hardening.** Key-based auth, disabling password login, changing default SSH ports. **Task:** Disable password login on your VM and ensure you can still access it via keys.
- **Day 13: Log Management.** `tail -f`, `grep`, `awk`. **Task:** Use `awk` to parse your Nginx access logs and count the number of 404 errors.
- **Day 14: Weekly Challenge.** Set up a "Production" Environment: Nginx acting as a Reverse Proxy + HTTPS (self-signed) + a Bash script that alerts you (echo to console) if the service goes down.

#### **Week 3: Advanced Docker**

_Goal: Production-grade containerization._

- **Day 15: Dockerfiles Deep Dive.** `ENTRYPOINT` vs `CMD`, `COPY` vs `ADD`, User switching (security). **Task:** Refactor a Dockerfile to run as a non-root user.
- **Day 16: Multi-Stage Builds.** Drastically reduce image size. **Task:** Take a Go or Node app. Build it in one stage, copy the binary to a strict `alpine` image in the second stage.
- **Day 17: Docker Networking.** Bridge, Host, and internal DNS. **Task:** Run two containers manually and make them ping each other by container name.
- **Day 18: Volumes & Persistence.** Bind mounts vs Volumes. **Task:** Run a Postgres container. Kill it. Restart it. Ensure the data is still there.
- **Day 19: Docker Compose.** Services, networks, volumes. **Task:** Create a `docker-compose.yml` for a full stack (Frontend + Backend + DB).
- **Day 20: Compose for Production.** Restart policies (`always`, `on-failure`), environment variables (`.env`). **Task:** Add a healthcheck to your database container so the backend waits for it to be ready.
- **Day 21: Weekly Challenge.** "Dockerize" a legacy project. Write a Compose file that sets up the app, a database, and a Redis cache, ensuring they communicate privately.

#### **Week 4: CI/CD (GitHub Actions)**

_Goal: Automate the path from Code -> Running App._

- **Day 22: CI/CD Concepts & YAML.** Understanding Runners, Steps, Jobs, and Workflows. **Task:** Create a `.github/workflows/main.yml` that simply prints "Hello World" on push.
- **Day 23: Continuous Integration.** Linting and Testing. **Task:** Add a step to your pipeline that runs `npm test` or `pytest`. Fail the pipeline if tests fail.
- **Day 24: Building Artifacts.** **Task:** If tests pass, build a Docker image inside the pipeline.
- **Day 25: Container Registry.** **Task:** Login to DockerHub within the pipeline (using Secrets) and push your built image.
- **Day 26: Continuous Deployment (CD).** SSH and scripting. **Task:** Use an SSH action to connect to your Linux VM, pull the new image, and restart the container.
- **Day 27: Secrets Management.** Handling API keys and ENV vars in CI/CD. **Task:** Move all sensitive config from your code to GitHub Secrets and inject them during the build.
- **Day 28: Weekly Challenge.** Full Pipeline. Push code -> Tests Run -> Image Builds -> Pushes to Hub -> Deploys to Server. (This is a major milestone).

---

### **Month 2: Infrastructure & Scale**

#### **Week 5: AWS (The Cloud)**

_Goal: Understanding the environment._

- **Day 29: IAM (Identity Access Management).** Users, Roles, Policies. **Task:** Create a user with Read-Only access to S3. Try to delete a file (it should fail).
- **Day 30: EC2 (Compute).** Instances, AMIs, SSH Key Pairs. **Task:** Launch an EC2 t2.micro manually. SSH into it. Install Docker.
- **Day 31: Security Groups (Firewalls).** Inbound/Outbound rules. **Task:** Lock down your EC2 so only YOUR home IP can SSH into it.
- **Day 32: VPC Basics (Networking).** Subnets, Route Tables, Internet Gateways. **Task:** Create a custom VPC with one public subnet. Launch an instance there.
- **Day 33: S3 (Storage).** Buckets, permissions. **Task:** Host a static website (HTML/CSS) directly on an S3 bucket.
- **Day 34: EC2 Roles.** Giving machines permissions without keys. **Task:** Attach an IAM Role to your EC2 allowing it to write to S3. Run a script on the EC2 to upload a file to S3 (no credentials in code!).
- **Day 35: Weekly Challenge.** Manual Cloud Deployment. Deploy your Dockerized app to an EC2 instance, using Security Groups to expose only port 80/443.

#### **Week 6: Terraform (Infrastructure as Code)**

_Goal: Automate Week 5._

- **Day 36: Install & HCL Syntax.** Providers, Resources. **Task:** Write a `main.tf` to provision a single AWS S3 bucket.
- **Day 37: State Management.** `terraform plan`, `apply`, `destroy`. Understanding `terraform.tfstate`. **Task:** Create a resource, change its name in code, apply the change, and see what happens.
- **Day 38: Variables & Outputs.** Making code reusable. **Task:** Variable-ize your region and bucket name. Output the bucket's URL after creation.
- **Day 39: Provisioning EC2.** **Task:** Write Terraform code to launch an EC2 instance with a specific Security Group.
- **Day 40: Modules.** Don't Repeat Yourself (DRY). **Task:** Use a pre-made module (or write a simple one) to create a VPC.
- **Day 41: Remote Backend.** Storing state in S3. **Task:** Configure Terraform to store the state file in an S3 bucket instead of your local laptop (crucial for teams).
- **Day 42: Weekly Challenge.** Destroy your manual AWS infrastructure. Re-create the VPC, Security Group, and EC2 instance entirely using one `terraform apply` command.

#### **Week 7: Kubernetes Basics**

_Goal: Orchestration._

- **Day 43: K8s Architecture.** Nodes, Pods, Control Plane. Install Minikube or K3s. **Task:** Get a local cluster running. Run `kubectl get nodes`.
- **Day 44: Pods.** The atomic unit. **Task:** Write a `pod.yaml`. Deploy an Nginx pod. Port-forward it to access it locally.
- **Day 45: Deployments.** Scaling and self-healing. **Task:** Create a `deployment.yaml` with 3 replicas. Delete a pod manually and watch K8s recreate it.
- **Day 46: Services.** All services. **Task:** Expose your deployment so you can access it from your browser.
- **Day 47: ConfigMaps & Secrets.** Injecting config. **Task:** Move your environment variables into a ConfigMap and mount them into the Pod.
- **Day 48: API Gateway.** HTTP Routing. **Task:** Set up an API Gateway.
- **Day 49: Weekly Challenge.** Deploy your full-stack app to K8s. Frontend deployment, Backend deployment, Database deployment (with a Service to connect them).

#### **Week 8: Observability & Final Project**

_Goal: Monitoring and wrap-up._

- **Day 50: Metrics Concepts.** Time-series data. **Task:** Install **Prometheus** on your cluster (use Helm if you want to be fancy, or standard manifests).
- **Day 51: Visualization.** **Grafana**. **Task:** Connect Grafana to Prometheus.
- **Day 52: Dashboards.** **Task:** Import a standard "Node Exporter" dashboard to see CPU/Memory usage of your cluster.
- **Day 53: Application Monitoring.** **Task:** Add an endpoint to your app (`/metrics`) that exports data. Scrape it with Prometheus.
- **Day 54: Logging.** **Task:** Use `kubectl logs` effectively. Setup a basic log aggregator if time permits (like Loki).
- **Day 55: Alerting.** **Task:** Configure a rule: "If a Pod restarts more than 5 times in 1 hour, fire an alert."
- **Day 56: FINAL PROJECT.**
  1.  Provision cloud infrastructure (EC2/EKS) with **Terraform**.
  2.  Pipeline builds image and pushes to registry (**CI**).
  3.  Pipeline updates K8s manifest and deploys (**CD**).
  4.  App runs on **Kubernetes**.
  5.  **Grafana** dashboard shows the app is alive.

**Would you like a resource list (YouTube channels, documentation links) for any specific week?**
