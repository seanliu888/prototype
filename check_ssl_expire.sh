#!/usr/bin/env bash

# check_ssl_expire.sh
# Usage:
#   ./check_ssl_expire.sh domains.txt
#
# domains.txt example:
#   example.com
#   google.com
#   api.example.com:8443

set -u

DOMAIN_FILE="${1:-}"

if [ -z "$DOMAIN_FILE" ]; then
  echo "Usage: $0 <domain_file>"
  exit 1
fi

if [ ! -f "$DOMAIN_FILE" ]; then
  echo "File not found: $DOMAIN_FILE"
  exit 1
fi

WARN_DAYS=30
NOW_TS=$(date +%s)

printf "%-35s %-25s %-12s %-10s\n" "DOMAIN" "EXPIRE_TIME" "LEFT_DAYS" "STATUS"
printf "%-35s %-25s %-12s %-10s\n" "------" "-----------" "---------" "------"

while IFS= read -r line || [ -n "$line" ]; do
  # Skip blank lines and comments.
  domain=$(echo "$line" | xargs)
  [ -z "$domain" ] && continue
  [[ "$domain" =~ ^# ]] && continue

  host="${domain%%:*}"
  port="${domain##*:}"

  if [ "$host" = "$port" ]; then
    port=443
  fi

  expire_date=$(
    echo | timeout 10 openssl s_client \
      -servername "$host" \
      -connect "$host:$port" \
      2>/dev/null \
    | openssl x509 -noout -enddate 2>/dev/null \
    | cut -d= -f2
  )

  if [ -z "$expire_date" ]; then
    printf "%-35s %-25s %-12s %-10s\n" "$domain" "-" "-" "ERROR"
    continue
  fi

  expire_ts=$(date -d "$expire_date" +%s 2>/dev/null)

  if [ -z "$expire_ts" ]; then
    printf "%-35s %-25s %-12s %-10s\n" "$domain" "$expire_date" "-" "DATE_ERR"
    continue
  fi

  left_days=$(( (expire_ts - NOW_TS) / 86400 ))

  if [ "$left_days" -lt 0 ]; then
    status="EXPIRED"
  elif [ "$left_days" -le "$WARN_DAYS" ]; then
    status="WARNING"
  else
    status="OK"
  fi

  printf "%-35s %-25s %-12s %-10s\n" "$domain" "$expire_date" "$left_days" "$status"
done < "$DOMAIN_FILE"
