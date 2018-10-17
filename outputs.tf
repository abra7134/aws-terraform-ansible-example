output "app_address" {
  description = "Address of Application instance"
  value       = "${aws_instance.app.public_dns}"
}

output "postgres_endpoint" {
  description = "Endpoint of Postgres"
  value       = "${aws_db_instance.postgres.endpoint}"
}

output "ansible_ssh_private_key_file" {
  description = "SSH private key for Ansible"
  value       = "${var.ssh_private_key_path}"
}

output "ansible_ssh_user" {
  description = "SSH username for Ansible"
  value       = "${var.ssh_username}"
}
