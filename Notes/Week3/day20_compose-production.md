**Week 3, Day 20: Compose for Production**

**The Scenario:** In the real world, `depends_on` is a lie. It only waits for the database container to start, not for the database software to be ready to accept connections. This causes your app to crash on startup because the DB port isn't open yet.

We need **Healthchecks** and **Environment Variables** (Secrets).

---

**Day 20 Mission: Bulletproof the Stack**

We will modify yesterday's WordPress stack so the App waits until MySQL is truly ready, and we will hide the passwords.

**1. The Secrets** (`.env`) Never commit passwords to Git. Docker Compose automatically looks for a file named `.env`. Create a file named `.env`:

```bash
MYSQL_ROOT_PASSWORD=supersecretkey
MYSQL_USER=wordpress
MYSQL_PASSWORD=wordpress
```

**2. The Robust** `docker-compose.yml` Overwrite your previous file with this one.

- **Look for:** `${VARIABLE}` syntax.
- **Look for:** `healthcheck` block in `db`.
- **Look for:** `condition: service_healthy` in `wordpress`.

```YAML
version: '3.8'

services:
  db:
    image: mysql:5.7
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: wordpress
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    # THE UPGRADE: Check if MySQL is actually answering queries
    healthcheck:
      test: ["CMD", "mysqladmin" ,"ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5

  wordpress:
    depends_on:
      db:
        condition: service_healthy  # WAIT for the healthcheck to pass
    image: wordpress:latest
    ports:
      - "8000:80"
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: ${MYSQL_USER}
      WORDPRESS_DB_PASSWORD: ${MYSQL_PASSWORD}
      WORDPRESS_DB_NAME: wordpress

volumes:
  db_data:
```

**3. The Verification**

1. Stop the old containers: `docker-compose down`
2. Start the new stack: `docker-compose up -d`
3. Watch the status: `docker ps`

**Your Task:** Run `docker ps`. Look at the **STATUS** column for the `db` container. Initially, it will say `(health: starting)`. Wait 10-20 seconds. **Paste the output when it changes to** `(health: healthy)`.
