**Week 6, Day 41: S3 (The Infinite Hard Drive)**

**The Scenario:** Servers are disposable. If you terminate your instance, the data on it is gone (unless you use EBS volumes carefully).
For long-term storage (backups, user uploads, logs), we use Amazon S3 (Simple Storage Service).
It is "Object Storage". Think of it as a Google Drive that you control with code.

---

**Day 41 Mission: The Cloud Drop**

We will use Terraform to create a private "Bucket" and upload a file to it.

**1. Create a Test File**
Create a text file named `my-data.txt` in your `aws-lab` folder.
Content: `This is critical data saved in the cloud.`

**2. Update main.tf**
Add these new resources to your file.

- **Important:** S3 Bucket names must be globally unique across all of AWS (like a Gmail username). You cannot use `my-test-bucket`. You must add random numbers or your name.

```Terraform
# 1. Random String Generator (To ensure unique bucket name)
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 2. The Bucket
resource "aws_s3_bucket" "my_bucket" {
  # Name will be like: devops-lab-a1b2c3d4
  bucket = "devops-lab-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# 3. The Upload
resource "aws_s3_object" "file_upload" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "uploaded-data.txt"            # The filename IN the bucket
  source = "${path.module}/my-data.txt"   # The filename ON your laptop
}

# 4. Output the Bucket Name
output "bucket_name" {
  value = aws_s3_bucket.my_bucket.id
}
```

**3. Apply**
Run `terraform init` (since we added the `random` provider).
Run `terraform apply -auto-approve`.

**4. The Verification**
Terraform will output the bucket name (e.g., `devops-lab-f3e2a1b9`).
We will use the AWS CLI to check if the file is really there.

**Your Task:**

1. Run the apply command.
2. Copy your specific bucket name from the output.
3. Run this command in your terminal:

```Bash
aws s3 ls s3://<YOUR_BUCKET_NAME>
```

**Paste the output of the `aws s3 ls` command.**

**Answer:** `2026-03-02 22:43:44         41 uploaded-data.txt`
