#!/usr/bin/env bash

set -euo pipefail

if [ ${trace} == "true" ]; then
  set -x
fi

miner=nebra
endpoint=data
lock_file=".${endpoint}.lock"
id=collector.${miner}.${endpoint}

get() {
  url=${nebra_test_url:-"http://${a}/json"}
  url="${url}"
  log_info "getting ${miner} ${endpoint} for [${client_id} (${a})]"
  log_debug "${miner} url: ${url}"

  n=0
  get_payload
  
  while [ ! "$(nebra_success_payload)" ]; do
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
    if [ "$(echo "${a}" | awk -F '.' '{print $1,$2,$3,$4}' | wc -w | tr -dc .[:print:].)" -eq 4 ]; then
      latency=$(ping -W 5 -c 1 ${a} | sed 's%.*time=\(.*\) .*%{ "response_time": "\1" }%' | grep 'response_time') || latency='{ "response_time": "-1" }'
    else
      latency='{ "response_time": "-1" }'
    fi
    payload=$(jq -s '(.[0] + .[1])' <<< "${payload} ${latency}") || true
  
    send_payload write "${data_dir}/${client_id}/miner.${miner}/${a}.${endpoint}" || true
    log_info "${miner} miner [${a}] ${endpoint} ready to process"
  fi

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
  
      ttl=${nebra_data_interval}
      lock "${data_dir}/${client_id}/miner.${miner}/.${a}${lock_file}"

      if [ "${ready}" == "true" ]; then
        error=
        get &
        sleep 1
      fi
    done
  done
fi
