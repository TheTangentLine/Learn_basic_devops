**Week 6, Day 37: The AWS CLI (The Bridge)**

**The Scenario:** You have your keys (Access Key ID and Secret Access Key) from yesterday. Now you need to introduce your terminal to AWS. Without this, Terraform cannot talk to the cloud.

---

**Day 37 Mission: Wire the Terminal**

**1. Install AWS CLI** If you don't have it:

- Mac: `brew install awscli`
- Windows: `winget install Amazon.AWSCLI`
- Linux: `sudo apt install awscli`

**2. The Configuration** Run this command:

```bash
aws configure
```

It will ask you 4 questions. Use the data from the `.csv` file you downloaded yesterday.

**1. AWS Access Key ID:** Paste your key (starts with `AKIA...`).
**2. AWS Secret Access Key:** Paste the long secret string.
**3. Default region name:** `us-east-1` (This is N. Virginia, the standard default).
**4. Default output format:** `json`

**3. The Verification** We need to prove the connection works. We will ask AWS "Who am I?".

**Your Task:** Run this command:

```bash
aws sts get-caller-identity
```

**Paste the output**. (It should show a JSON block with `UserId`, `Account`, and `Arn`).

**Answer:**

```json
{
  "UserId": "AIDAZ6S4X...",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/DevOpsAdmin"
}
```
