**Week 3, Day 18: Volumes (Persistence)**

**The Scenario:** Containers are **ephemeral** (temporary). If you delete a database container, your data is deleted with it. That is a disaster. To save data, we punch a hole through the container to the host machine. This is called a **Volume**.

---

**Day 18 Mission: The Database Survival Test**

We will create a Postgres database, save some data, destroy the container, and prove the data survived.

**1. Create the Volume A** managed bucket for your data.

```bash
docker volume create pgdata
```

**2. Start the Database (Round 1)** Run Postgres, mounting the volume to where Postgres stores data (`/var/lib/postgresql/data`).

```bash
docker run -d --name db1 \
  -e POSTGRES_PASSWORD=secret \
  -v pgdata:/var/lib/postgresql/data \
  postgres
```

**3. Write Data** Let's create a table.

```bash
# Exec into the container and run a SQL command
docker exec db1 psql -U postgres -c "CREATE TABLE important_stuff (id serial, name text);"
docker exec db1 psql -U postgres -c "INSERT INTO important_stuff (name) VALUES ('My Data Is Safe');"
```

**4. The Destruction** Kill it. Remove it. The container is gone.

```bash
docker rm -f db1
```

**5. The Resurrection (Round 2)** Start a **new** container (`db2`), but attach the **same** volume.

```bash
docker run -d --name db2 \
  -e POSTGRES_PASSWORD=secret \
  -v pgdata:/var/lib/postgresql/data \
  postgres
```

**Your Task:** Check if the table exists in the new container.

```bash
docker exec db2 psql -U postgres -c "SELECT * FROM important_stuff;"
```

**Paste the output.** (You should see "My Data Is Safe").
