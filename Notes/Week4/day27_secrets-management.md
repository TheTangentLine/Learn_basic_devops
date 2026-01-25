**Week 4, Day 27: Secrets Management (The Vault)**

**The Scenario:** Hardcoding credentials is the #1 way companies get hacked. You already used GitHub Secrets. But how does the application get secrets? You should not bake `.env` files into your Docker image (because then anyone with the image has your passwords).

You must **inject** them at runtime.

---

**Day 27 Mission: Runtime Injection**
**1. The App Update** Modify `app.py` to read from an Environment Variable.

```python
import os
def get_secret():
    return os.getenv("MY_SECRET_KEY", "DefaultValue")

if __name__ == "__main__":
    print(f"The secret is: {get_secret()}")
```

**2. The Deployment Update** We need to pass the secret from GitHub Secrets -> SSH Action -> Docker Run command.

Look at this command structure:

```bash
docker run -d \
  -e MY_SECRET_KEY='${{ secrets.APP_SECRET }}' \
  --name my-app ...
```

**Your Task:** There is a security risk in the command above. If you run `ps aux` on the server, anyone can see the full `docker run` command, including the secret key in plain text.

**How do we securely pass environment variables to Docker without them showing up in the process list?** (Hint: We did this in Week 3 with a specific file).

**What is the Docker flag to read env vars from a file?**

**The Answer:** `--env-file`

If you use `-e KEY=VALUE`, the value is visible to anyone running `ps inspect` or `ps aux`. If you use --env-file .env, only the filename is visible, not the contents.
