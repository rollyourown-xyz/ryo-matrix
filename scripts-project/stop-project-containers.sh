#!/bin/bash

# SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
  echo "stop-project-containers.sh: Stop the containers of a rollyourown.xyz project"
  echo ""
  echo "Help: stop-project-containers.sh"
  echo "Usage: ./stop-project-containers.sh -n hostname"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host on which to stop project containers"
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

while getopts n:h flag
do
  case "${flag}" in
    n) hostname=${OPTARG};;
    h) helpMessage ;;
    ?) errorMessage ;;
  esac
done

if [ -z "$hostname" ]
then
  errorMessage
fi


# Get Project IdP mode from configuration file
PROJECT_IDP_MODE="$(yq eval '.project_idp_mode' "$SCRIPT_DIR"/../configuration/configuration_"$hostname".yml)"

modeErrorMessage()
{
  echo "Invalid IdP mode \""$PROJECT_IDP_MODE"\". Please check configuration."
  exit 1
}

# Check IdP mode in configuration is supported
if [ ! "$PROJECT_IDP_MODE" == "standalone" ] && [ ! "$PROJECT_IDP_MODE" == "gitea" ]; then
  modeErrorMessage
fi



# Stop project containers
#########################

echo ""
echo "Stopping project containers..."

if [ "$PROJECT_IDP_MODE" == "standalone" ]
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
