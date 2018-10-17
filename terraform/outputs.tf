output "app_address" {
  description = "Address of Application instance"
  value       = "${aws_instance.app.public_dns}"
}

output "postgres_address" {
  description = "Address of Postgres RDS"
  value       = "${aws_db_instance.postgres.address}"
}

output "postgres_username" {
  description = "Master username of Postgres SQL for administrative tasks"
  value       = "${var.aws_rds_username}"
}

output "postgres_password" {
  description = "Master password of Postgres SQL for administrative tasks"
  value       = "${var.aws_rds_password}"
}

output "ansible_ssh_private_key_file" {
  description = "SSH private key for Ansible"
  value       = "${var.ssh_private_key_path}"
}

output "ansible_ssh_user" {
  description = "SSH username for Ansible"
  value       = "${var.ssh_username}"
}
