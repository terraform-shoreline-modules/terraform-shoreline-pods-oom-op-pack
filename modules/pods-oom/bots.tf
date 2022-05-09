# Bot that fires the update_slack action when there are one or more pods with oom condition on node.
resource "shoreline_bot" "update_slack" {
  name        = "${var.prefix}update_slack"
  description = "Send oom pods details to slack using incoming webhook."
  command     = "if ${shoreline_alarm.check_node_oom_alarm.name} then ${shoreline_action.update_slack.name} ( '${var.aggregation_time}', '${var.slack_url}') fi"
  
  # general type of bot this can be "standard" or "custom"
  family = "custom"
  enabled     = true
}
