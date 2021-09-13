#!/usr/bin/env bash

set -euo pipefail

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
cd ${DIR}

for c in ../conf/*.conf; do
  . "${c}"
done

if [ ${trace} == "true" ]; then
  set -x
fi

addresses=$(< ../conf/address.list)
endpoint=witnessed
lock_file=.${endpoint}.lock
id=collector.${endpoint}

get() {
  url="https://${hotspot_url}/${a}/${endpoint}"
  echo "$(date +%Y-%m-%dT%H:%M:%S) [INFO] [$id]: getting hotspot ${endpoint} data" >> "${logpath}/${logfile}"

  n=0
  payload=$(curl -s "${url}") || echo "$(date +%Y-%m-%dT%H:%M:%S) [ERROR] [$id]: api timeout" >> "${logpath}/${logfile}"
  
  while ! jq '.data[]' <<< "${payload}"; do
    if [ "${n}" -ge "${api_retry_threshold}" ]; then
      echo "$(date +%Y-%m-%dT%H:%M:%S) [ERROR] [$id]: maximum retries have been reached - ${api_retry_threshold}" >> "${logpath}/${logfile}"
      rm -f "${lock_file}"
      exit
    fi

    echo "$(date +%Y-%m-%dT%H:%M:%S) [WARN] [$id]: bad response from the api gateway while retrieving ${endpoint} data. Retrying in 5 seconds..." >> "${logpath}/${logfile}"
    ((n++)) || true
    sleep "${api_retry_wait}"
    payload=$(curl -s "${url}") || echo "$(date +%Y-%m-%dT%H:%M:%S) [ERROR] [$id]: api timeout" >> "${logpath}/${logfile}"
  done

  echo "${payload}" >> "${data_dir}/${a}/${endpoint}"
  echo "$(date +%Y-%m-%dT%H:%M:%S) [INFO] [$id]: hotspot ${endpoint} data ready to process" >> "${logpath}/${logfile}"
  [ "${debug}" == "true" ] && echo -e "$(date +%Y-%m-%dT%H:%M:%S) [DEBUG] [$id]: ${endpoint} data \n${payload}\n\n" >> "${logpath}/${logfile}" || true

  sleep ${witness_interval}
  rm -f "${data_dir}/${a}/${lock_file}"
}

for a in ${addresses}; do
  if [ ! -d "${data_dir}/${a}" ]; then
    mkdir -p "${data_dir}/${a}"
  fi

  if [ ! -f "${data_dir}/${a}/${lock_file}" ]; then
    touch "${data_dir}/${a}/${lock_file}"

    get
  fi

  sleep 1
done
