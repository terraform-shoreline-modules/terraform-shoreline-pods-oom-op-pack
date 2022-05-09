
# Alarm that triggers when there is pod with OOM condition on Kubernetes node.
resource "shoreline_alarm" "check_node_oom_alarm" {
  name = "${var.prefix}check_pods_oom_alarms"
  description = "Alarm on when there is a one or more pod with oom condition on node."
  # The query that triggers the Alarm: is there one or more pods with OOM condition on node.
  fire_query  = "${shoreline_action.get_oom_pods_count.name}('${var.aggregation_time}') >= 1"
  # The query that ends the Alarm when there are no pods with OOM condition on node.
  clear_query = "${shoreline_action.get_oom_pods_count.name}('${var.aggregation_time}') == 0"
  # How often is the Alarm evaluated. This is a more slowly changing metric, so every 60 seconds is fine.
  check_interval_sec = "${var.check_interval}"
  # User-provided resource selection
  resource_query = "${var.resource_query}"

  # UI / CLI annotation informational messages:
  fire_short_template = "There are pods with OOM condition on node."
  resolve_short_template = "There are no pods with OOM condition on node."
  fire_long_template = "There are pods with OOM condition on node for last ${var.aggregation_time } seconds."
  resolve_long_template = "There are no pods with OOM condition on node for last ${var.aggregation_time } seconds."

  # low-frequency, and a linux command, so compiling won't help
  compile_eligible = false

  # Alarm is raised local to a resource (vs global)
  raise_for = "local"
  # raised on a linux command (not a standard metric)
  metric_name = "get_oom_pods_count"
  # threshold value
  condition_value = 1
  # fires when above the threshold
  condition_type = "above"
  # general type of Alarm ("metric", "custom", or "system check")
  family = "custom"

  enabled = true
}
