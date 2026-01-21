**Week 2, Day 14: The Weekly Challenge (The Production Environment)**

**The Scenario:** You are launching a new internal tool.

1. It runs on **Port 8080** (simulated).

2. It must be accessible via a custom domain `internal-tool.local` on standard **Port 80**.

3. You need a "Watchdog" script that checks if the site is up and alerts you if it crashes.

---

**Your Mission:**

**Step 1: The Infrastructure (Nginx & Hosts)**

**1. Simulate DNS:** Edit your `/etc/hosts` file (`sudo nano /etc/hosts`). Add this line: `127.0.0.1 internal-tool.local`

**2. The Backend:** Start a Python server on port 8080 in a background terminal: `mkdir -p /tmp/tool && echo "Critical Data" > /tmp/tool/index.html cd /tmp/tool && python3 -m http.server 8080 &`

The Proxy: Create a new Nginx config (`/etc/nginx/sites-available/tool`) that proxies `internal-tool.local` (Port 80) -> `localhost:8080`.

- _Hint: Remember `server_name internal-tool.local`; and `proxy_pass`._
- _Enable it (symlink to `sites-enabled`) and reload Nginx._

**Step 2: The Watchdog Script**
Write a bash script `watchdog.sh` that:

1. Uses `curl` to check the status code of `http://internal-tool.local`.

2. **Logic:**
   - If the code is **200**, print "✅ System Online".
   - If the code is **anything else** (or connection refused), print "🚨 ALERT: System Down!".
   - _Hint: `curl -o /dev/null -s -w "%{http_code}\n" http://internal-tool.local` gives you just the number._

---

**Execute the mission.**

1. Set up the Nginx proxy.
2. Write the script.
3. **Kill your Python server** (`fg` then `Ctrl+C` or `kill <pid>`) and run the script to see the alert.
