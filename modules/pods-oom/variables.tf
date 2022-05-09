variable "prefix" {
  type        = string
  description = "A prefix to isolate multiple instances of the module with different parameters."
}

variable "resource_query" {
  type        = string
  description = "The set of hosts/pods/containers monitored and affected by this module."
}

variable "check_interval" {
  type        = number
  description = "Frequency, in seconds, to check the OOM pods on nodes."
  default     = 60
}

variable "script_path" {
  type        = string
  description = "Destination (on selected Resources) to store shell scripts."
  default     = "/agent/scripts"
}

variable "aggregation_time" {
  type        = number
  description = "Period of time, in seconds, that OOM pods are checked."
  default     = 120
}

variable "slack_url" {
  type = string
  # https://slack.com/help/articles/115005265063-Incoming-webhooks-for-Slack#set-up-incoming-webhooks
  description = "Incoming Slack webhook URL where OOM pods details are sent."
}
