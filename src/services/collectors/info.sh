#!/usr/bin/env bash

set -euo pipefail

if [ ${trace} == "true" ]; then
  set -x
fi

miner=hotspot
endpoint=info
lock_file=".${endpoint}.lock"
id=collector.${endpoint}
get_addresses

get() {
  url=${hotspot_test_url:-"${hotspot_url}"}
  url="${url}/${a}"
  log_info "getting hotspot ${endpoint} data for [${client_id} (${a})]"
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

  send_payload write "${data_dir}/${a}/${endpoint}"
  log_info "[${client_id} (${a})] hotspot ${endpoint} data ready to process"
  log_debug "[${client_id} (${a})] ${endpoint} data \n${payload}\n\n"

  sleep "${info_interval}"
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
