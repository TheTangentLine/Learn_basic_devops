**Week 2, Day 9: Nginx (The Traffic Controller)**

**The Scenario:** You have a NodeJS or Python app running on port 3000. But the world expects to talk to port 80 (HTTP). You _could_ run your app on port 80 as root, but that is a security nightmare.

**The Solution:** Use **Nginx**. Nginx is a Web Server. It sits at the front door. It handles the incoming traffic, handles the SSL (security), and then passes the request to your application. This is called a **Reverse Proxy**.

Today, we just want to install it and make it say hello.

---

**Day 9 Mission: First Contact**

_Note: If you are on Mac/Windows without a VM, you can simulate this using Docker: `docker run -it -p 80:80 --name my-nginx ubuntu bash`, then run the commands inside._

**1. Install Nginx:**

```bash
sudo apt update
sudo apt install nginx -y
```

2. **Check the Status:** Ensure it's running.

```bash
sudo systemctl status nginx
```

(Press `q` to exit the status screen).

3. **The "Web Root":** By default, Nginx looks into `/var/www/html/` for files to serve. There is usually a file there called `index.nginx-debian.html`.

4. **Vandalize the Page:** I want you to change the default "Welcome to Nginx" page to your own custom message.

```bash
echo "<h1>I am a DevOps Engineer</h1>" | sudo tee /var/www/html/index.nginx-debian.html
```

(Note: We use `tee` here because standard `>` redirection often fails with sudo permissions).

---

**Your Task:** Run the commands above. Then, verify your work by curling your own local machine: `curl localhost`

**Answer:**
Output: `I am a DevOps Engineer`
