#!/usr/bin/env bash

set -euo pipefail

if [ ${trace} == "true" ]; then
  set -x
fi

endpoint=height
lock_file=".${endpoint}.lock"
id=collector.${endpoint}

get() {
  url="https://${blocks_url}/${endpoint}"
  log_info "getting block ${endpoint} data"

  n=0
  get_payload
  
  while [ ! "$(success_payload)" ]; do
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
  log_debug "${endpoint} data \n${payload}\n\n"

  sleep "${blocks_interval}"
  rm_lock "${data_dir}/${lock_file}"
}


lock "${data_dir}/${lock_file}"
get
