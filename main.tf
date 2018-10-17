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

data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name = "main"
  }
}

resource "aws_subnet" "app" {
  cidr_block = "192.168.2.0/24"
  vpc_id     = "${aws_vpc.main.id}"

  tags {
    Name = "app"
  }
}

resource "aws_subnet" "rds" {
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  cidr_block        = "192.168.${length(data.aws_availability_zones.available.names) + count.index}.0/24"
  count             = "${length(data.aws_availability_zones.available.names)}"
  vpc_id            = "${aws_vpc.main.id}"

  tags {
    Name = "rds-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "postgres"
  subnet_ids = ["${aws_subnet.rds.*.id}"]
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "main"
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "main"
  }
}

resource "aws_route_table_association" "app" {
  subnet_id      = "${aws_subnet.app.id}"
  route_table_id = "${aws_route_table.main.id}"
}

resource "aws_security_group" "app" {
  name        = "app"
  description = "Allow SSH, HTTP inbound traffic for application"
  vpc_id      = "${aws_vpc.main.id}"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "app"
  }
}

resource "aws_security_group" "rds" {
  name        = "rds"
  description = "Allow Postgres traffic inbound traffic only from application"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["${aws_security_group.app.id}"]
  }

  tags {
    Name = "rds"
  }
}

resource "aws_key_pair" "main" {
  key_name   = "${var.aws_key_name}"
  public_key = "${file("${var.ssh_public_key_path}")}"
}

resource "aws_instance" "app" {
  ami                         = "${data.aws_ami.debian9.id}"
  associate_public_ip_address = true
  instance_type               = "${var.aws_app_instance_type}"
  key_name                    = "${aws_key_pair.main.id}"
  subnet_id                   = "${aws_subnet.app.id}"
  vpc_security_group_ids      = ["${aws_security_group.app.id}"]

  tags {
    Name = "app"
  }

  provisioner "remote-exec" {
    inline = ["# Connected!"]

    connection {
      user        = "${var.ssh_username}"
      private_key = "${file("${var.ssh_private_key_path}")}"
    }
  }
}

resource "aws_db_instance" "postgres" {
  allocated_storage         = "${var.aws_rds_allocated_storage}"
  db_subnet_group_name      = "${aws_db_subnet_group.rds.name}"
  engine                    = "postgres"
  engine_version            = "10.5"
  instance_class            = "${var.aws_rds_instance_class}"
  username                  = "${var.aws_rds_username}"
  password                  = "${var.aws_rds_password}"
  storage_type              = "gp2"
  skip_final_snapshot       = true
  final_snapshot_identifier = "Ignore"
  vpc_security_group_ids    = ["${aws_security_group.rds.id}"]

  tags {
    Name = "rds"
  }
}
