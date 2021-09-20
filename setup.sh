#!/usr/bin/env bash

set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
cd ${DIR}

OPT=${1:-"intro"}
HNT_HOTSPOT_ADDRESSES=${HNT_HOTSPOT_ADDRESSES:-""}
YAML=${YAML:-"hnt_monitor.yml"}

intro() {
  clear
  version
  echo
  echo "What do you want to do?"
  echo
  echo "1. Install"
  echo "2. Upgrade"
  echo "3. Exit"
  read title
  
  while [ ! "${title}" ]; do
    echo "Please choose a valid option or cancel the script [CTRL+C]"
    read title
  done

  case ${title} in 
                install|Install|INSTALL|1)
                  prereq
                  install
                  ;;
                upgrade|Upgrade|UPGRADE|2)
                  upgrade
                  ;;
                exit|Exit|EXIT|3)
                  exit 0
                  ;;
                *)
                  echo "invalid option: ${title}"
                  intro
                  exit 0
                  ;;
  esac
}

prereq() {
  if [ ! "$(which docker 2>/dev/null)" ] || [ ! "$(which docker-compose 2>/dev/null)" ]; then
    if [ "$(which yum 2>/dev/null)" ]; then
      yum update -y
      yum install -y epel-release
      yum update -y
      yum install docker docker-compose -y
      service docker start || systemctl start docker
    elif [ "$(which apt-get 2>/dev/null)" ]; then
      apt-get update -y
      apt-get upgrade -y
      apt-get install docker docker-compose -y
      service docker start || systemctl start docker
    fi
  fi
}

install() {
  clear
  echo "Which miner do you want to add?"
  echo
  echo "1. Bobcat"
  echo "2. LongAP"
  echo "3. Nebra"
  echo "4. Sensecap"
  echo
  read install

  while [ ! "${install}" ]; do
    echo "Please choose a valid option or cancel the script [CTRL+C]"
    read install
  done
  
  case ${install} in
                  bobcat|Bobcat|BOBCAT|1)
                    bobcat
                    ;;
                  longap|Longap|LongAP|LONGAP|2)
                    longap
                    ;;
                  nebra|Nebra|NEBRA|3)
                    nebra
                    ;;
                  sensecap|Sensecap|SENSECAP|4)
                    sensecap
                    ;;
  esac
}

ips() {
  echo "${message}"
  echo "ex: 192.168.0.1 10.10.0.3 172.16.2.5"
  echo
  read ips
}

mon() {
  if [ "$(grep "${monitor}" ${YAML} 2>/dev/null)" ]; then
    sed -i "s%${monitor}:.*%${monitor}: \"true\"%" ${YAML}
  else
    sed -i "s%DO_NOT_REMOVE:\(.*\)%DO_NOT_REMOVE:\1\n      ${monitor}: \"true\"%" ${YAML}
  fi
}

bobcat() {
  clear
  message="What are the PRIVATE IP addresses of your bobcat miner(s)? Please separate them by a [space]"
  ips

  monitor=HNT_BOBCAT_MONITOR
  mon

  if [ "$(grep "HNT_BOBCAT_IPS" ${YAML} 2>/dev/null)" ]; then
    sed -i "s%HNT_BOBCAT_IPS:.*%HNT_BOBCAT_IPS: \"${ips}\"%" ${YAML}
  else
    sed -i "s%${monitor}:\(.*\)%${monitor}:\1\n      HNT_BOBCAT_IPS: \"${ips}\"%" ${YAML}
  fi

  hotspot
  end
}

hotspot() {
  echo "What are the hotspot addresses of the bobcat miner(s)? Please separate them by a [space]"
  echo "ex: 112GezswE 114vTyhUnKo"
  echo
  read addr

  if [ "${HNT_HOTSPOT_ADDRESSES}" ]; then
    HNT_HOTSPOT_ADDRESSES="${HNT_HOTSPOT_ADDRESSES} ${addr}"
  else
    HNT_HOTSPOT_ADDRESSES="${addr}"
  fi
}

end() {
  echo "Would you like to add another miner?"
  echo
  read end_resp
  
  while [ ! "${end_resp}" ]; do
    echo "Please choose a valid option or cancel the script [CTRL+C]"
    read end_resp
  done

  case ${end_resp} in
                   y|Y|yes|Yes|YES)
                     install
                     exit 0
                     ;;
                   n|N|no|No|NO)
                     config
                     deploy
                     exit 0
                     ;;
                   *)
                     echo "invalid response: ${end_resp}"
                     end
                     exit 0
  esac    
}

config() {
  if [ "$(grep "HNT_HOTSPOT_ADDRESSES" ${YAML} 2>/dev/null)" ]; then
    sed -i "s%HNT_HOTSPOT_ADDRESSES:.*%HNT_HOTSPOT_ADDRESSES: \"${HNT_HOTSPOT_ADDRESSES}\"%" ${YAML}
  else
    sed -i "s%DO_NOT_REMOVE:\(.*\)%DO_NOT_REMOVE:\1\n      HNT_HOTSPOT_ADDRESSES: \"${HNT_HOTSPOT_ADDRESSES}\"%" ${YAML}
  fi
}

deploy() {
  clear
  echo "Ready to deploy?"
  echo
  read deploy

  while [ ! "${deploy}" ]; do
    echo "Please choose a valid option or cancel the script [CTRL+C]"
    read deploy
  done

  case ${deploy} in 
                 y|Y|yes|Yes|YES)
                   docker-compose -f ${YAML} up -d --build
                   ;;
                 *)
                   echo "Action cancelled"
                   exit 0
                   ;;
  esac
}

update() {
  git checkout master
  git pull
  deploy
}

version() {
  echo "HNT Monitor v$(grep '#' HISTORY.md | sed 's%# %%' | sort -V | tail -1)"
}

donate() {
  clear
  echo
  echo "                                                           HNT: 1359NhpbxJg1jRpDenJvrmD2P3ZN3hWGSGzUF6Uyn828zYdyYVt"
  cat .donate
}

case ${OPT} in
            donate)
              donate
              ;;
            install)
              prereq
              install
              ;;
            intro)
              intro
              ;;
            update|upgrade)
              update
              ;;
            version | -v | --version)
              version
              ;;
            *)
              echo "invalid option: ${OPT}"
              ;;
esac
