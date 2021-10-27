#!/usr/bin/env bash

set -euo pipefail

if [ ${trace} == "true" ]; then
  set -x
fi

miner=sensecap
endpoint=data
lock_file=".${endpoint}.lock"
id=collector.${miner}.${endpoint}

get() {
  url=${sensecap_test_url:-"${sensecap_url}/view_device?sn=${a}&api_key=${sensecap_api_key}"}
  url="${url}"
  log_info "getting ${miner} ${endpoint} for [${client_id} (${a})]"
  log_debug "${miner} url: ${url}"

  n=0
  get_payload
  
  while [ ! "$(sensecap_success_payload)" ]; do
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

  ip_address=$(jq -r '.data.ipEthLocal' <<< "${payload}")
  if [ "$(echo "${ip_address}" | awk -F '.' '{print $1,$2,$3,$4}' | wc -w | tr -dc .[:print:].)" -eq 4 ]; then
    latency=$(ping -W 5 -c 1 ${ip_address} | sed 's%.*time=\(.*\) .*%{ "response_time": "\1" }%' | grep 'response_time')
    latency=${latency:-"{ \"response_time\": \"-1\" }"}
  else
    latency='{ "response_time": "-1" }'
  fi
  payload=$(jq -s '(.[0] + .[1])' <<< "${payload} ${latency}")

  send_payload write "${data_dir}/${client_id}/miner.${miner}/${a}.${endpoint}"
  log_info "${miner} miner [${a}] ${endpoint} ready to process"

  sleep "${sensecap_data_interval}"
  rm_lock "${data_dir}/${client_id}/miner.${miner}/.${a}${lock_file}"
}


if [ "${miner_collector_enabled}" == "true" ] && [ "${sensecap_collector_enabled}" == "true" ]; then
  get_addresses
  for address in ${sensecap_serial_numbers}; do
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
