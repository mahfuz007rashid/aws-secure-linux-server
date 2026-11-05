resource "aws_backup_vault" "main" {
  name          = "${var.project_name}-vault"
  force_destroy = true
}

# Daily at 16:00 UTC, which is 3am in Sydney (AEDT). Keep 7 days.
resource "aws_backup_plan" "daily" {
  name = "${var.project_name}-daily"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 16 * * ? *)"

    lifecycle {
      delete_after = 7
    }
  }
}

data "aws_iam_policy_document" "backup_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "backup" {
  name               = "${var.project_name}-backup-role"
  assume_role_policy = data.aws_iam_policy_document.backup_assume.json
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# Restoring a server that has an instance profile needs PassRole
data "aws_iam_policy_document" "backup_passrole" {
  statement {
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.server.arn]
  }
}

resource "aws_iam_role_policy" "backup_passrole" {
  name   = "pass-server-role-on-restore"
  role   = aws_iam_role.backup.id
  policy = data.aws_iam_policy_document.backup_passrole.json
}

# Back up everything tagged Backup = true (the server has this tag)
resource "aws_backup_selection" "tagged" {
  name         = "tagged-servers"
  iam_role_arn = aws_iam_role.backup.arn
  plan_id      = aws_backup_plan.daily.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "true"
  }
}