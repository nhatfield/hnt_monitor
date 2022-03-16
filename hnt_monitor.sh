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
YAML=${YAML:-".hnt_monitor.yml"}

if [ ! -f "${YAML}" ]; then
  cp hnt_monitor.yml "${YAML}"
fi

os=$(uname)

if [ "${os}" == "Darwin" ]; then
  sedi="gsed -i"
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
                  clear
                  echo "Starting installation ..."
                  prereq
                  setup
                  deploy
                  ;;
                setting|settings|Setting|Settings|SETTING|SETTINGS|2)
                  setup
                  config
                  ;;
                update|Update|UPDATE|upgrade|Upgrade|UPGRADE|3)
                  update
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
  echo "Press [enter] key to continue ..."
  read resp

} 

prereq() {
  echo "Verifying software dependencies are installed"
  if [ ! "$(which docker 2>/dev/null)" ] || [ ! "$(which docker-compose 2>/dev/null)" ]; then
    echo "Docker was not detected. Installing..."
    if [ "$(which yum 2>/dev/null)" ]; then
      echo "The script wants to update your system [yum update -y]. This will update all of your systems software! Would you like to proceed? [yes|no]"
      echo
      read up_resp

      case ${up_resp} in
                      y|Y|yes|Yes|YES)
                        yum update -y
                        yum install -y epel-release
                        yum update -y
                        ;;
                      n|N|no|No|NO)
                        echo "skipping updates"
                        ;;
                      *)
                        echo "Please choose a valid option: [yes|no]"
                        ;;
      esac

      yum install docker docker-compose -y
      service docker start || systemctl start docker
    elif [ "$(which apt-get 2>/dev/null)" ]; then
      echo "The script wants to update your system [apt-get update -y] and [apt-get upgrade -y]. This will update all of your systems software! Would you like to proceed? [yes|no]"
      echo
      read up_resp

      case ${up_resp} in
                      y|Y|yes|Yes|YES)
                        apt-get update -y
                        apt-get upgrade -y
                        ;;
                      n|N|no|No|NO)
                        echo "skipping updates"
                        ;;
                      *)
                        echo "Please choose a valid option: [yes|no]"
                        ;;
      esac

      if [ "$(uname -a | tr ' ' '\n' | grep arm)" ]; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo chmod 755 get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker ${USER}
        sudo apt-get install libffi-dev libssl-dev -y
        sudo apt install python3-dev -y
        sudo apt-get install -y python3 python3-pip
        sudo pip3 install docker-compose

        echo "You may need to reboot your ARM device for these changes to take effect."
        echo "... continuing in 5 seconds"
        sleep 5
      else
        apt-get install docker docker-compose -y
        service docker start || systemctl start docker
      fi
    else
      if [ ! "$(which brew 2>/dev/null)" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
  
      if [ ! "$(which cask 2>/dev/null)" ]; then
        brew install cask
      fi

      fail=""
      brew install --cask docker-toolbox || fail=true

      if [ "${fail}" == "true" ]; then
        echo -e "\n\nCould not install the docker-toolbox. Check your System & Privacy settings under System Preferences and allow the blocked app \"Oracle VirtualBox\". Then re-run the setup again"
        exit 1
      fi

      brew install docker-machine || brew link --overwrite docker-machine
      docker-machine create --driver "virtualbox" devbox || true
      docker-machine start devbox
      eval "$(docker-machine env devbox)"

      if [ ! "$(grep 'docker-machine env devbox' "${HOME}"/.zshrc 2>/dev/null)" ]; then
        echo 'if ! docker-machine status devbox | grep -q "Running"; then' >> "${HOME}"/.zshrc
        echo '  docker-machine start devbox' >> "${HOME}"/.zshrc
        echo 'fi' >> "${HOME}"/.zshrc
        echo 'eval "$(docker-machine env devbox)"' >> "${HOME}"/.zshrc
      fi

      if [ ! "$(which gsed 2>/dev/null)" ]; then
        brew install gnu-sed
      fi
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
  echo "5. Hotspot (blockchain metrics)"
  echo "6. Deploy"
  echo "7. back"
  echo "8. exit"
  echo
  read install

  while [ ! "${install}" ]; do
    echo "Please choose a valid option from the listed items above."
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
                  hotspot|Hotspot|HOTSPOT|5)
                    hotspot
                    ;;
                  deploy|Deploy|DEPLOY|6)
                    deploy
                    exit 0
                    ;;
                  back|7)
                    intro
                    exit 0
                    ;;
                  exit|8)
                    exit 0
                    ;;
  esac
}

address_endp() {
  echo "What are the hotspot addresses of the ${id} miner(s)? Please separate them by a [space]"
  echo "ex: 112GezswE 114vTyhUnKo"
  echo
  validate
}

ips_endp() {
  echo "What are the PRIVATE IP addresses of your ${id} miner(s)? Please separate them by a [space]"
  echo "ex: 192.168.0.1 10.10.0.3 172.16.2.5"
  echo
  validate
}

