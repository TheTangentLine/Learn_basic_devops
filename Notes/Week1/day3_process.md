**Week 1, Day 3: Process Management**

**The Scenario:** You SSH into a production server because the CPU is at 100%. You need to find the rogue process and kill it without rebooting the whole machine.

You need to master three things:

1. **Backgrounding:** Running things without blocking your terminal.
2. **Listing:** Finding the "Process ID" (PID)
3. **Killing:** Sending signals to stop the process.

**The Tools**

- `&`: Put this at the end of a command to run it in the background.
  - `python server.py &` -> Returns control to you immediately.

- `ps aux`: "Process Status". Lists every running process. It dumps a lot of data, so we usually pipe it to grep.
  - `ps aux | grep python`

- `kill <PID>`: Sends a signal to stop the process.
  - `kill 1234` (Polite ask to stop).
  - `kill -9 1234` (The "Nuclear Option". Force kill immediately. Use only if it's stuck).

---

**Day 3 Mission: The Zombie Hunt**
We are going to simulate a stuck process and kill it.

1. **Create the Zombie:** Run the `sleep` command (which just waits) for 1000 seconds, and put it in the background so you can still type.
   - Command: `sleep 1000 &`

2. **Find the ID:** The terminal might print the PID when you run it, but pretend you missed it. Use `ps aux` and grep to find the line for `sleep 1000`.

3. **Kill it:** Take that PID and terminate the process.

4. **Verify:** Run `ps aux` again to make sure it's gone.

**Execute the mission.** Paste the exact sequence of commands you used to **Find** and **Kill** the process.

**Answer:**

```bash
sleep 1000 &
ps aux | grep sleep # example: pid = 2
kill -9 2
ps aux | grep sleep # not see anymore
```
