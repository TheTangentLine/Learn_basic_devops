**Week 2, Day 11: SSL/TLS (The Security Layer)**

**The Scenario:** You are sending passwords over `http://`. Anyone sitting in the same coffee shop can sniff that traffic and steal credentials. You must use **HTTPS** (Port 443).

To do this, you need a **Certificate**. In the real world, you get this from a "Certificate Authority" (like Let's Encrypt). For learning/internal testing, we create a **Self-Signed Certificate** (we act as our own authority).

**Day 11 Mission: Going Secure**

**1. Generate the Keys** We use `openssl` to create a private key and a public certificate in one go. Run this command:

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/nginx-selfsigned.key \
  -out /etc/ssl/certs/nginx-selfsigned.crt
```

It will ask you for Country, State, etc. You can just hit **Enter** through all of them.

**2. Configure Nginx for HTTPS** Open the config file again:

```bash
sudo nano /etc/nginx/sites-available/default
```

**3. The Change** We need to add a new server block that listens on 443. Add this **below** your existing configuration (don't delete the old one yet):

```nginx
server {
    listen 443 ssl default_server;
    listen [::]:443 ssl default_server;

    # Point to the keys we just made
    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

    server_name _;

    location / {
        proxy_pass http://localhost:3000;
    }
}
```

_Save and exit._

**4. Reload** `sudo nginx -t` (Check syntax) -> `sudo systemctl reload nginx`.

**5. The Test** Since we signed the certificate ourselves, your browser (and curl) will scream that it is "Insecure." We need to tell curl to ignore that safety check using the `-k` (insecure) flag.

---

**Your Task:** Run: `curl -v -k https://localhost`
**More information:** [Repository](https://github.com/TheTangentLine/Learn_SSL-TLS)
