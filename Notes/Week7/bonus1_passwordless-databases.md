**Passwordless Databases (The IAM Phantom)**

**The Scenario:** Hardcoding a database password like `supersecret123` in your code is a massive security risk. If that leaks, hackers have permanent access. In modern cloud production, we use **IAM Authentication**. You tell the SDK: "I don't have a password. Use my server's IAM Role to generate a temporary, 15-minute token."

---

**Day 50 Mission: The Token Generator Test**

**1. The Code (`generate-token.js`)**

We are going to use the AWS SDK to cryptographically generate a mathematical proof of our identity, without ever asking the internet for a password.

Create `generate-token.js`:

```JavaScript
import { Signer } from "@aws-sdk/rds-signer";

// THE MAGIC GENERATOR: Creates a temporary token using local EC2/Pod metadata
async function getTemporaryIAMToken() {
  const signer = new Signer({
    hostname: "db-cluster.us-east-1.rds.amazonaws.com",
    port: 5432,
    region: "us-east-1",
    username: "iam_db_user",
  });

  const token = await signer.getAuthToken();
  console.log("Your temporary DB password is:\n");
  console.log(token);
}

getTemporaryIAMToken();
```

**2. The Execution**

```Bash
node generate-token.js
```

**3. The Validation Test**

1. Run the script.
2. Look at the output. You won't see a standard password. You will see a massive URL string signed via SigV4.
3. Notice the `X-Amz-Date` and `X-Amz-Expires=900` parameters—this proves the password self-destructs in 900 seconds (15 minutes).

**Your Task:**

Look at the output string.
**How does the database driver use this**? (It passes this entire giant string into the `password` field of your DB connection object).

**Paste the output showing the generated token.**

**Output:**

```Plaintext
Your temporary DB password is:

db-cluster.us-east-1.rds.amazonaws.com:5432/?Action=connect&DBUser=iam_db_user&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIOSFODNN7EXAMPLE%2F20260313%2Fus-east-1%2Frds-db%2Faws4_request&X-Amz-Date=20260313T124735Z&X-Amz-Expires=900&X-Amz-SignedHeaders=host&X-Amz-Signature=aee...
```