validate() {
  val=$(grep "${endpoints}" ${YAML} 2>/dev/null | sed "s%.*: %%;s%\"%%g") || true
  
  if [ "${val}" ]; then
    echo "Keep existing? [yes|no]"
    echo 
    echo "> \"${val}\""
    echo

    read val_resp

    case ${val_resp} in
                   y|Y|yes|Yes|YES)
                     type=keeping
                     ips=${val}
                     ;;
                   n|N|no|No|NO)
                     type=changing
                     echo "Enter your ips separated by a [space]"
                     echo
                     read ips

                     if [ ! "${ips}" ]; then
                       none
                     fi

                     ;;
                   *)
                     echo "Invalid response: ${val_resp}"
                     echo "[yes|no]"
                     echo "No rchanges committed. Returning to the miner setup menu."
                     sleep 2
                     setup
                     exit 0
                     ;;
    esac
  else
    type=adding
    read ips
    
    if [ ! "${ips}" ]; then
      none
    fi
  fi
}

none() {
  echo "No rchanges committed. Returning to the miner setup menu"
  sleep 2
  setup
  exit 0
}

end_point() {
  echo "${id}: ${type} - ${endpoints} = \"${ips}\""
  if [ "$(grep "${endpoints}" ${YAML} 2>/dev/null)" ]; then
    ${sedi} "s%${endpoints}:.*%${endpoints}: \"${ips}\"%" "${YAML}"
  else
    ${sedi} "s%${monitor}:\(.*\)%${monitor}:\1\n      ${endpoints}: \"${ips}\"%" "${YAML}"
  fi
}

start_point() {
  echo "${id}: enabling - ${monitor} = \"true\""
  if [ "$(grep "${monitor}" ${YAML} 2>/dev/null)" ]; then
    ${sedi} "s%${monitor}:.*%${monitor}: \"true\"%" "${YAML}"
  else
    ${sedi} "s%DO_NOT_REMOVE:\(.*\)%DO_NOT_REMOVE:\1\n      ${monitor}: \"true\"%" "${YAML}"
  fi
}

bobcat() {
  clear
  id=bobcat
  monitor=HNT_BOBCAT_MONITOR
  endpoints=HNT_BOBCAT_IPS

  ips_endp
  start_point
  end_point
  sleep 2
  hotspot
  end  
}

longap() {
  clear
  id=longap
  monitor=HNT_LONGAP_MONITOR
  endpoints=HNT_LONGAP_ADDRESSES

  address_endp
  start_point
  end_point
  sleep 2
  hotspot
  end
}

nebra() {
  clear
  id=nebra
  monitor=HNT_NEBRA_MONITOR
  endpoints=HNT_NEBRA_IPS

  ips_endp
  start_point
  end_point
  sleep 2
  hotspot
  end
}

sensecap() {
  clear
  id=sensecap
  monitor=HNT_SENSECAP_MONITOR
  endpoints=HNT_SENSECAP_SERIAL_NUMBERS

  echo "What are the serial numbers of the ${id} miner(s)? Please separate them by a [space]"
  echo "ex: serial1 serial2"
  echo
  validate

  start_point
  end_point
  sleep 2
  hotspot
  sleep 2

  clear
  id=sensecap
  endpoints=HNT_SENSECAP_API_KEY
  echo "Enter your sensecap api key"
  echo
  validate
  
  end_point
  end
}

hotspot() {
  clear
  id=hotspot
  monitor=HNT_HOTSPOT_MONITOR
  endpoints=HNT_HOTSPOT_ADDRESSES

  address_endp
  start_point

  if [ "${HNT_HOTSPOT_ADDRESSES}" ]; then
    HNT_HOTSPOT_ADDRESSES="${HNT_HOTSPOT_ADDRESSES} ${ips}"
  else
    HNT_HOTSPOT_ADDRESSES="${ips}"
  fi
}

end() {
  echo "Would you like to add another miner? [yes|no]"
  echo
  read end_resp
  
  while [ ! "${end_resp}" ]; do
    echo "Please choose a valid option: [yes|no]"
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
  echo "Ready to deploy? [yes|no]"
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
  echo "Prometheus Server:       http://localhost:9090"
  echo "Prometheus Push Gateway: http://localhost:9091"
  echo
  echo "Docs:                    https://github.com/nhatfield/hnt_monitor#whats-next"
  echo "Donate:                  HNT: 1359NhpbxJg1jRpDenJvrmD2P3ZN3hWGSGzUF6Uyn828zYdyYVt"
  echo
  echo
  echo "Press [enter] key to continue ..."
  read resp
}

update() {
  git reset --hard
  git pull
  git checkout $(git tag | tail -1 | tr -dc .[:print:].)
  deploy
}

version() {
  echo "HNT Monitor v$(grep '#' HISTORY.md | sed 's%# %%' | sort -V | tail -1)"
}

donate() {
  clear
  cat .donate
  echo "Yes the QR code works. HNT wallet address =)"
  echo "Make your terminal window large enough to see the whole QR. Center your scanner and slowly pull your scanner away from the code until it accepts."
  echo "Thank you =)"
}

case ${OPT} in
            deploy)
              deploy
              ;;
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
            prereq|deps|dependencies)
              prereq
              ;;
            settings|setup)
              setup
              ;;
            view|configs)
              view
              ;;
            version | -v | --version)
              version
              ;;
            *)
              echo "invalid option: ${OPT}"
              ;;
esac
