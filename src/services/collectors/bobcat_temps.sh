#!/usr/bin/env bash

set -euo pipefail

if [ ${trace} == "true" ]; then
  set -x
fi

miner=bobcat
endpoint=temp
lock_file=".${endpoint}.lock"
id=collector.${miner}.${endpoint}

get() {
  url=${bobcat_test_url:-"http://${a}"}
  url="${url}/${endpoint}.json"
  log_info "getting ${miner} ${endpoint} data for [${client_id} (${a})]"
  log_debug "${miner} url: ${url}"

  n=0
  get_payload
  
  while [ ! "$(bobcat_temp_success_payload)" ]; do
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

  if [ "$(echo "${a}" | awk -F '.' '{print $1,$2,$3,$4}' | wc -w | tr -dc .[:print:].)" -eq 4 ]; then
    latency=$(ping -W 5 -c 1 ${a} | sed 's%.*time=\(.*\) .*%{ "response_time": "\1" }%' | grep 'response_time') || latency='{ "response_time": "-1" }'
  else
    latency='{ "response_time": "-1" }'
  fi
  payload=$(jq -s '(.[0] + .[1])' <<< "${payload} ${latency}") || true

  send_payload write "${data_dir}/${client_id}/miner.${miner}/${a}.${endpoint}" || true
  log_info "${miner} miner [${a}] ${endpoint} data ready to process"

  sleep "${bobcat_temperature_interval}"
  rm_lock "${data_dir}/${client_id}/miner.${miner}/.${a}${lock_file}"
}


if [ "${miner_collector_enabled}" == "true" ] && [ "${bobcat_collector_enabled}" == "true" ]; then
  get_addresses
  for address in ${bobcat_ips}; do
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
