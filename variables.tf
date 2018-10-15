variable "aws_region" {
  description = "AWS Region for instances created"
  default     = "eu-central-1"
}

variable "aws_vpc_cidr_block" {
  description = "AWS VPC CIDR block for instances"
  default     = "192.168.2.0/24"
}

variable "aws_instance_type" {
  description = "Type of EC2 instances to created"
  default     = "t2.micro"
}

variable "aws_ami_owner_id" {
  description = "Owner ID of AWS AMI's searching"
  default     = "379101102735"                    # Official Debian account
}

variable "aws_ami_filter_name" {
  description = "Name to search of AWS AMI's"
  default     = "debian-stretch-*"
}

variable "aws_key_name" {
  description = "Name of ssh key to create"
  default     = "app"
}

variable "ssh_public_key_path" {
  description = "Path to ssh public key used to create this one on AWS"
  default     = "~/.ssh/id_rsa.pub"
}
