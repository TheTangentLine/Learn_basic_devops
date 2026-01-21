**Week 2, Day 13: Log Management (The Black Box)**

**The Scenario:** Users are reporting 500 errors. Your boss asks, "How many times did it happen in the last hour?" If you say "I don't know," you aren't doing DevOps.

You need to mine the **Logs**.

**The Tools**

- `tail -f /path/to/log`: "Follow". Watches the file in real-time. It's like the matrix code scrolling down your screen.

- `awk`: A programming language just for text. We use it to pick specific columns (e.g., "Give me just the IP address").

- `uniq -c`: Counts adjacent duplicate lines.

---

**Day 13 Mission: Data Mining Nginx**
Nginx logs look like this: `192.168.1.5 - - [17/Jan/2026:10:00:00] "GET / HTTP/1.1" 200 612 ...`

We want to extract that `200` (The Status Code) and count how many successes vs. failures we have.

**1. Generate Data** First, let's create some noise so we have something to count. Run this 4-5 times in your terminal:

```bash
curl -I localhost/nonexistent  # Generates 404
curl -I localhost              # Generates 200
```

**2. The `awk` Command** Nginx standard log format puts the **Status Code** in the **9th column** (separated by spaces). Run this to see just the codes:

```bash
sudo awk '{print $9}' /var/log/nginx/access.log
```

_(You should see a list like: 200, 404, 200, etc.)_

**3. The Analysis Pipeline** Now we chain commands to count them.

1. Get the column (`awk`)
2. Sort them (`sort` - `uniq` needs sorted input)
3. Count unique occurrences (`uniq -c`)

**Your Task:** Run this specific pipeline:

```bash
sudo awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c
```
