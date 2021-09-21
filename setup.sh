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
RELEASE_BRANCH=${RELEASE_BRANCH:-"master"}

os=$(uname)

if [ "${os}" == "Darwin" ]; then
  sedi="sed -i ''"
else
  sedi="sed -i"
fi

intro() {
  clear
  version
  echo
  echo "What do you want to do?"
  echo
  echo "1. Install   [ Install dependencies, setup, and deploy the full monitoring stack ]"
  echo "2. Settings  [ Update miner addresses, serial numbers, ips, etc ]"
  echo "3. Upgrade   [ Upgrade an existing setup to the latest stable release ]"
  echo "4. Deploy    [ Deploy the monitoring stack only ]"
  echo "5. View      [ View the current configuration ]"
  echo "6. Donate    [ Display the HNT wallet backing this project ]"
  echo "7. Exit      [ Exit the program ]"
  echo
  echo
  read title
  
  while [ ! "${title}" ]; do
    echo "Please choose a valid option or cancel the script [CTRL+C]"
    read title
  done

  case ${title} in 
                install|Install|INSTALL|1)
                  prereq
                  setup
                  deploy
                  ;;
                setting|settings|Setting|Settings|SETTING|SETTINGS|2)
                  setup
                  config
                  ;;
                upgrade|Upgrade|UPGRADE|3)
                  upgrade
                  ;;
                deploy|Deploy|DEPLOY|4)
                  deploy
                  ;;
                view|View|VIEW|5)
                  view
                  intro
                  ;;
                donate|Donate|DONATE|6)
                  donate
                  ;;
                exit|Exit|EXIT|7)
                  exit 0
                  ;;
                *)
                  echo "invalid option: ${title}"
                  intro
                  exit 0
                  ;;
  esac
}

view() {
  clear
  grep "HNT_" "${YAML}" | sed 's%^      %%'
  echo
  echo
  echo "Press any key to continue ..."
  read resp
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

setup() {
  clear
  echo "Which miner do you want to add?"
  echo
  echo "1. Bobcat"
  echo "2. LongAP"
  echo "3. Nebra"
  echo "4. Sensecap"
  echo "5. Deploy"
  echo "6. back"
  echo "7. exit"
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
                  deploy|Deploy|DEPLOY|5)
                    deploy
                    exit 0
                    ;;
                  back|6)
                    intro
                    exit 0
                    ;;
                  exit|7)
                    exit 0
                    ;;
  esac
}

address_endp() {
  echo "What are the hotspot addresses of the ${id} miner(s)? Please separate them by a [space]"
  echo "ex: 112GezswE 114vTyhUnKo"
  echo
  read ips
}

ips_endp() {
  echo "What are the PRIVATE IP addresses of your ${id} miner(s)? Please separate them by a [space]"
  echo "ex: 192.168.0.1 10.10.0.3 172.16.2.5"
  echo
  read ips
}

end_point() {
  if [ "$(grep "${endpoints}" ${YAML} 2>/dev/null)" ]; then
    ${sedi} "s%${endpoints}:.*%${endpoints}: \"${ips}\"%" "${YAML}"
  else
    ${sedi} "s%${monitor}:\(.*\)%${monitor}:\1\n      ${endpoints}: \"${ips}\"%" "${YAML}"
  fi
}

mon() {
  if [ "$(grep "${monitor}" ${YAML} 2>/dev/null)" ]; then
    ${sedi} "s%${monitor}:.*%${monitor}: \"true\"%" "${YAML}"
  else
    ${sedi} "s%DO_NOT_REMOVE:\(.*\)%DO_NOT_REMOVE:\1\n      ${monitor}: \"true\"%" "${YAML}"
  fi
}

bobcat() {
  clear
  
  id=bobcat
  ips_endp

  monitor=HNT_BOBCAT_MONITOR
  mon

  endpoints=HNT_BOBCAT_IPS
  end_point

  hotspot
  end
}

longap() {
  clear

  id=longap
  address_endp

  monitor=HNT_LONGAP_MONITOR
  mon

  endpoints=HNT_LONGAP_ADDRESSES
  end_point

  hotspot
  end
}

nebra() {
  clear

  id=nebra
  ips_endp

  monitor=HNT_NEBRA_MONITOR
  mon

  endpoints=HNT_NEBRA_IPS
  end_point

  hotspot
  end
}

sensecap() {
  clear

  id=sensecap
  echo "What are the serial numbers of the ${id} miner(s)? Please separate them by a [space]"
  echo "ex: serial1 serial2"
  echo
  read ips

  monitor=HNT_SENSECAP_MONITOR
  mon

  endpoints=HNT_SENSECAP_SERIAL_NUMBER
  end_point

  echo
  echo "Enter your sensecap api key"
  echo
  read ips
  
  end_point

  hotspot
  end
}

hotspot() {
  clear
  address_endp

  if [ "${HNT_HOTSPOT_ADDRESSES}" ]; then
    HNT_HOTSPOT_ADDRESSES="${HNT_HOTSPOT_ADDRESSES} ${ips}"
  else
    HNT_HOTSPOT_ADDRESSES="${ips}"
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
                     setup
                     ;;
                   n|N|no|No|NO)
                     config
                     ;;
                   *)
                     echo "invalid response: ${end_resp}"
                     end
                     exit 0
  esac    
}

config() {
  HNT_HOTSPOT_ADDRESSES=$(echo "${HNT_HOTSPOT_ADDRESSES}" | tr ' ' '\n' | sort -u | sed 's%^$%%' | tr '\n' ' ')

  if [ "$(grep "HNT_HOTSPOT_ADDRESSES" ${YAML} 2>/dev/null)" ]; then
    ${sedi} "s%HNT_HOTSPOT_ADDRESSES:.*%HNT_HOTSPOT_ADDRESSES: \"${HNT_HOTSPOT_ADDRESSES}\"%" ${YAML}
  else
    ${sedi} "s%DO_NOT_REMOVE:\(.*\)%DO_NOT_REMOVE:\1\n      HNT_HOTSPOT_ADDRESSES: \"${HNT_HOTSPOT_ADDRESSES}\"%" ${YAML}
  fi

  rm -f "${YAML}"\'\'
}

deploy() {
  clear
  echo "Ready to deploy?"
  echo
  read deploy

  while [ ! "${deploy}" ]; do
    echo "Please choose a valid option: [yes|no]"
    read deploy
  done

  case ${deploy} in 
                 y|Y|yes|Yes|YES)
                   docker-compose -f ${YAML} up -d --build
                   finish
                   donate
                   ;;
                 *)
                   echo "Action cancelled"
                   exit 0
                   ;;
  esac
}

finish() {
  clear
  echo "You're all set! Take a look at the docs to setup the application interface"
  echo
  echo "Grafana:                 http://localhost:3000"
  echo "Prometheus Server:       http://localhost:3000"
  echo "Prometheus Push Gateway: http://localhost:9091"
  echo
  echo "Docs:                    https://github.com/nhatfield/hnt_monitor#whats-next"
  read resp
}

update() {
  git checkout "${RELEASE_BRANCH}"
  git pull
  deploy
}

version() {
  echo "HNT Monitor v$(grep '#' HISTORY.md | sed 's%# %%' | sort -V | tail -1)"
}

donate() {
  clear
  echo
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
            view)
              view
              ;;
            version | -v | --version)
              version
              ;;
            *)
              echo "invalid option: ${OPT}"
              ;;
esac
