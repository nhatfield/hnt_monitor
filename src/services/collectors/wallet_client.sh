#!/usr/bin/env bash

set -euo pipefail

if [ ${trace} == "true" ]; then
  set -x
fi

miner=wallet.client
when=${when:-"15 minutes ago"}
endpoint=activity
lock_file=".${miner}.${endpoint}.lock"
id=collector.${miner}

get() {
  url=${wallet_test_url:-"${wallet_url}"}
  url="${url}/${a}/${endpoint}?min_time=${current_date}"
  log_info "getting wallet ${endpoint} data for [${client_id} ${a}]"
  log_debug "wallet url: ${url}"

  n=0
  get_payload

  while [ ! "$(blockchain_success_payload)" ]; do
    if [ "${n}" -ge "${api_retry_threshold}" ]; then
      log_err "maximum retries have been reached - ${api_retry_threshold}"
      rm_lock "${data_dir}/${client_id}/${a}/${lock_file}"
      exit
    fi

    log_warn "bad response from the api gateway while retrieving ${endpoint} data for ${a}. Retrying in 5 seconds..."
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
      rm_lock "${data_dir}/${client_id}/${a}/${lock_file}"
      exit
    fi
    ((n++)) || true
  done

  if [ "$(validate_payload)" ]; then
    send_payload append "${data_dir}/${client_id}/${a}/${data_format}.${endpoint}"
  fi

  log_info "[${a}] wallet ${endpoint} data ready to process"

  sleep "${wallet_client_interval}"
  rm_lock "${data_dir}/${client_id}/${a}/${lock_file}"
}

if [[ ! "${elasticsearch_url}" == *"hntmonitor.com"* ]] && [ "${wallet_collector_client_enabled}" == "true" ]; then
  current_date=$(date +%Y-%m-%dT%H:%M:%S -u --date="${when}")

  get_addresses

  if [ ! "${wallet_client_addresses}" ]; then
    log_debug "no client walletaddresses have been found"
  fi

  for address in ${wallet_client_addresses}; do
    addr=${address//*:/}
    addr=${addr//###/ }
    client_id=${address//:*/}

    for a in ${addr}; do
      make_dir "${data_dir}/${client_id}/${a}"

      lock "${data_dir}/${client_id}/${a}/${lock_file}"
      get &

      sleep 1
    done
  done
fi
