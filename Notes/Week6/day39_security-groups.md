# Day 39: Security Groups & SSH (The Keys)

> **Goal**: Attach a key pair and a security group to your EC2 instance, then SSH in and run a command.
> **Prereqs**: Day 38 — a working Terraform project that provisions a bare EC2 instance.

## 1. Scenario & Why It Matters

Yesterday's server had a public IP but was completely unreachable. Two AWS defaults blocked you:

1. **No SSH public key was injected**, so password-less login had nothing to authenticate against (and EC2 disables passwords by default).
2. **All inbound traffic is denied** by default. Every EC2 instance is wrapped in at least one **Security Group** — a stateful virtual firewall — and you must explicitly open ports.

These are both *good* defaults. "Deny by default" is the opposite of what a home router does, and it's why a fresh EC2 isn't instantly hacked. But for the server to be useful, you need to:

- Upload a public key AWS will place in `~ubuntu/.ssh/authorized_keys`.
- Open port **22/TCP** so your laptop can reach `sshd`.
- Open port **80/TCP** for future web traffic.

## 2. Concept Deep-Dive

**Key pairs.** SSH uses asymmetric crypto: the instance stores your *public* key; your laptop proves identity with the matching *private* key. AWS never sees the private half.

**Security Groups (SGs).** A Security Group is a set of allow-rules attached to an ENI (network interface) on the instance. Key properties:

- **Stateful** — if you allow an inbound request, the reply is automatically allowed out. You only write one direction.
- **Allow-only** — there are no deny rules. Absence of a rule is the deny.
- **Ingress** rules control inbound traffic; **egress** rules control outbound. Default egress (in Terraform's `aws_security_group`) is none, so you must add one for the server to reach the internet.

```mermaid
flowchart LR
    Laptop[Your laptop] -->|TCP 22 - SSH| SG[Security Group: allow_ssh_http]
    Laptop -->|TCP 80 - HTTP| SG
    SG -->|ingress allow| ENI[Instance ENI]
    ENI --> EC2[EC2 Instance - Ubuntu]
    EC2 -->|egress 0.0.0.0/0| Internet[Internet / apt / ubuntu.com]
```

**The mental model:** the SG sits between the wider VPC network and the instance's network card. A packet that doesn't match an `ingress` rule is silently dropped.

For a production setup you would scope `cidr_blocks` to your office/VPN IP, not `0.0.0.0/0`.

## 3. Hands-On Mission

**1. Generate a local key pair**

```bash
ssh-keygen -t ed25519 -f mykey -N ""
```

This creates `mykey` (private) and `mykey.pub` (public) in `aws-lab/`.

**2. Overwrite `main.tf`** with key pair + SG + updated instance:

```hcl
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

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("${path.module}/mykey.pub")
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my_server" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"

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

**3. Apply and connect**

```bash
terraform apply -auto-approve
chmod 400 mykey
ssh -i mykey ubuntu@<YOUR_PUBLIC_IP>
```

Destroy when done: `terraform destroy -auto-approve`.

## 4. Your Task — Answer

**Q:** After SSH-ing in, run `whoami` on the remote server. Paste the output.

**Sample answer:**

```
ubuntu
```

**Why:** Ubuntu AMIs ship with a default login user named `ubuntu` (Amazon Linux uses `ec2-user`, Debian uses `admin`). AWS copies the public key you registered via `aws_key_pair` into `/home/ubuntu/.ssh/authorized_keys` during first boot. When `whoami` returns `ubuntu`, you've proven: the SG allows port 22, the key pair is attached correctly, and your private key matches — three separate pieces of plumbing are all working.

## 5. Q&A (Concepts Check)

**Q1: What does "stateful" mean for a Security Group?**
The SG tracks connection state. If you allow an inbound TCP SYN on port 22, the return packets from the instance are automatically allowed out, regardless of egress rules. You never have to write mirror rules for replies.

**Q2: Why is opening `0.0.0.0/0` on port 22 a bad idea in production?**
It exposes `sshd` to every IP on the internet. Bots constantly scan port 22 and try common usernames/passwords. Best practice: restrict to your office CIDR, use a bastion host, or replace SSH entirely with AWS Systems Manager Session Manager (no open ports).

**Q3: What is the difference between a Security Group and a Network ACL?**
Security Groups are **stateful** and attach to an ENI (instance-level). Network ACLs are **stateless** and attach to a subnet. NACLs can have both allow and deny rules and are evaluated before the SG. Most workloads rely on SGs and leave NACLs at their defaults.

**Q4: Why did we also add an egress rule? Isn't outbound usually open by default?**
It depends on the tool. The AWS Console creates an `allow all egress` rule automatically. Terraform's `aws_security_group` does **not** — if you omit `egress`, nothing can leave, including `apt-get update`. Always make egress explicit.

**Q5: What happens to SSH access if you regenerate `mykey.pub` and re-apply without rebuilding the instance?**
`aws_key_pair` can be replaced, but AWS only injects the public key at first boot via cloud-init. Existing instances keep their old `authorized_keys`. To rotate, you either update the file over SSH or taint/replace the instance.

## 6. Further Reading

- AWS docs: [Security groups for your VPC](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html)
- AWS docs: [Security groups vs network ACLs](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html)
- AWS docs: [Connect to your Linux instance with SSH](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html)
- Terraform registry: [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)
