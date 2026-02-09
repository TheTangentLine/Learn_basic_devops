**Week 6, Day 38: Your First Cloud Server (EC2)**

**The Scenario:** You have credentials. Now you want a server. In AWS, a server is called an EC2 Instance (Elastic Compute Cloud). We will use Terraform to spawn a real Ubuntu server in the us-east-1 region.

---

**Day 38 Mission: Launching into Orbit**

**1. Create the Directory** Create a new folder `aws-lab`. Inside, create `main.tf`.

**2. The Provider** Tell Terraform we are using AWS now, not Docker.

```Terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

**3. The Server Resource** Add this to `main.tf`.

- **AMI:** This is the "Image" (like the ISO file). The ID below is for Ubuntu 22.04 in `us-east-1`.
- **Instance Type:** `t2.micro` (This is the specific size that is eligible for the Free Tier).

```Terraform
resource "aws_instance" "my_server" {
  ami           = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS (us-east-1)
  instance_type = "t2.micro"

  tags = {
    Name = "DevOps-Day38"
  }
}

output "public_ip" {
  value = aws_instance.my_server.public_ip
}
```

**4. Init and Apply**

```Bash
terraform init
terraform apply
```

- Type `yes` when prompted.
- Wait about 30-60 seconds.

**5. The Verification** Terraform will print the `public_ip` at the end.

**Your Task:**

1. Run the apply command.
2. Copy the IP address output.
3. **IMPORTANT:** Immediately run `terraform destroy` after you copy the IP.
   - _Why?_ Even though `t2.micro` is free, if you leave it running for 750+ hours or launch multiple, you will be charged. **Always clean up your lab.**

**Paste the Public IP you received.**

**Answer:**

```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

public_ip = "54.196.22.105"
```
