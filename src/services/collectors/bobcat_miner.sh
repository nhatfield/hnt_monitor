#!/usr/bin/env bash

set -euo pipefail

if [ ${trace} == "true" ]; then
  set -x
fi

endpoint=miner
lock_file=".${endpoint}.lock"
id=collector.bobcat.${endpoint}

get() {
  url="http://${a}/${endpoint}.json"
  log_info "getting bobcat ${endpoint} data for ${a}"

  n=0
  get_payload
  
  while [ ! "$(bobcat_miner_success_payload)" ]; do
    if [ "${n}" -ge "${api_retry_threshold}" ]; then
      log_err "maximum retries have been reached - ${api_retry_threshold}"
      rm_lock "${data_dir}/miner.bobcat/.${a}${lock_file}"
      exit
    fi

    log_warn "bad response from the api gateway while retrieving ${endpoint} data. Retrying in 5 seconds..."
    ((n++)) || true
    sleep "${api_retry_wait}"
    get_payload
  done

  send_payload write "${data_dir}/miner.bobcat/${a}.${endpoint}"
  log_info "Bobcat miner ${a} ${endpoint} data ready to process"
  log_debug "${endpoint} data \n${payload}\n\n"

  sleep "${bobcat_info_interval}"
  rm_lock "${data_dir}/miner.bobcat/.${a}${lock_file}"
}


for a in ${bobcat_ips}; do
  make_dir "${data_dir}/miner.bobcat"

  lock "${data_dir}/miner.bobcat/.${a}${lock_file}"
  get &

  sleep 1
done
