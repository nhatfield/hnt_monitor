#!/usr/bin/env bash

set -euo pipefail

if [ ${trace} == "true" ]; then
  set -x
fi

when=${when:-"15 minutes ago"}
miner=hotspot
endpoint=rewards
lock_file=".${endpoint}.lock"
id=collector.${endpoint}

get() {
  url=${hotspot_test_url:-"${hotspot_url}"}
  url="${url}/${a}/${endpoint}?min_time=${current_date}"
  log_info "getting hotspot ${endpoint} data for [${client_id} (${a})]"
  log_debug "hotspot url: ${url}"

  n=0
  get_payload
  
  while [ ! "$(blockchain_success_payload)" ]; do
    if [ "${n}" -ge "${api_retry_threshold}" ]; then
      log_err "maximum retries have been reached - ${api_retry_threshold}"
      rm_lock "${data_dir}/${client_id}/${a}/${lock_file}"
      get_system_metrics_total
      send_system_metrics
      exit
    fi

    log_warn "bad response from the api gateway while retrieving ${endpoint} data for ${a}. Retrying in 5 seconds..."
    get_system_metrics_total
    ((n++)) || true
    sleep "${api_retry_wait}"
    get_payload
  done

  n=0
  get_cursor
  
  while [ "${cursor}" ]; do
    next_payload
    get_cursor "${new_payload}"
    payload=$(jq -s '{data: (.[0].data + .[1].data)}' <<< "${payload} ${new_payload}")

    if [ "${n}" -ge ${cursor_threshold} ]; then
      log_err "api is having problems or there are too many cursors to traverse"
      rm_lock "${data_dir}/${client_id}/${a}/${lock_file}"
      get_system_metrics_total
      send_system_metrics
      exit
    fi
    ((n++)) || true
  done

  if [ "$(validate_payload)" ]; then
    send_payload append "${data_dir}/${client_id}/${a}/${data_format}.${endpoint}"
  fi

  log_info "[${a}] hotspot ${endpoint} data ready to process"

  sleep "${rewards_interval}"
  rm_lock "${data_dir}/${client_id}/${a}/${lock_file}"
  get_system_metrics_total
}

if [[ ! "${elasticsearch_url}" == *"hntmonitor.com"* ]] && [ "${reward_collector_enabled}" == "true" ]; then
  current_date=$(date +%Y-%m-%dT%H:%M:%S -u --date="${when}")
  if [ ! "${addresses}" ]; then
    log_debug "no hotspot addresses have been found"
  fi

  for address in ${addresses}; do
    addr=${address//*:/}
    addr=${addr//###/ }
    client_id=${address//:*/}
  
    for a in ${addr}; do
      make_dir "${data_dir}/${client_id}/${a}"
  
      lock "${data_dir}/${client_id}/${a}/${lock_file}"
      get &
  
      sleep 1
    done
  done
fi
