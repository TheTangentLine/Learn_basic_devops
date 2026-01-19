**Week 1, Day 1: Shell Efficiency**

**The Mindset Shift:** As a full-stack dev, you use the terminal to run servers (`npm start`). As a DevOps engineer, you use the terminal to manipulate data streams and automate logic. You cannot rely on a GUI.

Today is about controlling where data goes (**Redirection**) and chaining logic (**Control Operators**).

**1. Redirection (Streams)**
Linux has three standard streams:

- Stdin (0): Input (keyboard).
- Stdout (1): Output (screen).
- Stderr (2): Error messages.

**The Operators:**

- `>` : **Overwrite**. Saves output to a file (deletes existing content).
  - `echo "Hello" > file.txt`

- `>>` : **Append**. Adds to the end of a file (crucial for logs).
  - `echo "New Log Entry" >> logs.txt`

- `|` : **Pipe**. Takes the **Stdout** of the left command and pushes it into **Stdin** of the right command.
  - `cat huge_file.txt | less` (Reads file, pipes it to a pager so you can scroll).

**2. Chaining (Logic)**

- `&&` : **AND**. Run the second command **ONLY IF** the first one succeeds (exit code 0).
  - `mkdir build && cd build` (If `mkdir` fails, `cd` won't run).

- `;` : **Separator**. Run the second command regardless of what happened before.
  - `cd /wrong/path ; ls` (Will try to CD, fail, and then list the current directory anyway).

---

**Day 1 Exercise: The "Log Hunter"**
**Scenario:** You are debugging a server. You need to find specific log files without opening them one by one, and save that list for your manager.

**Your Mission:**

1. Create a dummy folder named `devops_day1.`
2. Inside it, create 3 empty files: `app.log`, `error.log`, and `config.json`.
3. **The Challenge:** Write **ONE single command line** (using pipes and redirection) that:
   - Lists all files in the directory (`ls`).
   - Filters specifically for files ending in `.log` (`grep`).
   - Saves that list into a new file called `incident_report.txt`.

**Answer:**

```bash
ls | grep "\.log" > incident_report.txt
```
