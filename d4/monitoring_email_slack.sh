#!/bin/bash

host="localhost"
port=5000
slack_webhook_url="https://hooks.slack.com/services/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"
check_url="http://localhost:5000/"
log_file="/var/log/automate_server.log"
alert_email="jaybantv@gmail.com"
retry_interval=5
failure_count=0
timestamp=$(date)
failure_count_file="/tmp/server_failure_count"
threshold=3
if [ -f "$failure_count_file" ]; then
    failure_count=$(cat "$failure_count_file")
else
    failure_count=0
fi

send_slack_alert(){
        local message="Warning: $check_url is DOWN!"
        local payload="{\"text\":\"${message}\"}"
        curl -X POST -H 'Content-type: application/json' --data "$payload" "$slack_webhook_url"> /dev/null 2>&1
}

send_email_alert() {
    timestamp=$(date)
    echo -e "Subject: Server Down Alert\n\nHello, $host:$port is down after 3 failures." | msmtp -a mail "$alert_email" 2>&1 | tee -a "$log_file"

    if [ $? -eq 0 ]; then
        echo "$timestamp: Email sent successfully" >> "$log_file"
    else
        echo "$timestamp: Failed to send email" >> "$log_file"
    fi
}

perform_check(){
    timeout 5 bash -c "echo > /dev/tcp/$host/$port" > /dev/null 2>&1

    if [ $? -ne 0 ] ; then
                failure_count=$((failure_count+1))
                echo "$failure_count" > "$failure_count_file"
                echo "$timestamp: $host:$port check failed ($failure_count failures)." >> "$log_file"
                if [ "$failure_count" -ge "$threshold" ] ; then
                        send_email_alert
			send_slack_alert 
                        failure_count=0
                fi
    else
                echo "0" > "$failure_count_file"
                #failure_count=0
                echo "$timestamp: $host:$port  is up. " >> "$log_file"
    fi
}

while true; do
        perform_check
        sleep "$retry_interval"
done
