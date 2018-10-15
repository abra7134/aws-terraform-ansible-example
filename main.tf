provider "aws" {
  region     = "eu-central-1"
  version    = "~> 1.40"
}

data "aws_ami" "debian9" {
  most_recent = true
  owners      = ["379101102735"] # Official Debian account

  filter {
    name   = "name"
    values = ["debian-stretch-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "app" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name = "Application VPC"
  }
}

resource "aws_subnet" "app" {
  vpc_id     = "${aws_vpc.app.id}"
  cidr_block = "192.168.2.0/24"

  tags {
    Name = "Application Subnet"
  }
}

resource "aws_internet_gateway" "app" {
  vpc_id = "${aws_vpc.app.id}"

  tags {
    Name = "Application Gateway"
  }
}

resource "aws_route_table" "app" {
  vpc_id = "${aws_vpc.app.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.app.id}"
  }

  tags {
    Name = "Application Public Subnet Route Table"
  }
}

resource "aws_route_table_association" "app" {
  subnet_id      = "${aws_subnet.app.id}"
  route_table_id = "${aws_route_table.app.id}"
}

resource "aws_security_group" "app" {
  name        = "app_ssh_http"
  description = "Allow SSH, HTTP inbound traffic"
  vpc_id      = "${aws_vpc.app.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "Application SG"
  }
}

resource "aws_key_pair" "app" {
  key_name   = "app"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_instance" "app" {
  ami                         = "${data.aws_ami.debian9.id}"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.app.id}"
  subnet_id                   = "${aws_subnet.app.id}"
  vpc_security_group_ids      = ["${aws_security_group.app.id}"]
  associate_public_ip_address = true

  tags {
    Name = "app1"
  }
}
