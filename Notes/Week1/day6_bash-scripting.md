**Week 1, Day 6: Bash Scripting (Logic)**

**The Scenario:** You are tired of typing the same 5 commands every morning to check your server. It's time to put logic into a file.

Bash scripts are just commands listed in a file, but with programming logic added.

**The Syntax Rules (Bash is strict!)**

1. **The Shebang:** The first line must be `#!/bin/bash`. This tells Linux "Use Bash to run this."

2. **Variables:** No spaces around the equals sign!
   - `NAME="DevOps"` (Good)
   - `NAME = "DevOps"` (Error!)

3. **The `if` Statement:** Note the spaces inside the brackets [ ].

```bash
if [ "$NAME" == "DevOps" ]; then
    echo "Match!"
else
    echo "No match"
fi
```

**Common Checks:**

- `-f filename`: True if file exists.
- `-d dirname`: True if directory exists.
- `-z "$var"`: True if variable is empty.

---

**Day 6 Mission: The Self-Healing Script**

We will write a script that checks for a configuration file. If it's missing, the script will fix the problem automatically.

**1. Create the Script** Create a file named `setup.sh`:

```bash
nano setup.sh
```

**2. Write the Logic** Copy this code (study it, don't just copy!):

```bash

#!/bin/bash

FILE="config.txt"

# Check if the file exists
if [ -f "$FILE" ]; then
    echo "Success: $FILE exists."
else
    echo "Error: $FILE is missing!"
    echo "Creating it now..."
    touch "$FILE"
fi
```

**3. Run it Twice**

1. Give it execution permission: `chmod +x setup.sh`

2. Run it the **first time**: `./setup.sh` (It should say missing and
   create it).
3. Run it the **second time**: `./setup.sh` (It should say success).

**Your Task:** Run the script twice as described. **Paste the output of the 1st run and the output of the 2nd run.**
