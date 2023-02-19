#!/bin/bash

#Variable / Function
VERSION="1.4"

#live
#SERVER_URL="https://raw.githubusercontent.com/BassT23/Proxmox/master"
#beta
SERVER_URL="https://raw.githubusercontent.com/BassT23/Proxmox/beta"
LOCAL_FILES="/root/Proxmox-Updater"

#Colors
BL='\033[36m'
RD='\033[01;31m'
GN='\033[1;92m'
CL='\033[m'

#Header
function HEADER_INFO {
  clear
  echo -e "\n \
      https://github.com/BassT23/Proxmox"
  cat <<'EOF'
     ____
    / __ \_________  _  ______ ___  ____  _  __
   / /_/ / ___/ __ \| |/_/ __ `__ \/ __ \| |/_/
  / ____/ /  / /_/ />  </ / / / / / /_/ />  <
 /_/   /_/   \____/_/|_/_/ /_/ /_/\____/_/|_|
      __  __          __      __
     / / / /___  ____/ /___ _/ /____  ____
    / / / / __ \/ __  / __ `/ __/ _ \/ __/
   / /_/ / /_/ / /_/ / /_/ / /_/  __/ /
   \____/ .___/\____/\____/\__/\___/_/
       /_/
EOF
  echo -e "\n \
      *** Install and/or Update *** \n \
      ***    Version :   $VERSION    *** \n"
  CHECK_ROOT
}

#Check root
function CHECK_ROOT {
  if [[ $EUID -ne 0 ]]; then
      echo -e >&2 "${RD}--- Please run this as root ---${CL}";
      exit 1
  fi
}

function USAGE {
    if [[ $SILENT != true ]]; then
        echo -e "Usage: $0 [OPTIONS...] {COMMAND}\n"
        echo -e "[OPTIONS] Manages the Proxmox-Updater:"
        echo -e "======================================"
        echo -e "  -h --help            Show this help"
        echo -e "  -s --silent          Silent mode\n"
        echo -e "Commands:"
        echo -e "========="
        echo -e "  status               Check current installation status"
        echo -e "  install              Install Proxmox-Updater"
        echo -e "  uninstall            Uninstall Proxmox-Updater"
        echo -e "  update               Update Proxmox-Updater\n"
        echo -e "Report issues at: <https://github.com/BassT23/Proxmox/issues>\n"
    fi
}

function isInstalled {
    if [ -f "/usr/local/bin/update" ]; then
        true
    else
        false
    fi
}

function STATUS {
    if [[ $SILENT != true ]]; then
        echo -e "Proxmox-Updater"
        if isInstalled; then
            echo -e "Status: ${GN}present${CL}\n"
        else
            echo -e "Status: ${RD}not present${CL}\n"
        fi
    fi
    if isInstalled; then exit 0; else exit 1; fi
}

function INSTALL {
    echo -e "\n${BL}[Info]${GN} Installing Proxmox-Updater${CL}\n"
    if [ -f "/usr/local/bin/update" ]; then
      echo -e "${RD}Proxmox-Updater is already installed.${CL}"
      read -p "Should I update for you? Type [Y/y] or Enter for yes - enything else will exit " -n 1 -r -s
      if [[ $REPLY =~ ^[Yy]$ || $REPLY = "" ]]; then
        bash <(curl -s $SERVER_URL/install.sh) update
      else
        echo -e "\nBye\n"
        exit 0
      fi
    else
      mkdir -p /root/Proxmox-Updater/exit
      curl -s $SERVER_URL/update.sh > /usr/local/bin/update
      chmod 750 /usr/local/bin/update
      curl -s $SERVER_URL/exit/error.sh > $LOCAL_FILES/exit/error.sh
      curl -s $SERVER_URL/exit/passed.sh > $LOCAL_FILES/exit/passed.sh
      curl -s $SERVER_URL/update-extras.sh > $LOCAL_FILES/update-extras.sh
      curl -s $SERVER_URL/update.conf > $LOCAL_FILES/update.conf
      chmod -R +x $LOCAL_FILES/exit/*.sh
      echo -e "${BL}Finished. Run Proxmox-Updater with 'update'.${CL}\n"
    fi
}

function UPDATE {
    if [ -f "/usr/local/bin/update" ]; then
      if [ -d "/root/Proxmox-Update-Scripts" ]; then
        echo -e "${RD}Proxmox-Updater has changed directorys, so the old directory\n\
/root/Update-Scripts will be delete.\n\
Is it OK for you, or want to backup first your files?${CL}\n"
        read -p "Type [Y/y] for DELETE - enything else will exit " -n 1 -r -s
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          rm -r /root/Update-Proxmox-Scripts
          bash <(curl -s $SERVER_URL/install.sh) update
        else
          exit 0
        fi
      else
        echo -e "\n${BL}[Info]${GN} Updating script ...${CL}\n"
        curl -s $SERVER_URL/update.sh > /usr/local/bin/update
        # Check if files are different
        mkdir -p /root/Proxmox-Updater-Temp/exit
        curl -s $SERVER_URL/exit/error.sh > /root/Proxmox-Updater-Temp/exit/error.sh
        curl -s $SERVER_URL/exit/passed.sh > /root/Proxmox-Updater-Temp/exit/passed.sh
        curl -s $SERVER_URL/update-extras.sh > /root/Proxmox-Updater-Temp/update-extras.sh
        curl -s $SERVER_URL/update.conf > /root/Proxmox-Updater-Temp/update.conf
        chmod -R +x $LOCAL_FILES/exit/*.sh
        cd /root/Proxmox-Updater-Temp
        FILES="*.* **/*.*"
        for f in $FILES
        do
          CHECK_DIFF
        done
        rm -r /root/Proxmox-Updater-Temp
        echo -e "${GN}Proxmox-Updater updated successfully.${CL}\n"
      fi
    else
      echo -e "${RD}Proxmox-Updater is not installed.\n\n${GN}Would you like to install it?${CL}"
      read -p "Type [Y/y] or Enter for yes - enything else will exit " -n 1 -r -s
      if [[ $REPLY =~ ^[Yy]$ || $REPLY = "" ]]; then
        bash <(curl -s $SERVER_URL/install.sh)
      else
        echo -e "\n\nBye\n"
        exit 0
      fi
    fi
}

