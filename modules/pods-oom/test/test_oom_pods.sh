#!/bin/bash

action=$1

# number of pods to keep in oom state:
pod_count=$2

create_oom_pods() {
  for (( i=1; i<=$pod_count; i++ )) do
    echo "Creating pod-${i} on ${nodeName}"
    kubectl  run ${i}  --image=polinux/stress --overrides='{
      "apiVersion": "v1",
      "kind": "Pod",
      "metadata": {
        "name": "'pod-${i}'"
      },
      "spec": {
        "containers": [
          {
            "name": "oom-pod",
            "image": "polinux/stress",
            "resources": {
              "requests": {
                "memory": "100Mi"
              },
              "limits": {
                "memory": "100Mi"
              }
            },
            "command": [
              "stress"
            ],
            "args": [
              "--vm",
              "1",
              "--vm-bytes",
              "50M",
              "--vm-hang",
              "1"
            ]
          }
        ]
      }
  }'

    # wait pod to create 
    sleep 3
    #create oom event on pods pod-${i}
    kubectl   exec -it  pod-${i}  -- bash -c "stress --vm 1 --vm-bytes 300M"
  done
}


drop_oom_pods() {
  for (( i=1; i<=$pod_count; i++ )) do
    echo "Dropping pod-"${i}" on "${NODENAME}""
    kubectl delete pod pod-${i} --now
  done
}

case ${action} in
  create) create_oom_pods ;;
    drop) drop_oom_pods ;;
       *) echo "Unknown action ${action}" ;;
esac