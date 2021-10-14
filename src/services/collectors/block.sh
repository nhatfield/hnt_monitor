#!/usr/bin/env bash

set -euo pipefail

if [ ${trace} == "true" ]; then
  set -x
fi

miner=helium
endpoint=height
lock_file=".${endpoint}.lock"
id=collector.${endpoint}

get() {
  url=${helium_test_url:-"${blocks_url}"}
  url="${url}/${endpoint}"
  log_info "getting block ${endpoint} data"
  log_debug "helium url: ${url}"

  n=0
  get_payload
  
  while [ ! "$(blockchain_success_payload)" ]; do
    if [ "${n}" -ge "${api_retry_threshold}" ]; then
      log_err "maximum retries have been reached - ${api_retry_threshold}"
      rm_lock "${data_dir}/${lock_file}"
      exit
    fi

    log_warn "bad response from the api gateway while retrieving ${endpoint} data. Retrying in 5 seconds..."
    ((n++)) || true
    sleep "${api_retry_wait}"
    get_payload
  done

  send_payload write "${data_dir}/${endpoint}"
  log_info "Block ${endpoint} data ready to process"

  sleep "${blocks_interval}"
  rm_lock "${data_dir}/${lock_file}"
}

if [[ ! "${elasticsearch_url}" == *"hntmonitor.com"* ]]; then
  lock "${data_dir}/${lock_file}"
  get
fi
