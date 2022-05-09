# Push the script that get  OOM  pods on node.
resource "shoreline_file" "get_oom_pods_count_script" {
  name = "oom_pods_get_script"
  description = "Script to get number of oom pods."
  input_file = "${path.module}/data/get_oom_pods.sh"  # source file (relative to this module)
  destination_path = "${var.script_path}/get_oom_pods.sh" # where it is copied to on the selected resources
  resource_query = "${var.resource_query}" # where it is copied to on the selected resources
  enabled = true
}

# Push the script that send OOM pods details to slack channel.
resource "shoreline_file" "fix_oom_pods_count_script" {
  name = "oom_pods_fix_script"
  description = "Script to update slack with oom pods details."
  input_file = "${path.module}/data/update_slack.sh" # source file (relative to this module)
  destination_path = "${var.script_path}/update_slack.sh" # where it is copied to on the selected resources
  resource_query = "${var.resource_query}" # where it is copied to on the selected resources
  enabled = true
}