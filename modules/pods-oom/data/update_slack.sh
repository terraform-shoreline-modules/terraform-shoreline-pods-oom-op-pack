#!/bin/bash
# first argument is the time period in which you need to check the oom pods
# second argument is slack incoming webhook url in which details need to be shared . 
# Fail on a single failed command in a pipeline
set -o pipefail

aggregation_time=$1
slack_url=$2
updated_aggregation_time=$(date -d'now-'$aggregation_time' seconds' -Ins --utc | sed 's/+0000/Z/')

# Function to send oom pods details to slack channel.

update_slack(){

pods_details=$(kubectl get pod -A -o go-template --template='{{range .items}} {{"\n"}} {{.metadata.name}}  {{.metadata.namespace}} {{range .status.containerStatuses}}{{if .lastState.terminated.reason }}{{.lastState.terminated.reason}} {{ .lastState.terminated.finishedAt }} {{.lastState.terminated.message}} {{end}}{{end}}{{end}}' --field-selector spec.nodeName=$NODE_NAME  | grep OOMKilled  | awk '$4 >= "'$updated_aggregation_time'"')

if [ -n "$pods_details" ]; then

while IFS= read -r line ; do
   local namespace pod_name  terminated_time pod_log
   namespace=$(echo "$line" | awk '{ print $2 }')
   pod_name=$(echo "$line" | awk '{ print $1 }')
   terminated_time=$(echo "$line" | awk '{ print $4 }') 
   pod_log=$(kubectl logs "$pod_name" -n "$namespace" --previous --since "$aggregation_time"s | tr -d '\n' | tr -d  "'" | tr -d '"' | cut -c -3000 )
  
  status_code=$(curl -i  -X POST -H 'Content-type: application/json' --data '{
	"blocks": [
		{
			"type": "header",
			"text": {
				"type": "plain_text",
				"text": "Pod deleted with OOM",
				"emoji": true
			}
		},
		{
			"type": "section",
			"fields": [
				{
					"type": "mrkdwn",	
					"text": "*Pod Name:*\n'$pod_name'"
				},
				{
					"type": "mrkdwn",
					"text": "*Namespace:*\n'$namespace'"
				}
			]
		},
		{
			"type": "section",
			"fields": [
				{
					"type": "mrkdwn",
					"text": "*Node Name:*\n'$NODE_NAME'"
				},
				{
					"type": "mrkdwn",
					"text": "*Terminated Time:*\n'$terminated_time'"
				}
			]
		},
		{
			"type": "header",
			"text": {
				"type": "plain_text",
				"text": "Logs:",
				"emoji": true
			}
		},
		{
			"type": "section",
			"text": {
				"type": "plain_text",
				"text": "'"$pod_log"'",
				"emoji": true
			}
		}
	]
}' "$slack_url" |  head -n 1 | awk '{print $2}')


if [ "$status_code" == "200" ];
then
        printf "successfully update slack"
else
        printf -- "http status code: %s${status_code}"
        printf "Unable to Post message to slack, please check the slack_url "
        exit 127
fi 
done <<< "$pods_details"
fi
}
update_slack