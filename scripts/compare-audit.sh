#!/bin/bash
npm_audit_report=${NPM_AUDIT_REPORT:-npm-audit-report.json}
ack_file=${ACK_FILE:-acknowledged-npm-vulnerabilities.json}

find_effects() {
  names=$1
  for name in $names; do
    echo $name
    effects=$(jq -r --arg name "$name" '.vulnerabilities | to_entries[] | select(.value.name == $name) | .value.effects[]' "$npm_audit_report")
    echo $(find_effects $effects)
  done
}

service_name=$1
path=$2
echo "Running npm audit for $service_name service located at $path"
cd $path

npm ci --silent

npm audit --json > "$npm_audit_report"

# Check if ack_file exists
if [ ! -f "$ack_file" ]; then
  echo "Acknowledged vulnerabilities file $ack_file not found."
  exit 1
fi

# Extract acknowledged vulnerability IDs
ack_ids=$(jq -r '.acknoledgedVulnerabilities[] | to_entries[] | .key' "$ack_file")

# Extract current vulnerabilities names
current_vuln_names=$(jq -r '.vulnerabilities | to_entries[] | .value.via[] | select(type == "object") | .name' "$npm_audit_report")

# Find new, unacknowledged vulnerabilities
new_vulns=0
vulnerability_msg="⚠️ New Unacknowledged Vulnerabilities Detected for $service_name service:

"
for name in $current_vuln_names; do
  id=$(jq -r --arg name "$name" '.vulnerabilities | to_entries[] | .value.via[] | if type == "object" and .name == $name then .source else empty end' "$npm_audit_report")
  dependency=$(jq -r --arg name "$name" '.vulnerabilities | to_entries[] | .value.via[] | if type == "object" and .name == $name then .dependency else empty end' "$npm_audit_report")
  title=$(jq -r --arg name "$name" '.vulnerabilities | to_entries[] | .value.via[] | if type == "object" and .name == $name then .title else empty end' "$npm_audit_report")
  url=$(jq -r --arg name "$name" '.vulnerabilities | to_entries[] | .value.via[] | if type == "object" and .name == $name then .url else empty end' "$npm_audit_report")
  severity=$(jq -r --arg name "$name" '.vulnerabilities | to_entries[] | .value.via[] | if type == "object" and .name == $name then .severity else empty end' "$npm_audit_report")
  effects=$(jq -r --arg name "$name" '.vulnerabilities | to_entries[] | select(.value.name == $name) | .value.effects[]' "$npm_audit_report")
  all_effects=$(find_effects $effects)

  if [ ${#all_effects[@]} -eq 0 ] || [ -z "${all_effects[0]}" ]; then
    used="Package is used at root level"
  else
    used="Package is used in:"
    for effect in $all_effects; do
      used+=" $effect"
    done
  fi

  case "$severity" in
    low)
      severity=":large_green_circle: $severity :large_green_circle:"
      ;;
    moderate)
      severity=":large_yellow_circle: $severity :large_yellow_circle:"
      ;;
    high)
      severity=":large_orange_circle: $severity :large_orange_circle:"
      ;;
    critical)
      severity=":large_red_circle: $severity :large_red_circle:"
      ;;
    *)
      ;;
  esac
  if ! echo "$ack_ids" | grep -q "$id"; then
    new_vulns=1
    vulnerability_msg+="• $title (id: $id):
    - Package name: $name.
    - Severity: $severity.
    - $used.
    - More information can be found here: $url.
"
  fi
done

# Format Slack message
if [ "$new_vulns" -eq 0 ]; then
  msg="✅ No new vulnerabilities found for $service_name service."
  payload=$msg
else
  payload=$vulnerability_msg
fi

echo $payload

# Send Slack message
if [ -z "$SLACK_BOT_TOKEN" ] || [ -z "$SLACK_TECH_TEAM_CHANNEL_ID" ]; then
  echo "SLACK_BOT_TOKEN or SLACK_TECH_TEAM_CHANNEL_ID is not set. Skipping Slack notification."
else
  curl -X POST $SLACK_API_URL \
    -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
    -H "Content-type: application/json; charset=utf-8" \
    --data "$(jq -n \
      --arg channel "$SLACK_TECH_TEAM_CHANNEL_ID" \
      --arg text "$payload" \
      '{channel: $channel, text: $text}')"
fi
cd ..
