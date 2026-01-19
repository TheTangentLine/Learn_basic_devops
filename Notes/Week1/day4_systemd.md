**Week 1, Day 4: Systemd (The Production Manager)**

**The Scenario:** You wrote a great API. You start it with `python app.py &`. It works! But then the server reboots for an update. When it comes back up, your API is dead.

**Systemd** solves this. It is the "init system" for most Linux distros. It manages "Services"—programs that run in the background, start on boot, and restart if they crash.

The Tools: `systemctl`

- `sudo systemctl start <name>`: Start it now.
- `sudo systemctl enable <name>`: Start it **automatically on boot.**
- `sudo systemctl status <name>`: Check logs and running state.
- `sudo systemctl restart <name>`: The "turn it off and on again" fix.

---

**Day 4 Mission: Immortalize a Script**

_Note: This requires a Linux environment with `sudo` access (VM, VPS, or WSL). Standard Docker containers usually don't have systemd active._

**1. The "Application"** Create a dummy Python script that runs forever.

```bash
# Create the file
nano /tmp/myservice.py
```

Paste this code (ctrl+o to save, ctrl+x to exit):

```python
import time
while True:
    with open("/tmp/service_log.txt", "a") as f:
        f.write("I am alive\n")
    time.sleep(5)
```

**2. The Unit File** This tells Systemd how to run your script.

```bash
# Create the service file (requires root)
sudo nano /etc/systemd/system/my-test.service
```

Paste this configuration:

```TOML
[Unit]
Description=My Test Service

[Service]
ExecStart=/usr/bin/python3 /tmp/myservice.py
Restart=always

[Install]
WantedBy=multi-user.target
```

**3. The Activation** Now, make it run.

1. `sudo systemctl daemon-reload` (Tell systemd you added a new file).

2. `sudo systemctl start my-test` (Start it).

3. `sudo systemctl status my-test` (Check if it's green/active).

**Your Task:** Perform the steps above. If it works, the status command will show "Active: active (running)".
