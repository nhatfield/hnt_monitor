#!/usr/bin/env bash

set -euo pipefail

if [ ${trace} == "true" ]; then
  set -x
fi

endpoint=data
lock_file=".${endpoint}.lock"
id=collector.nebra.${endpoint}

get() {
  url="http://${a}/?json=true"
  log_info "getting nebra ${endpoint} for ${a}"

  n=0
  get_payload
  
  while [ ! "$(nebra_miner_success_payload)" ]; do
    if [ "${n}" -ge "${api_retry_threshold}" ]; then
      log_err "maximum retries have been reached - ${api_retry_threshold}"
      rm_lock "${data_dir}/miner.nebra/.${a}${lock_file}"
      exit
    fi

    log_warn "bad response from the api gateway while retrieving ${endpoint} data. Retrying in 5 seconds..."
    ((n++)) || true
    sleep "${api_retry_wait}"
    get_payload
  done

  send_payload write "${data_dir}/miner.nebra/${a}.${endpoint}"
  log_info "Nebra miner ${a} ${endpoint} ready to process"
  log_debug "nebra ${endpoint} \n${payload}\n\n"

  sleep "${nebra_data_interval}"
  rm_lock "${data_dir}/miner.nebra/.${a}${lock_file}"
}


for a in ${nebra_ips}; do
  make_dir "${data_dir}/miner.nebra"

  lock "${data_dir}/miner.nebra/.${a}${lock_file}"
  get &

  sleep 1
done
