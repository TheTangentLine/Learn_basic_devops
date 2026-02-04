**Week 6, Day 36: IAM (Identity & Access Management)**

**The Scenario:** You never use the "Root User" (your email login) for daily work. It has too much power. If hacked, you lose your credit card and your company. You must create an **Admin User** for yourself and use that.

**Day 36 Mission: Create Your Digital ID**

**1. Log in to AWS Console** Log in using your Root email. Search for IAM in the top search bar.

**2. Create User**

1. Click **Users -> Create user**.
2. **User name**: `DevOpsAdmin` (or your name).
3. Check **Provide user access to the AWS Management Console**.
4. Select **I want to create an IAM user**.
5. Set a password. Uncheck "Users must create a new password".

**3. Permissions (The Keys to the Kingdom)**

1. Click Next.
2. Select **Attach policies directly.**
3. Search for `AdministratorAccess`. Check the box.

- _Note: In a real job, this is bad practice (too permissive), but for learning, it prevents permission errors._

4. Click **Next -> Create user.**

**4. The Download STOP**. Do not close the page yet. You will see "Console sign-in URL" and password. **Also**, we need **Access Keys** for Terraform later.

1. Click on your new user `DevOpsAdmin`.
2. Click the **Security credentials** tab.
3. Scroll to **Access keys**. Click **Create access key**.
4. Select **Command Line Interface (CLI).**
5. Download the `.csv` file. **This is the only time you will ever see these secret keys.**

Your Task:

1. Log out of the Root account.
2. Log in as your new `DevOpsAdmin` user.
3. Look at the top right of the screen.

**Paste the format of your identity shown in the top right**. (It usually looks like `DevOpsAdmin @ AccountID` or just `DevOpsAdmin`).
