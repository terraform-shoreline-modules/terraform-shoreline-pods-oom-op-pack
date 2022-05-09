# Bot that fires the update_slack Action when there are one or more pods with OOM node conditions.
resource "shoreline_bot" "update_slack" {
  name        = "${var.prefix}update_slack"
  description = "Send OOM pod details to Slack using the incoming webhook."
  command     = "if ${shoreline_alarm.check_node_oom_alarm.name} then ${shoreline_action.update_slack.name} ( '${var.aggregation_time}', '${var.slack_url}') fi"
  
  # general type of bot this can be "standard" or "custom"
  family = "custom"
  enabled     = true
}
