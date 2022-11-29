# ---------------------------------------------------------------------
# Variables

variable "vpc_main_id" {}
variable "public_subnet_a_id" {}
variable "public_subnet_c_id" {}
variable "private_subnet_a_id" {}
variable "private_subnet_c_id" {}
variable "nat_gateway_a" {}

# ---------------------------------------------------------------------
# output

output "private_ec2_a_id" {
  value = aws_instance.private_ec2_a.id
}

output "private_ec2_c_id" {
  value = aws_instance.private_ec2_c.id
}

# ---------------------------------------------------------------------
# EC2 instance

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "public_ec2_a" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.nano"
  subnet_id              = var.public_subnet_a_id
  vpc_security_group_ids = [aws_security_group.sg_public_ec2.id]
  key_name               = aws_key_pair.ssh_key.id
  user_data              = templatefile("./modules/ec2/user_data.sh", { subnet = "A", info = "Public" })
  tags = {
    Name = "example-ec2-public_a"
  }
}

resource "aws_instance" "public_ec2_c" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.nano"
  subnet_id              = var.public_subnet_c_id
  vpc_security_group_ids = [aws_security_group.sg_public_ec2.id]
  key_name               = aws_key_pair.ssh_key.id
  user_data              = templatefile("./modules/ec2/user_data.sh", { subnet = "C", info = "Public" })
  tags = {
    Name = "example-ec2-public_c"
  }
}

resource "aws_instance" "private_ec2_a" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.nano"
  subnet_id              = var.private_subnet_a_id
  vpc_security_group_ids = [aws_security_group.sg_private_ec2.id]
  key_name               = aws_key_pair.ssh_key.id
  user_data              = templatefile("./modules/ec2/user_data.sh", { subnet = "A", info = "Private" })
  tags = {
    Name = "example-ec2-private_a"
  }
  depends_on = [
    var.nat_gateway_a // Natを作成して通信経路を確保してからUserDataを流す
  ]
}

resource "aws_instance" "private_ec2_c" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.nano"
  subnet_id              = var.private_subnet_c_id
  vpc_security_group_ids = [aws_security_group.sg_private_ec2.id]
  key_name               = aws_key_pair.ssh_key.id
  user_data              = templatefile("./modules/ec2/user_data.sh", { subnet = "C", info = "Private" })
  tags = {
    Name = "example-ec2-private_c"
  }
  depends_on = [
    var.nat_gateway_a
  ]
}

# ---------------------------------------------------------------------
# Security Group

resource "aws_security_group" "sg_public_ec2" {
  name   = "example-sg-public-ec2"
  vpc_id = var.vpc_main_id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_security_group" "sg_private_ec2" {
  name   = "example-sg-private-ec2"
  vpc_id = var.vpc_main_id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

# ---------------------------------------------------------------------
# SSH Key
resource "aws_key_pair" "ssh_key" {
  key_name   = "example-key"
  public_key = file("./modules/ec2/example-key.pub")
}
