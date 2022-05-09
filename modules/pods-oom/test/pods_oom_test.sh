#!/bin/bash

# exit on any errors
set -e

TEST_ONLY=0

RETURN_CODE=1
# seconds to wait on k8s/alarms/etc
MAX_WAIT=600
# seconds to pause between checking k8s/alarms/etc
PAUSE_TIME=20

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color


on_exit () {
  set +e
  echo -n -e "${RED}"
  echo "============================================================"
  echo "Test script failed."
  echo "============================================================"
  echo "Attempting cleanup..."
  echo -e "${NC}"
  do_cleanup
  exit 1
}
trap on_exit ERR
#trap on_exit EXIT

PATH=${PATH}:~/work/shoreline/cli/go/bin/
# PATH=${PATH}:~/work/shoreline/cli/go/bin CLI=`command -v oplang_cli`


############################################################
# Utility functions

pre_error() {
  echo -n -e "${RED}"
  echo "============================================================"
  echo "ERROR: $1"
  echo "============================================================"
  echo -e "${NC}"
  exit 1
}


do_timeout() {
  echo -n -e "${RED}"
  echo "============================================================"
  echo "ERROR: Timed out waiting for $1"
  echo "============================================================"
  echo "Attempting cleanup..."
  echo -e "${NC}"
  do_cleanup
  exit 2
}

check_command() {
  command -v $1 > /dev/null || pre_error "missing command $1"
}

check_env() {
  env | grep -e "^$1=" ||  pre_error "missing env variable $1"
}

get_event_counts() {
  echo "events | name =~ 'oom' | count" | ${CLI}  | grep "group_all" | awk -F "ALARMS" '{print $2}'
}

now() {
  date +"%s"
}

age_to_sec() {
  declare -a tm
  tm[86400]=$(echo $1 | grep -oe '[0-9][0-9]*d' | tr -d 'd')
  tm[3600]=$(echo $1 | grep -oe '[0-9][0-9]*h' | tr -d 'h')
  tm[60]=$(echo $1 | grep -oe '[0-9][0-9]*m' | tr -d 'm')
  tm[1]=$(echo $1 | grep -oe '[0-9][0-9]*s' | tr -d 's')
  sec=0
  for K in "${!tm[@]}"; do
    V=${tm[${K}]}
    #echo ${K} "->" ${V};
    if [ "$V" != "" ]; then
      sec=$(( sec + (K*V) ))
    fi
  done
  unset tm
  echo ${sec}
}


check_oom_util() {
  echo "host | pods  | app='shoreline'| limit=1 | \`ls scripts/\`" | ${CLI} | grep "test_oom_pods.sh"
}

createEvent() {
   echo "host | pods | app='shoreline'| limit=1  | \`chmod +x scripts/test_oom_pods.sh && scripts/test_oom_pods.sh create 5\`"  | ${CLI} 
}

cleanPods() {
   echo "host | pods | app='shoreline'| limit=1  | \`chmod +x scripts/test_oom_pods.sh && scripts/test_oom_pods.sh drop 5\`"  | ${CLI} 
}

############################################################
# Pre-flight validation

check_command kubectl
check_command oplang_cli

check_env SHORELINE_URL
check_env SHORELINE_TOKEN
check_env CLUSTER

CLI=$(command -v oplang_cli)


############################################################
# setup

do_setup_terraform() {
  echo "Setting up terraform objects"
  terraform init
  terraform apply --auto-approve
}



do_setup() {
  do_setup_terraform
}

############################################################
# cleanup

do_cleanup_terraform() {
  echo "Cleaning up terraform objects"
  terraform destroy --auto-approve
}

do_cleanup() {
  if [ "${TEST_ONLY}" == "0" ]; then
    do_cleanup_terraform
    cleanPods
  fi
}

############################################################
# actual tests

run_tests() {
  start_time=$(now)

  # dynamically wait for file to propagate
  echo "waiting for oom-util file to propagate ..."
  used=0
  while [ ! check_oom_util ]; do
    echo "  waiting..."
    sleep ${PAUSE_TIME}
    # timeout after maximum wait and fail
    used=$(( ${used} + ${PAUSE_TIME} ))
    if [ ${used} -gt ${MAX_WAIT} ]; then
      do_timeout "test_oom_pods propagation"
    fi
  done

  # count alarms before we started
  pre_fired=$(get_event_counts | cut -d '|' -f 2)
  pre_cleared=$(get_event_counts | cut -d '|' -f 3)
  
  ## creating oom event 
  createEvent
  ####
  echo "waiting for oom alarm to create ..."
  post_fired=$(get_event_counts | cut -d '|' -f 2)
  while [ "${pre_fired}" == "${post_fired}" ]; do
    echo "  waiting... for alarm to create....."
    sleep ${PAUSE_TIME}
    post_fired=$(get_event_counts | cut -d '|' -f 2)
    # timeout after maximum wait and fail
    used=$(( ${used} + ${PAUSE_TIME} ))
    if [ ${used} -gt ${MAX_WAIT} ]; then
      do_timeout "alarm to clear"
    fi
  done
    if  [ "${pre_fired}" == "${post_fired}" ]; then
    echo -n -e "${RED}"
    echo "============================================================"
    echo "ERROR: Alarm failed to fire!"
    echo "============================================================"
    echo -e "${NC}"
  else
    echo -n -e "${GREEN}"
    echo "============================================================"
    echo "Successfully fired  oom pods Alarm."
    echo "============================================================"
    echo -e "${NC}"
    RETURN_CODE=0
  fi
  post_cleared=$(get_event_counts | cut -d '|' -f 3)
  used=0
  while [ "${post_cleared}" == "${pre_cleared}" ]; do
    echo "  waiting..."
    sleep ${PAUSE_TIME}
    # timeout after maximum wait and fail
    post_cleared=$(get_event_counts | cut -d '|' -f 3)
    used=$(( ${used} + ${PAUSE_TIME} ))
    if [ ${used} -gt ${MAX_WAIT} ]; then
      do_timeout "alarm to clear"
    fi
  done

  if  [ "${post_cleared}" == "${pre_cleared}" ]; then
    echo -n -e "${RED}"
    echo "============================================================"
    echo "ERROR: Alarm failed to clear!"
    echo "============================================================"
    echo -e "${NC}"
  else
    echo -n -e "${GREEN}"
    echo "============================================================"
    echo "Successfully clear oom pods Alarm."
    echo "============================================================"
    echo -e "${NC}"
    RETURN_CODE=0
  fi
}

do_all() {
  do_setup
  run_tests
  do_cleanup
  exit ${RETURN_CODE}
}

case $1 in
       setup) do_setup ;;
     cleanup) do_cleanup ;;
  debug-test) TEST_ONLY=1; set -x; run_tests  ;;
   test-only) TEST_ONLY=1; run_tests  ;;
           *) do_all ;;
esac
