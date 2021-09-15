#!/usr/bin/env bash

set -euo pipefail

if [ ${trace} == "true" ]; then
  set -x
fi

when=${when:-"15 minutes ago"}
get_addresses
current_date=$(date +%Y-%m-%dT%H:%M:%S -u --date="${when}")
endpoint=rewards
lock_file=".${endpoint}.lock"
id=collector.${endpoint}

get() {
  url="https://${hotspot_url}/${a}/${endpoint}?min_time=${current_date}"
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

  get_cursor
  
  while [ "${cursor}" ]; do
    next_payload
    get_cursor "${new_payload}"
    payload="${payload}
${new_payload}"
  done

  send_payload append "${data_dir}/${a}/${data_format}.${endpoint}"
  log_info "${a} hotspot ${endpoint} data ready to process"
  log_debug "${endpoint} data \n${payload}\n\n"

  sleep "${rewards_interval}"
  rm_lock "${data_dir}/${a}/${lock_file}"
}

for a in ${addresses}; do
  make_dir "${data_dir}/${a}"

  lock "${data_dir}/${a}/${lock_file}"
  get &

  sleep 1
done