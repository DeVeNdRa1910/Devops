#!/bin/bash

slack_webhook_url="https://hooks.slack.com/services/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"
host_to_monitor="http://localhost:5050/api/books/get-all-books"
check_interval=10
log_file="/var/log/server_monitoring.log"

send_slack_notification(){
	local message="$1"
	curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$message\"}" "$slack_webhook_url" > /dev/null 2>&1
}

#function for cehcking, host is up or down
check_uptime(){
	local result
	local status_code

	result=$(curl -s -I "$host_to_monitor")
	status_code=$(echo $result | grep "^HTTP/" | awk '{print $2}')

	if [[ "$status_code" -ge 200 && "$status_code" -lt 300 ]]; then
		echo "$(date) - $host_to_monitor is UP, with status code $status_code" >> "$log_file"
	else
		echo "$(date) - $host_to_monitor is DOWN, with status code $status_code" >> "$log_file"
		send_slack_notification "*Warning:* $host_to_monitor is down!, with status code $status_code "
	fi
}

# we can run this loop till perticular number
while true; do
	check_uptime
	sleep "$check_interval"
done

