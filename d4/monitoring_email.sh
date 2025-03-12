#!/bin/bash

host="localhost"
port=5000
log_file="/var/log/automate_server.log"
alert_email="tanishanikose083@gmail.com"
threshold=3
retry_interval=1
failure_count=0
timestamp=$(date)
failure_count_file="/tmp/server_failure_count"


if [ -f "$failure_count_file" ]; then
    failure_count=$(cat "$failure_count_file")
else
    failure_count=0
fi

send_alert() {
    timestamp=$(date)
    echo -e "Subject: Server Down Alert\n\nHello, $host:$port is down after $threshold failures." | msmtp -a mail "$alert_email" 2>&1 | tee -a "$log_file"

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
                        send_alert
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
