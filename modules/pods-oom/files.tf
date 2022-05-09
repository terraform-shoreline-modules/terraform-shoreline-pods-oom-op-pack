# Push the script that gets OOM pods on node.
resource "shoreline_file" "get_oom_pods_count_script" {
  name = "oom_pods_get_script"
  description = "Script to get number of OOM pods."
  input_file = "${path.module}/data/get_oom_pods.sh"  # source file (relative to this module)
  destination_path = "${var.script_path}/get_oom_pods.sh" # where it is copied to on the selected Resources
  resource_query = "${var.resource_query}" # which Resources to copy to
  enabled = true
}

# Push the script that sends OOM pod details to Slack channel.
resource "shoreline_file" "fix_oom_pods_count_script" {
  name = "oom_pods_fix_script"
  description = "Script to update Slack with OOM pods details."
  input_file = "${path.module}/data/update_slack.sh" # source file (relative to this module)
  destination_path = "${var.script_path}/update_slack.sh" # where it is copied to on the selected Resources
  resource_query = "${var.resource_query}" # which Resources to copy to
  enabled = true
}