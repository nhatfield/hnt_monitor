#!/usr/bin/env bash

set -euo pipefail

if [ ${trace} == "true" ]; then
  set -x
fi

miner=longap
endpoint=status
lock_file=".${endpoint}.lock"
id=collector.${miner}.${endpoint}

get() {
  url=${longap_test_url:-"${longap_url}/hotspot/status/${a}"}
  url="${url}"
  log_info "getting ${miner} ${endpoint} for [${client_id} (${a})]"
  log_debug "${miner} url: ${url}"

  n=0
  get_payload
  
  while [ ! "$(longap_success_payload)" ]; do
    if [ "${n}" -ge "${api_retry_threshold}" ]; then
      log_err "maximum retries have been reached - ${api_retry_threshold}"
      error=true
      break
    fi

    log_warn "bad response from the api gateway while retrieving ${endpoint} data for ${a}. Retrying in 5 seconds..."
    ((n++)) || true
    sleep "${api_retry_wait}"
    get_payload
  done

  if [ ! "${error}" == "true" ]; then
    send_payload write "${data_dir}/${client_id}/miner.${miner}/${a}.${endpoint}"
    log_info "${miner} miner [${a}] ${endpoint} ready to process"
  fi

  sleep "${longap_data_interval}"
  rm_lock "${data_dir}/${client_id}/miner.${miner}/.${a}${lock_file}"
}


if [ "${miner_collector_enabled}" == "true" ] && [ "${longap_collector_enabled}" == "true" ]; then
  for address in ${longap_addresses}; do
    addr=${address//*:/}
    addr=${addr//###/ }
    client_id=${address//:*/}
  
    for a in ${addr}; do
      make_dir "${data_dir}/${client_id}/miner.${miner}"
  
      ttl=${longap_data_interval}
      lock "${data_dir}/${client_id}/miner.${miner}/.${a}${lock_file}"

      if [ "${ready}" == "true" ]; then
        error=
        get &
        sleep 1
      fi
    done
  done
fi
