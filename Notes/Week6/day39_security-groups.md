**Week 6, Day 39: Security Groups & SSH (The Keys)**

**The Scenario:** You created a server yesterday, but it was useless. You couldn't log in.

Two things blocked you:

1. **No Key:** You didn't give the server a public key, so it rejected your passwordless entry.

2. **The Firewall:** AWS blocks all incoming traffic by default.

We need to punch a hole in the firewall (Security Group) and upload your key.

---

**Day 39 Mission: The Secure Login**

**1. Generate a Key Pair (Locally)**
You need a key on your laptop first.
Run this in your `aws-lab` terminal:

```Bash
ssh-keygen -t ed25519 -f mykey -N ""
```

This creates two files: `mykey` (Private) and `mykey.pub` (Public).

**2. Update** `main.tf`
We will add three things:

1. **Upload the Key:** Tell AWS about `mykey.pub`.

2. **Create the Firewall:** Allow Port 22 (SSH) and 80 (HTTP).

3. **Update the Server:** Attach the Key and the Firewall to the instance.

Overwrite your `main.tf` with this:

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

# 1. THE KEY PAIR
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("${path.module}/mykey.pub")
}

# 2. THE SECURITY GROUP (Firewall)
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"

  # Inbound Rules (Ingress)
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to the world (For lab only!)
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Rules (Egress) - Allow server to talk to the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. THE SERVER
resource "aws_instance" "my_server" {
  ami           = "ami-0c7217cdde317cfec" # Ubuntu 22.04 (us-east-1)
  instance_type = "t2.micro"

  # ATTACHMENTS
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  tags = {
    Name = "DevOps-Day39"
  }
}

output "public_ip" {
  value = aws_instance.my_server.public_ip
}
```

**3. Apply & Connect**

1. Run `terraform apply -auto-approve`.

2. Copy the new `public_ip`.

3. Connect using the private key (`mykey`) you generated in step 1.

```Bash
ssh -i mykey ubuntu@<YOUR_PUBLIC_IP>
```

**Your Task:**

1. Run the SSH command.

2. If it asks "Are you sure...", type `yes`.

3. You should see the prompt change to `ubuntu@ip-172-xx-xx-xx:~$`.

4. Run `whoami` on the remote server.

**Paste the output of the `whoami` command.**

**Answer:** `ubuntu`
