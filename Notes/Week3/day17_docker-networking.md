**Week 3, Day 17: Docker Networking**

**The Scenario:** You have a `frontend` container and a `backend` container.

- **Bad Way:** You hardcode IP addresses (which change every time containers restart).

- **Good Way:** You use **Service Discovery**. You want to just say `curl http://backend` and let Docker figure out the IP.

To do this, you must create a **Custom Bridge Network**.

---

**Day 17 Mission: The Ping Test**

We will create a private network and prove that containers can find each other by **Name**.

**1. Create the Network** This is the virtual switch that connects your containers.

```bash
docker network create my-net
```

**2. The "Server"** Run a standard Nginx container, but attach it to our network and give it the name `myserver`.

```bash
docker run -d --name myserver --network my-net nginx
```

**3. The "Client"** Now, we run a tiny Alpine Linux container on the **same network**. We will tell it to "ping myserver".

- Docker's internal DNS will see "myserver", look up its container IP, and route the traffic.

**Your Task:** Run this command:

```bash
docker run --rm --network my-net alpine ping -c 4 myserver
```

**Paste the output.**

- (Note: You should see it resolving an IP like `172.18.0.2` and getting replies).
