# Pods OOM Op Pack

<table role="table" style="vertical-align: middle;">
  <thead>
    <tr style="background-color: #fff">
      <th style="padding: 6px 13px; border: 1px solid #B1B1B1; text-align: center;" colspan="3">Provider Support</th>
    </tr>
  </thead>
  <tbody>
    <tr style="background-color: #E2E2E2">
      <td style="padding: 6px 13px; border: 1px solid #B1B1B1; text-align: center;">AWS</td>
      <td style="padding: 6px 13px; border: 1px solid #B1B1B1; text-align: center;">Azure</td>
      <td style="padding: 6px 13px; border: 1px solid #B1B1B1; text-align: center;">GCP</td>
    </tr>
    <tr>
      <td style="padding-top: 6px; vertical-align: bottom; border: 1px solid #B1B1B1; text-align: center;"><svg xmlns="http://www.w3.org/2000/svg" style="width: 1.5rem; height: 1.5rem;" fill="none" viewBox="0 0 24 24" stroke="#6CB169"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" /></svg></td>
      <td style="padding-top: 6px; vertical-align: bottom; border: 1px solid #B1B1B1; text-align: center;"><svg xmlns="http://www.w3.org/2000/svg" style="width: 1.5rem; height: 1.5rem;" fill="none" viewBox="0 0 24 24" stroke="#6CB169"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" /></svg></td>
      <td style="padding-top: 6px; vertical-align: bottom; border: 1px solid #B1B1B1; text-align: center;"><svg xmlns="http://www.w3.org/2000/svg" style="width: 1.5rem; height: 1.5rem;" fill="none" viewBox="0 0 24 24" stroke="#6CB169"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" /></svg></td>
    </tr>
  </tbody>
</table>

The Pods OOM Op Pack monitors kubernetes pods. Whenever any pod on cluster restart with oom on node, pods details are automatically collected and pushed to slack chnanel using incoming webhook.

Collected data includes:

1. Pod Name
1. Pod Namespace
1. Node Name
1. Terminated Time
1. Pod Logs

## Usage

The following example monitors all pods in cluster. Whenever a pod's have oom event it sends pods details to slack channel using incoming webhook URL.

```hcl
terraform {
  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.1.3"
    }
  }
}

provider "shoreline" {
  # provider configuration here
  debug   = true
  retries = 2
  url     = "<SHORELINE_CLUSTER_API_ENDPOINT>"
}

module "pods-oom" {
  # Location of the module
  source = "terraform-shoreline-modules/pods-oom/shoreline//modules/pods-oom"

  # Frequency to evaluate alarm conditions in seconds
  check_interval = 60

  # http endpoint of slack incoming webhook.
  # https://slack.com/help/articles/115005265063-Incoming-webhooks-for-Slack#set-up-incoming-webhooks
  slack_url = "https://hooks.slack.com/services/[insert webhook url]"

  # Time in seconds for that oom pods are checked.
  aggregation_time = 60

  # Prefix to allow multiple instances of the module, with different params
  prefix = "pods_oom_example_"

  # Resource query to select the affected resources
  resource_query = "pods | app='shoreline'"

  # Destination of the oom-pods, and update slack scripts on the selected resources
  script_path = "/tmp"

}
```

## Manual command examples

These commands use Shoreline's expressive [Op language](https://docs.shoreline.io/op) to retrieve fleet-wide data using the generated actions from the Pods OOM module.

-> These commands can be executed within the [Shoreline CLI](https://docs.shoreline.io/installation#cli) or [Shoreline Notebooks](https://docs.shoreline.io/ui/notebooks).

### Force data collection for a given time range.

```
op> pods | app='shoreline' | pods_oom_oom_pods_counts('600')
```

-> See the [shoreline_action resource](https://registry.terraform.io/providers/shorelinesoftware/shoreline/latest/docs/resources/action) and the [Shoreline Actions](https://docs.shoreline.io/actions) documentation for details.

### Force data collection for a given time range, on a single (arbitrary) pod

```
op> pods | app='shoreline' | limit=1 | pods_oom_oom_pods_counts('60')
```

### Manually check oom pods on a set of nods

```
op> pods | app='shoreline' | pods_oom_oom_pods_counts('60')
 ID  | TYPE      | NAME                                 | REGION    | AZ         | STATUS | STDOUT
 51  | CONTAINER | shoreline.shoreline-2tb2c.shoreline  | centralus | ---        |   0    | 0
     |           |                                      |           |            |        |
 77  | CONTAINER | shoreline2.shoreline-4jkfc.shoreline | us-west-2 | us-west-2c |   0    | 0
     |           |                                      |           |            |        |
```
### List triggered Pods OOM Alarms

```
op> events | alarm_name =~ 'oom'

 RESOURCE_ID | RESOURCE_NAME              | RESOURCE_TYPE | ALARM_NAME                     | STATUS   | STEP_TYPE   | TIMESTAMP                 | DESCRIPTION
 26          | shoreline.shoreline-rjwrp  | POD           | pods_oom_check_pods_oom_alarms | resolved |             |                           | Alarm on when there is a one or more pod with oom condition on node.
             |                            |               |                                |          | ALARM_FIRE  | 2022-05-04T05:43:42-07:00 | There are pods with oom condition on node.
             |                            |               |                                |          | ALARM_CLEAR | 2022-05-04T05:44:40-07:00 | There are no pods with oom condition on node.
```

-> See the [Shoreline Events documentation](https://docs.shoreline.io/op/events) for details.
