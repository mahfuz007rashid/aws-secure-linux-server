"""Check that the newest AWS Backup recovery point is recent enough."""
import argparse
import datetime
import sys

import boto3


def newest_recovery_point(vault_name, region):
    client = boto3.client("backup", region_name=region)
    points = []
    paginator = client.get_paginator("list_recovery_points_by_backup_vault")
    for page in paginator.paginate(BackupVaultName=vault_name):
        points.extend(p for p in page["RecoveryPoints"] if p["Status"] == "COMPLETED")
    if not points:
        return None
    return max(points, key=lambda p: p["CreationDate"])


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--vault", required=True)
    parser.add_argument("--region", default="ap-southeast-2")
    parser.add_argument("--max-age-hours", type=float, default=26)
    args = parser.parse_args()

    latest = newest_recovery_point(args.vault, args.region)
    if latest is None:
        print("FAIL: no completed recovery points found")
        return 1

    now = datetime.datetime.now(datetime.timezone.utc)
    age_hours = (now - latest["CreationDate"]).total_seconds() / 3600
    created_utc = latest["CreationDate"].astimezone(datetime.timezone.utc)
    print(f"Latest backup: {created_utc:%Y-%m-%d %H:%M UTC} ({age_hours:.1f} hours old)")

    if age_hours > args.max_age_hours:
        print(f"FAIL: older than {args.max_age_hours} hours")
        return 1
    print("OK: backup is recent")
    return 0


if __name__ == "__main__":
    sys.exit(main())