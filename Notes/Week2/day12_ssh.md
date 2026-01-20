**Week 2, Day 12: SSH Hardening**

The Scenario: By default, servers allow you to log in with a password. This is bad. Bots scan the internet 24/7 trying` admin/password123` on every server they find.

We will disable passwords and use **SSH Keys** only.

**Day 12 Mission: Locking the Door**

_Warning: Be careful. If you do this wrong on a remote cloud server, you can lock yourself out forever. Since we are learning, keep your current terminal session open as a backup._

**1. Create Keys (On your local machine/laptop)** If you don't have keys yet, generate them:

```bash
ssh-keygen -t rsa -b 4096
```

(Press Enter for default file location). This creates `id_rsa` (Private) and `id_rsa.pub` (Public).

**2. Install the Key (The manual way)** Take the content of your **Public Key** (`cat ~/.ssh/id_rsa.pub`) and paste it into the server's authorized keys file:

```bash
# On the server (or your VM)
mkdir -p ~/.ssh
nano ~/.ssh/authorized_keys
# Paste your public key string here. Save and exit.
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

**3. Verify Key Login** Open a **new** terminal. Try to SSH into your server (or `ssh localhost` if you are on the same machine). It should **not** ask for a password. If it logs you in automatically, it worked.

**4. Disable Password Auth (The "Hardening")** Now we tell the server: "Passwords are forbidden." Edit the SSH config:

```bash
sudo nano /etc/ssh/sshd_config
```

Find these lines and change them (uncomment them if they have a `#`):

```Code snippet
PasswordAuthentication no
PubkeyAuthentication yes
```

_Save and exit._

**5. Apply**

```bash
sudo systemctl restart ssh
```

_(or `ssh.service` depending on distro)_

---

**Your Task:**

1. Perform the steps above.

2. Try to SSH into your machine.

3. **The Verification:** Run this command to check the active configuration: `sudo grep "PasswordAuthentication" /etc/ssh/sshd_config`

**FYI:**

**Question:** Why the server holds the public key but not private key ?
**Answer:**

This is the most common point of confusion, especially because it is the **exact opposite** of what we did with SSL/TLS yesterday.

Here is the Golden Rule of Cryptography: **The entity that needs to prove its identity holds the Private Key.**

**1. The Difference (Who is proving who?)**

- **In SSL (Day 11):** The **Server** (Google.com) needs to prove to You (the browser) that it is legitimate.
  - _Result: Server holds the Private Key._

- **In SSH (Day 12): You** (the Admin) need to prove to the Server that you are allowed to enter.
  - _Result: **You** hold the Private Key (on your laptop)._

**2. The Analogy: The Lock and The Key**
Think of the **Public Key** as a **Padlock** and the **Private Key** as the physical **Key**.

1. **Setup:** You (on your laptop) generate a Lock (Public) and a Key (Private).

2. **Installation:** You walk up to the Server and hang your Padlock (Public Key) on the server's door (`authorized_keys` file).

3. **Login:** When you try to SSH in:
   - The Server looks at the door and sees your Padlock.
   - It says, "I will only open this door if you can unlock this specific padlock."
   - You use your **Private Key** (which never left your pocket/laptop) to unlock it.

**3. Why not store the Private Key on the Server?**
**Security.**

If you put your Private Key on the server, and that server gets hacked:

1. The hacker steals your Private Key
2. Now the hacker can impersonate **YOU**.
3. They can use that key to log into every other server you own.

By keeping the Private Key on your laptop, even if the server is destroyed, your identity is safe.
