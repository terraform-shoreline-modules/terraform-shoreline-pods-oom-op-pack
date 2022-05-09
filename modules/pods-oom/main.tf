################################################################################
# Module: pods_oom
#
# The Pods OOM Op Pack monitors kubernetes pods. Whenever any pod on cluster
# restart with oom on node, pods details are automatically collected and pushed
# to slack chnanel using incoming webhook.
#
# Example usage:
#
# module "pods-oom" {
#  # Location of the module
#  source = "terraform-shoreline-modules/pods-oom/shoreline//modules/pods-oom"
#
#  # Frequency to evaluate alarm conditions in seconds
#  check_interval = 60
#
#  # http endpoint of slack incoming webhook.
#  # https://slack.com/help/articles/115005265063-Incoming-webhooks-for-Slack#set-up-incoming-webhooks
#  slack_url =  "https://hooks.slack.com/services/[insert webhook url]"
#
#  #Time in seconds for that oom pods are checked.
#  aggregation_time = 60
#
#  # Prefix to allow multiple instances of the module, with different params
#  prefix = "pods_oom_example_"
#
#  # Resource query to select the affected resources
#  resource_query = "pods | app='shoreline'"
#
#  # Destination of the oom-pods, and update slack scripts on the selected resources
#  script_path = "/tmp"
#
# }
#
################################################################################


terraform {
  # Setting 0.13.1 as the minimum version. Older versions are missing significant features.
  required_version = ">= 0.13.1"
}

#provider "shoreline" {
#  # provider configuration here
#  retries = 2
#  debug = true
#}