function INCLUDE_VM {
  echo "Want to Update VM also?"
}

function CHECK_DIFF {
  if ! cmp -s "/root/Proxmox-Updater-Temp/$f" "$LOCAL_FILES/$f"; then
    echo -e "The file $f\n \
 ==> Modified (by you or by a script) since installation.\n \
   What would you like to do about it ?  Your options are:\n \
    Y or y  : install the package maintainer's version (old file will be save as 'file.bak')\n \
    N or n  : keep your currently-installed version\n \
    S or s  : show the differences between the versions\n \
 The default action is to keep your current version.\n \
*** $f (Y/y/N/n/S/s) [default=Y] ? "
        read -p "" -n 1 -r -s
        if [[ $REPLY =~ ^[Yy]$ || $REPLY = "" ]]; then
          echo -e "\n${BL}[Info]${GN} Installed server version and backed up old file${CL}\n"
          cp -f "$LOCAL_FILES/$f" "$LOCAL_FILES/$f.bak"
          mv "/root/Proxmox-Updater-Temp/$f" "$LOCAL_FILES/$f"
        elif [[ $REPLY =~ ^[Nn]$ ]]; then
          echo -e "\n${BL}[Info]${GN} Kept old file${CL}\n"
        elif [[ $REPLY =~ ^[Ss]$ ]]; then
          echo
          diff "/root/Proxmox-Updater-Temp/$f" "$LOCAL_FILES/$f"
        else
          echo -e "\n${BL}[Info]${GN} Skip this file${CL}\n"
        fi
  fi
}

function UNINSTALL {
  if [ -f "/usr/local/bin/update" ]; then
    echo -e "\n${BL}[Info]${GN} Uninstall Proxmox-Updater${CL}\n"
    echo -e "${RD}Really want to remove Proxmox-Updater?${CL}"
    read -p "Type [Y/y] for yes - enything else will exit " -n 1 -r -s
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      rm /usr/local/bin/update
      rm -r /root/Proxmox-Updater
      echo -e "\n\n${BL}Proxmox-Updater removed${CL}\n"
    fi
  else
    echo -e "${RD}Proxmox-Updater is not installed.${CL}\n"
  fi
}

#Error/Exit
set -e
function EXIT {
  EXIT_CODE=$?
  # Install Finish
  if [[ $EXIT_CODE == "1" ]]; then
    exit 0
  elif [[ $EXIT_CODE != "0" ]]; then
    echo -e "${RD}Error during install --- Exit Code: $EXIT_CODE${CL}\n"
  fi
}

# Exit Code
trap EXIT EXIT

#Install
HEADER_INFO
parse_cli()
{
  while test $# -gt -0
  do
    _key="$1"
    case "$_key" in
      -h|--help)
        USAGE
        exit 0
        ;;
      -s|--silent)
        SILENT=true
        ;;
      status)
        STATUS
        exit 0
        ;;
      install)
        COMMAND=true
        INSTALL
        exit 0
        ;;
      uninstall)
        COMMAND=true
        UNINSTALL
        exit 0
        ;;
      update)
        COMMAND=true
        UPDATE
        exit 0
        ;;
      *)
        echo -e "${RD}Error: Got an unexpected argument \"$_key\"${CL}\n";
        USAGE;
        exit 1;
        ;;
    esac
    shift
  done
}
parse_cli "$@"

# Run without commands
if [[ $COMMAND != true ]]; then
  INSTALL
fi
