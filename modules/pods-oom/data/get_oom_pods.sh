#!/bin/bash
# first argument is the Frequency in seconds to check the alarm. 
# Fail on a single failed command in a pipeline

set -o pipefail

check_interval_sec=$1

deletion_ts=$(date -d'now-'"$check_interval_sec"' seconds' -Ins --utc | sed 's/+0000/Z/') 

# Function to get oom  pods on node and return count.

check_oom_pods(){
count=$(kubectl get pod -A -o go-template --template='{{range .items}} {{"\n"}} {{.metadata.name}} {{range .status.containerStatuses}}{{if .lastState.terminated.reason }}{{.lastState.terminated.reason}} {{ .lastState.terminated.finishedAt }}{{end}}{{end}}{{end}}' --field-selector spec.nodeName=$NODE_NAME | grep OOMKilled | awk '$3 >= "'$deletion_ts'"' | wc -l)
echo "$count"
}
check_oom_pods
 