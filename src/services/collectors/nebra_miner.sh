#!/usr/bin/env bash

set -euo pipefail

if [ ${trace} == "true" ]; then
  set -x
fi

miner=nebra
endpoint=data
lock_file=".${endpoint}.lock"
id=collector.${miner}.${endpoint}
get_addresses

get() {
  url=${nebra_test_url:-"http://${a}/?json=true"}
  url="${url}"
  log_info "getting ${miner} ${endpoint} for [${client_id} (${a})]"
  log_debug "${miner} url: ${url}"

  n=0
  get_payload
  
  while [ ! "$(nebra_success_payload)" ]; do
    if [ "${n}" -ge "${api_retry_threshold}" ]; then
      log_err "maximum retries have been reached - ${api_retry_threshold}"
      rm_lock "${data_dir}/${client_id}/miner.${miner}/.${a}${lock_file}"
      exit
    fi

    log_warn "bad response from the api gateway while retrieving ${endpoint} data. Retrying in 5 seconds..."
    ((n++)) || true
    sleep "${api_retry_wait}"
    get_payload
  done

  send_payload write "${data_dir}/${client_id}/miner.${miner}/${a}.${endpoint}"
  log_info "${miner} miner [${a}] ${endpoint} ready to process"

  sleep "${nebra_data_interval}"
  rm_lock "${data_dir}/${client_id}/miner.${miner}/.${a}${lock_file}"
}


if [ "${miner_collector_enabled}" == "true" ] && [ "${nebra_collector_enabled}" == "true" ]; then
  for address in ${nebra_ips}; do
    addr=${address//*:/}
    addr=${addr//###/ }
    client_id=${address//:*/}
  
    for a in ${addr}; do
      make_dir "${data_dir}/${client_id}/miner.${miner}"
  
      lock "${data_dir}/${client_id}/miner.${miner}/.${a}${lock_file}"
      get &
  
      sleep 1
    done
  done
fi
