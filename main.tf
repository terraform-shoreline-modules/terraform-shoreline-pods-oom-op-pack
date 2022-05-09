# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these parameters/secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# SHORELINE_URL   - The API url for your shoreline cluster, i.e. "https://<customer>.<region>.api.shoreline-<cluster>.io"
# SHORELINE_TOKEN - The alphanumeric access token for your cluster. (Typically from Okta.)

terraform {
  # Setting 0.13.1 as the minimum version. Older versions are missing significant features.
  required_version = ">= 0.13.1"

  #required_providers {
  #  shoreline = {
  #    source  = "shorelinesoftware/shoreline"
  #    version = ">= 1.1.0"
  #  }
  #}
}

# Example instantiation of the Pods OOM OpPack:
module "pods_oom_example" {
  source = "./modules/pods-oom/"
  prefix = "pods_oom_"
  resource_query = "host| pods | app='shoreline'"
# check more frequently to speed up test
  check_interval = 60
  script_path = "/agent/scripts"
# https://slack.com/help/articles/115005265063-Incoming-webhooks-for-Slack#set-up-incoming-webhooks
  slack_url = "https://hooks.slack.com/services/[insert webhook url]"
  aggregation_time = 60
}
