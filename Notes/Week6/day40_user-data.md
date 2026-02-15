**Week 6, Day 40: User Data (The Automator)**

**The Scenario:** Logging in via SSH is cool, but manual work is bad.
If you launch 100 servers, you can't SSH into each one to install software.
AWS has a feature called **User Data**. It allows you to pass a shell script to the instance. The instance runs this script **once** immediately after it boots up (as `root`).

---

**Day 40 Mission: The Self-Installing Server**

**1. Create the Script**
Create a file named `install_apache.sh` in your `aws-lab` folder.
This script updates the OS, installs Apache, and writes a custom "Hello World" page.

```Bash
#!/bin/bash
apt-get update
apt-get install -y apache2
systemctl start apache2
systemctl enable apache2
echo "<h1>Deployed via Terraform on $(date)</h1>" > /var/www/html/index.html
```

**2. Update** `main.tf`
We need to tell the `aws_instance` resource to read this file.
Add the `user_data` argument to your existing `aws_instance` block.

```Terraform
resource "aws_instance" "my_server" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"

  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  # THE NEW LINE:
  user_data = file("${path.module}/install_apache.sh")

  tags = {
    Name = "DevOps-Day40"
  }
}
```

**3. Apply**
Run `terraform apply -auto-approve`.
_Note: If you already have a running instance, Terraform might say `forces replacement`. This is normal. It will kill the old one and spawn a fresh one with the new startup script._

**4. The Test**

1. Copy the new `public_ip`.

2. Wait about **60 seconds** after the apply finishes (booting + installing software takes time).

3. Open your browser and go to `http://<YOUR_PUBLIC_IP>`.

**Your Task:**

1. Visit the URL.
2. **Paste the text you see in the browser.** (It should contain the date).

**Answer:** `Deployed via Terraform on Wed Feb 4 02:15:43 +07 2026`
