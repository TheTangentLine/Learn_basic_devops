**Week 1, Day 7: The Weekly Challenge (The Backup Script)**

**The Scenario:** You are responsible for a critical data folder. If the server crashes, that data is gone. Your boss wants a daily "snapshot" of this folder, compressed to save space, and labeled with today's date so we know when it was taken.

**Your Mission:** Write a bash script named `backup.sh` that performs the following steps:

1. **Define Variables:**
   - `SOURCE`: The folder you want to backup (create a dummy folder named `data` with some text files in it).

   - `DEST`: The folder where backups go (create a folder named `backups`).

   - `DATE`: A string representing right now (format: YYYY-MM-DD). _Hint: Use `$(date +%F)`_.

2. **Compress:**
   - Create a `.tar.gz` file of the `SOURCE` folder.

   - The filename must be: `backup-YYYY-MM-DD.tar.gz` (using your DATE variable).

   - Save it inside the `DEST` folder.

   - _Hint: `tar -czvf /path/to/destination/file.tar.gz /path/to/source`_

3. **Verify:**
   - Check if the file was successfully created.
   - If yes, print "Backup successful: [filename]".
   - If no, print "Backup failed!"

**Execute the mission.** Write the script, test it on your local machine, and **paste the full code of your `backup.sh` here.**
