#!/usr/bin/env bash
set -euo pipefail

INSTANCE_ID="${1:?Usage: $0 <instance-id>}"
REGION="${AWS_REGION:-ap-southeast-2}"

CMD_ID="$(aws ssm send-command \
  --region "$REGION" \
  --instance-ids "$INSTANCE_ID" \
  --document-name "AWS-RunShellScript" \
  --parameters '{"commands":["echo == Uptime ==","uptime","echo == Disk ==","df -h /","echo == Memory ==","free -m","echo == Failed services ==","systemctl --failed --no-legend || true"]}' \
  --query "Command.CommandId" --output text)"

sleep 2
aws ssm wait command-executed --region "$REGION" \
  --command-id "$CMD_ID" --instance-id "$INSTANCE_ID"

aws ssm get-command-invocation --region "$REGION" \
  --command-id "$CMD_ID" --instance-id "$INSTANCE_ID" \
  --query "StandardOutputContent" --output text