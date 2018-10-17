variable "aws_region" {
  description = "AWS Region for instances created"
  default     = "eu-central-1"
}

variable "aws_app_instance_type" {
  description = "Type of EC2 instances to be created"
  default     = "t2.micro"
}

variable "aws_rds_instance_class" {
  description = "Class of RDS instances to be created"
  default     = "db.t2.micro"
}

variable "aws_key_name" {
  description = "Name of ssh key to be created"
  default     = "app"
}

variable "ssh_public_key_path" {
  description = "Path to ssh public key used to be created this one on AWS"
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key_path" {
  description = "Path to ssh private key used to connect to instance"
  default     = "~/.ssh/id_rsa"
}

variable "ssh_username" {
  description = "SSH username to connect to instance"
  default     = "admin"
}

variable "aws_rds_allocated_storage" {
  description = "A size of storage to be allocated for a RDS"
  default     = "20"
}

variable "aws_rds_username" {
  description = "A master username of AWS RDS"
  default     = "master"
}

variable "aws_rds_password" {
  description = "A master password of AWS RDS"
  default     = "masterPass"
}
