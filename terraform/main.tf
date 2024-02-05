provider "aws" {
   region = "eu-central-1"
   access_key = var.aws_access_key
   secret_key = var.aws_secret_key
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "ssh_host" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    associate_public_ip_address = true
    security_groups = [aws_security_group.ssh_sg.name]
    user_data = <<EOF
#!/bin/bash
port=${var.ssh_port}
sed -i "s/#Port [0-9]\+/Port $port/g" /etc/ssh/sshd_config
systemctl restart sshd
EOF
}

resource "aws_security_group" "ssh_sg" {
  name = "ssh_sg"
  description = "sg to apply SSH rule"
  ingress {
      description      = "Custom SSH port to instance"
      from_port        = var.ssh_port
      to_port          = var.ssh_port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
}
