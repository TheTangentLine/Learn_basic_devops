**Week 2, Day 10: The Reverse Proxy**

**The Scenario:** Static HTML is boring. You want to run a Python or Node app. Your app listens on **Port 3000**. The user visits **Port 80** (standard HTTP). You need Nginx to take the request on Port 80 and "proxy" (forward) it to Port 3000.

**This is the most common architectural pattern in DevOps.**

**Day 10 Mission: Connecting the Pipes**

**1. The "Backend" App** Instead of writing a full app, we will use Python's built-in cheat code to start a web server instantly on port 3000. Open a **new terminal window** (or use `screen`/`tmux` if you know them) and run:

```bash
# Create a folder for the app

mkdir my_backend
cd my_backend
echo "This is the Backend running on Port 3000" > index.html

# Start the server (it will hang here, which is fine)

python3 -m http.server 3000
```

_Keep this terminal open._

**2. The Nginx Configuration** Go back to your **original terminal**. We need to tell Nginx to forward traffic. Edit the default config file:

```bash
sudo nano /etc/nginx/sites-available/default
```

**3. The Change** Find the section that looks like `location / { ... }`. Delete what is inside the curly braces and replace it with `proxy_pass`. It should look exactly like this:

```nginx
server {
listen 80 default_server;
listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        # THIS IS THE MAGIC LINE
        proxy_pass http://localhost:3000;
    }

}
```

_Save and exit (Ctrl+O, Enter, Ctrl+X)._

**4. The Reload** Whenever you change config, you must reload.

```bash
# Check for syntax errors first

sudo nginx -t

# If ok, reload

sudo systemctl reload nginx
```

---

**Your Task:**

1. Ensure your Python server is still running in the other window.

2. Run `curl localhost` (which hits Nginx on Port 80).

3. **Result**: You should see "This is the Backend running on Port 3000" instead of your previous "DevOps Engineer" HTML.
