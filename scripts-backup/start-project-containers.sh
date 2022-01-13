#!/bin/bash

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
  echo "start-project-containers.sh: Stop the containers of a rollyourown.xyz project"
  echo ""
  echo "Help: start-project-containers.sh"
  echo "Usage: ./start-project-containers.sh -n hostname -m mode"
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
  echo "Use \"./start-project-containers.sh -h\" for help"
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

# Start project containers

echo ""
echo "Starting project containers"

if [ $mode == "standalone" ]
then
  echo "Starting synapse-admin container - Executing command: lxc start "$hostname":synapse-admin"
  lxc start "$hostname":synapse-admin
  echo ""
fi

echo "Starting element container - Executing command: lxc start "$hostname":element"
lxc start "$hostname":element
echo ""

echo "Starting synapse container - Executing command: lxc start "$hostname":synapse"
lxc start "$hostname":element
echo ""

echo "Project containers started"
echo ""
