#!/usr/bin/env bash

set -euo pipefail

if [ ${trace} == "true" ]; then
  set -x
fi

when=${when:-"15 minutes ago"}
get_addresses
miner=hotspot
current_date=$(date +%Y-%m-%dT%H:%M:%S -u --date="${when}")
endpoint=rewards
lock_file=".${endpoint}.lock"
id=collector.${endpoint}

get() {
  url=${hotspot_test_url:-"${hotspot_url}"}
  url="${url}/${a}/${endpoint}?min_time=${current_date}"
  log_info "getting hotspot ${endpoint} data for ${a}"
  log_debug "hotspot url: ${url}"

  n=0
  get_payload
  
  while [ ! "$(blockchain_success_payload)" ]; do
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

  n=0
  get_cursor
  
  while [ "${cursor}" ]; do
    next_payload
    get_cursor "${new_payload}"
    payload=$(jq -s '{data: (.[0].data + .[1].data)}' <<< "${payload} ${new_payload}")

    if [ "${n}" -ge ${cursor_threshold} ]; then
      log_err "api is having problems or there are too many cursors to traverse"
      rm_lock "${data_dir}/${a}/${lock_file}"
      exit
    fi
    ((n++)) || true
  done

  if [ "$(validate_payload)" ]; then
    send_payload append "${data_dir}/${a}/${data_format}.${endpoint}"
  fi

  log_info "${a} hotspot ${endpoint} data ready to process"
  log_debug "${endpoint} data \n${payload}\n\n"

  sleep "${rewards_interval}"
  rm_lock "${data_dir}/${a}/${lock_file}"
}

if [ ! "${addresses}" ]; then
  log_debug "no hotspot addresses have been found"
fi

for address in ${addresses}; do
  addr=${address//*:/}
  addr=${addr//###/ }
  client_id=${address//:*/}

  for a in ${addr}; do
    make_dir "${data_dir}/${a}"

    lock "${data_dir}/${a}/${lock_file}"
    get &

    sleep 1
  done
done
