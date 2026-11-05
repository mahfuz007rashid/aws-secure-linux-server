# Restore runbook: secure-linux server

## Purpose
Restore the Linux server from an AWS Backup recovery point after data loss.

## Prerequisites
- Access to the AWS console with permission to use AWS Backup and EC2
- Vault name and the recovery point to restore

## Steps
1. Open AWS Backup, Vaults, select the vault, select the recovery point.
2. Choose Restore and set: private subnet, server security group,
   instance profile, and the backup role.
3. Wait for the restore job to show Completed.
4. Connect with Session Manager and verify the data.
5. Update monitoring and documentation if the instance ID changed.

## Test results
| Date | Backup duration | Restore duration | Result |
| --- | --- | --- | --- |
| 5 Nov 2026 | 4 min 4 sec | 1 min (restore job), plus a few minutes before Session Manager connected | Success: marker file recovered with identical contents | the job finished about 13:37, and you were connected by 13:45 after checking the instance details

## Lessons learned
- AWS Backup restore defaults point at the default VPC, so the private subnet, server security group, instance profile and backup role had to be chosen by hand.
- The restored server keeps the original's tags, so both instances were named secure-linux-server. Instance ID is the only reliable way to tell them apart.
- The restored server is not managed by Terraform and must be terminated manually before terraform destroy.
- A misspelled file name in my delete check returned a "success" message for the wrong reason. Confirm deletion using the exact file name.