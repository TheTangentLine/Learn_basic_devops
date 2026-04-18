**Week 6, Day 42: The Weekly Challenge (The Connected Stack)**

**The Scenario:**
You are building a photo processing application. You need a **Web Server** to receive photos and a **Storage Bucket** to save them.
Your challenge is to provision both of them in a single Terraform run.
**The Twist:** The Web Server needs to know the name of the bucket. Since the bucket name is random, you cannot hardcode it. You must inject it dynamically.

**Your Mission:**
Write a single `main.tf` that deploys:

1. **Network:** A Security Group allowing SSH (22) and HTTP (80).
2. **Storage:** A private S3 Bucket with a random suffix.
3. **Compute:** An EC2 Instance (Ubuntu t2.micro).
   - It must have the Security Group attached.
   - It must have a User Data script that installs Apache.
   - **Crucial:** The User Data script must write the **Bucket Name** into `index.html`.
     - _Expected index.html content:_ `<h1>Upload to: devops-lab-a1b2c3d4</h1>`

**Hint: Terraform Interpolation**
To use Terraform variables inside a multi-line string (like a script), use the <<-EOF syntax:

```Terraform
user_data = <<-EOF
  #!/bin/bash
  apt-get update
  apt-get install -y apache2
  systemctl start apache2
  systemctl enable apache2
  echo "<h1>Upload to: ${aws_s3_bucket.YOUR_BUCKET_RESOURCE_NAME.id}</h1>" > /var/www/html/index.html
  EOF
```

**Execute the mission.**
_(Note: Assume the `random_id` resource and a`ws_key_pair` exist or are part of your code)._

**Paste your full `main.tf` here.**
