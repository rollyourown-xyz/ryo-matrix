#!/bin/bash

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
  echo "stop-project-containers.sh: Stop the containers of a rollyourown.xyz project"
  echo ""
  echo "Help: stop-project-containers.sh"
  echo "Usage: ./stop-project-containers.sh -n hostname -m mode"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host on which to stop project containers"
  echo -e "-m mode \t\t(Mandatory) Mode for the project deployment, e.g. standalone"
  echo -e "-h \t\t\tPrint this help message"
  echo ""
  exit 1
}

errorMessage()
{
  echo "Invalid option or input variables are missing"
  echo "Use \"./stop-project-containers.sh -h\" for help"
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

# Stop project containers

echo ""
echo "Stopping project containers..."

if [ $mode == "standalone" ]
then
  echo "...stopping synapse-admin container"
  lxc stop "$hostname":synapse-admin
  echo ""
fi

echo "...stopping element container"
lxc stop "$hostname":element
echo ""

echo "...stopping synapse container"
lxc stop "$hostname":synapse
echo ""

echo "Project containers stopped"
echo ""
