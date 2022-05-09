terraform {
  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.0.7"
    }
  }
}

locals {
  prefix             = "test_oom_"
}

module "oom_pods" {
  source = "../"
  prefix = "${local.prefix}"
  resource_query = "host| pods | app='shoreline'"
  # check more frequently to speed up test
  check_interval = 60
  script_path = "/agent/scripts"
  # https://slack.com/help/articles/115005265063-Incoming-webhooks-for-Slack#set-up-incoming-webhooks
  slack_url = "https://hooks.slack.com/services/[insert webhook url]"
  aggregation_time = 60
}

# copy script to resources for crating oom pods on k8s cluster.
resource "shoreline_file" "create_oom_pods" {
  name             = "create_oom_pods"
  description      = "Script to create oom pods on k8s cluster."
  input_file       = "${path.module}/test_oom_pods.sh"
  destination_path = "/agent/scripts/test_oom_pods.sh"
  resource_query   =   "host| pods | app='shoreline'"
  enabled          = true
}
