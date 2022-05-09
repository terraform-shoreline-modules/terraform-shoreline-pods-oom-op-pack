# Action to report the oom pods on k8s node.
# Returns Count of oom pods on k8s node.
resource "shoreline_action" "get_oom_pods_count" {
  name = "${var.prefix}oom_pods_counts"
  description = "Get oom pods count on node"
  # Run the script and set res_env_var
  command = "`cd ${var.script_path} && chmod +x ./get_oom_pods.sh && COUNT=$(./get_oom_pods.sh $AGGREGATION_TIME) && echo $COUNT`"
  # Parameters passed in: the seconds to get oom pods in time period of given seconds.
  params = ["AGGREGATION_TIME" ]
  res_env_var = "COUNT"
  # Select the shell to run 'command' with.
  shell = "/bin/bash"


  # UI / CLI annotation informational messages:
  start_short_template    = "Getting oom pods count."
  error_short_template    = "Error getting oom pods count."
  complete_short_template = "Finished calculating oom pods count."
  start_long_template     = "Getting oom pods count on node for last ${var.aggregation_time } seconds."
  error_long_template     = "Error Getting oom pods count for last ${var.aggregation_time } seconds.."
  complete_long_template  = "Finished Getting oom pods count for last ${var.aggregation_time } seconds."

  enabled = true
}


resource "shoreline_action" "update_slack" {
  name = "${var.prefix}post_oom_pods_details_slack"
  description = "Update oom pods details to slack using incoming webhook."
  # Run the script to update slack channel with incoming webhook.
  command = "`cd ${var.script_path} && chmod +x ./update_slack.sh && ./update_slack.sh $AGGREGATION_TIME $SLACK_URL`"
  # Parameters 
     # AGGREGATION_TIME: time in seconds to get oom pods in time period of given seconds.
     # SLACK_URL:  slack incoming webhook endpoint where oom pods details will be send. 
  params = ["AGGREGATION_TIME", "SLACK_URL"]
  # Select the shell to run 'command' with.
  shell = "/bin/bash"


   # UI / CLI annotation informational messages:
  start_short_template    = "Sending oom pods details to slack"
  error_short_template    = "Error sending oom pods details to slack channel ."
  complete_short_template = "Successfully send oom pods details to slack channel."
  start_long_template     = "Sending oom pods details to slack channel using incoming webhook."
  error_long_template     = "Error sending oom pods details to slack channel using incoming webhook."
  complete_long_template  = "Successfully send oom pods details to slack channel using incoming webhook."
 
  enabled = true
}


