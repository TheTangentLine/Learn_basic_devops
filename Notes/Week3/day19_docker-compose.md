**Week 3, Day 19: Docker Compose (The Orchestrator)**

**The Scenario:** You have 3 containers: `App`, `DB`, and `Redis`. Running `docker run` three times with all the flags (networks, volumes, ports) is a nightmare. Docker Compose lets you define your entire stack in **one YAML file**. You start everything with `docker-compose up`.

---

**Day 19 Mission: The Full Stack**

We will define a WordPress stack (App + MySQL) in a single file.

**1. Create the Workspace**

```bash
mkdir my-wordpress
cd my-wordpress
```

**2. The** `docker-compose.yml` Create this file exactly. Note the indentation (YAML is strict!).

```YAML
version: '3.8'

services:
  db:
    image: mysql:5.7
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: somewordpress
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress

  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    ports:
      - "8000:80"
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
      WORDPRESS_DB_NAME: wordpress

volumes:
  db_data:
```

**3. The Magic Command** Start the entire stack in the background (`-d`).

```bash
docker-compose up -d
```

_(Note: If you have a newer Docker version, the command is just `docker compose up -d` without the hyphen)._

**Your Task:**

1. Run the command.
2. Wait 30 seconds for MySQL to initialize.
3. Open your browser to `http://localhost:8000.`
4. **Or** verify via curl: `curl -I localhost:8000`

**Paste the output of the curl command.** (You should see a `302 Found` or `200 OK` from WordPress).
