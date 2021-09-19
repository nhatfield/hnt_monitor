#!/usr/bin/env bash

set -euo pipefail

if [ ${trace} == "true" ]; then
  set -x
fi

miner=bobcat
endpoint=status
lock_file=".${endpoint}.lock"
id=collector.${miner}.${endpoint}

get() {
  url=${bobcat_test_url:-"http://${a}/"}
  url="${url}/${endpoint}.json"
  log_info "getting ${miner} ${endpoint} data for ${a}"
  log_debug "${miner} url: ${url}"

  n=0
  get_payload
  
  while [ ! "$(bobcat_status_success_payload)" ]; do
    if [ "${n}" -ge "${api_retry_threshold}" ]; then
      log_err "maximum retries have been reached - ${api_retry_threshold}"
      rm_lock "${data_dir}/miner.${miner}/.${a}${lock_file}"
      exit
    fi

    log_warn "bad response from the api gateway while retrieving ${endpoint} data. Retrying in 5 seconds..."
    ((n++)) || true
    sleep "${api_retry_wait}"
    get_payload
  done

  send_payload write "${data_dir}/miner.${miner}/${a}.${endpoint}"
  log_info "${miner} miner ${a} ${endpoint} data ready to process"
  log_debug "${endpoint} data \n${payload}\n\n"

  sleep "${bobcat_status_interval}"
  rm_lock "${data_dir}/miner.${miner}/.${a}${lock_file}"
}


for a in ${bobcat_ips}; do
  make_dir "${data_dir}/miner.${miner}"

  lock "${data_dir}/miner.${miner}/.${a}${lock_file}"
  get &

  sleep 1
done
