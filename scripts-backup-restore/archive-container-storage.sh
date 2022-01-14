#!/bin/bash

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
  echo "archive-container-storage.sh: Archive project container persistent storage on the host"
  echo ""
  echo "Help: archive-container-storage.sh"
  echo "Usage: ./archive-container-storage.sh -n hostname -m mode"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host on which to start project containers"
  echo -e "-m mode \t\t(Mandatory) Mode for the project deployment, e.g. standalone"
  echo -e "-h \t\t\tPrint this help message"
  echo ""
  exit 1
}

errorMessage()
{
  echo "Invalid option or input variables are missing"
  echo "Use \"./archive-container-storage.sh -h\" for help"
  exit 1
}

while getopts n:m:h flag
do
  case "${flag}" in
    n) hostname=${OPTARG};;
    m) mode=${OPTARG};;
    h) helpMessage ;;
    ?) errorMessage ;;
  esac
done

if [ -z "$hostname" ] ||  [ -z "$mode" ]
then
  errorMessage
fi

# Archive project container persistent storage

echo ""
echo "Archiving project container persistent storage on "$hostname"..."
ansible-playbook -i "$SCRIPT_DIR"/../../ryo-host/configuration/inventory_"$hostname" "$SCRIPT_DIR"/archive-container-storage.yml --extra-vars "host_id="$hostname""
