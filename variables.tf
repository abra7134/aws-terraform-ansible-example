variable "aws_region" {
  description = "AWS Region for instances created"
  default     = "eu-central-1"
}

variable "aws_instance_type" {
  description = "Type of EC2 instances to created"
  default     = "t2.micro"
}

variable "aws_key_name" {
  description = "Name of ssh key to create"
  default     = "app"
}

variable "ssh_public_key_path" {
  description = "Path to ssh public key used to create this one on AWS"
  default     = "~/.ssh/id_rsa.pub"
}
