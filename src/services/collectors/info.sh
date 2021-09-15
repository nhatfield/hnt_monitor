#!/usr/bin/env bash

set -euo pipefail

if [ ${trace} == "true" ]; then
  set -x
fi

get_addresses
endpoint=info
lock_file=".${endpoint}.lock"
id=collector.${endpoint}

get() {
  url="https://${hotspot_url}/${a}"
  log_info "getting hotspot ${endpoint} data for ${a}"

  n=0
  get_payload
  
  while ! success_payload; do
    if [ "${n}" -ge "${api_retry_threshold}" ]; then
      log_err "maximum retries have been reached - ${api_retry_threshold}"
      rm_lock "${data_dir}/${a}/${lock_file}"
      exit
    fi

    log_warn "bad response from the api gateway while retrieving ${endpoint} data. Retrying in 5 seconds..."
    ((n++)) || true
    sleep "${api_retry_wait}"
    get_payload
  done

  send_payload write "${data_dir}/${a}/${endpoint}"
  log_info "${a} hotspot ${endpoint} data ready to process"
  log_debug "${endpoint} data \n${payload}\n\n"

  sleep ${info_interval}
  rm_lock ${data_dir}/${a}/${lock_file}
}


for a in ${addresses}; do
  make_dir "${data_dir}/${a}"

  lock ${data_dir}/${a}/${lock_file}
  get &

  sleep 1
done
