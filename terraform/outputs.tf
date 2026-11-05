output "instance_id" {
  value =  aws_instance.server.id
}

output "instance_arn" {
  value = aws_instance.server.arn
}

output "vault_name" {
  value = aws_backup_vault.main.name
}

output "backup_role_arn" {
  value = aws_iam_role.backup.arn
}