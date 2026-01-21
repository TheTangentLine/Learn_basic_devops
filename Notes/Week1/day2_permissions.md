**Week 1, Day 2: Permissions (The Gatekeeper)**

In DevOps, "Permission Denied" is the error you will see 50% of the time. You need to understand **Octal Permissions.**

Every file has permissions for 3 groups: **Owner (u), Group (g), Others (o)**. Permissions are numbers:

- **Read (r)** = 4
- **Write (w)** = 2
- **Execute (x)** = 1

**Math:**

- `7` = 4+2+1 (Read, Write, Execute) -> Full control.
- `6` = 4+2 (Read, Write) -> Standard for files.
- `5` = 4+1 (Read, Execute) -> Run scripts but can't change them.
- `4` = 4 (Read only).
- `0` = No access.

**Example:** `chmod 755 file`

- **Owner (7):** Read + Write + Execute.
- **Group (5):** Read + Execute.
- **Others (5):** Read + Execute.

---

**Day 2 Mission: The Secret Script**
We are going to create a script and lock it down.

1. Create a file named `deploy.sh` with the content `echo "Deploying to Production...".`
2. Try to run it using `./deploy.sh`. **It should fail.**
3. **Task A:** Fix the permissions so you (the Owner) can execute it.
4. **Task B (The Challenge)**: Change permissions so that **ONLY** you can Read, Write, and Execute it. Everyone else (Group and Others) should have **zero** permissions.

**Execute this mission.** Paste the commands you used for Task A and Task B, and the final permission code (e.g., 777, 644, etc.).

**Answer:**

```bash
echo 'echo “Deplying to Production”' > deploy.sh
chmod 700 deploy.sh
```
