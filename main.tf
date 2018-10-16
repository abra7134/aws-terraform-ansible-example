provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.40"
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
  cidr_block           = "${var.aws_vpc_cidr_block}"
  enable_dns_hostnames = true

  tags {
    Name = "Application VPC"
  }
}

resource "aws_subnet" "app" {
  vpc_id     = "${aws_vpc.app.id}"
  cidr_block = "${var.aws_vpc_cidr_block}"

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
  description = "Allow SSH, HTTP inbound traffic for application"
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
  key_name   = "${var.aws_key_name}"
  public_key = "${file("${var.ssh_public_key_path}")}"
}

resource "aws_instance" "app" {
  ami                         = "${data.aws_ami.debian9.id}"
  associate_public_ip_address = true
  instance_type               = "${var.aws_instance_type}"
  key_name                    = "${aws_key_pair.app.id}"
  subnet_id                   = "${aws_subnet.app.id}"
  vpc_security_group_ids      = ["${aws_security_group.app.id}"]

  tags {
    Name = "app1"
  }
}
