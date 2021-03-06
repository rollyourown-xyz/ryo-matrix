#!/bin/bash

# SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
  echo "delete-project-containers.sh: Delete the containers of a rollyourown project"
  echo ""
  echo "Help: delete-project-containers.sh"
  echo "Usage: ./delete-project-containers.sh -n hostname"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host on which to delete project containers"
  echo -e "-h \t\t\tPrint this help message"
  echo ""
  exit 1
}

errorMessage()
{
  echo "Invalid option or input variables are missing"
  echo "Use \"./delete-project-containers.sh -h\" for help"
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


# Deleting project containers
#############################

echo ""
echo "Deleting project container..."

if [ "$PROJECT_IDP_MODE" == "standalone" ]
then
  echo "...deleting synapse-admin container"
  lxc delete --force "$hostname":synapse-admin
  echo ""
fi

echo "...deleting element container"
lxc delete --force "$hostname":element
echo ""

echo "...deleting synapse container"
lxc delete --force "$hostname":synapse
echo ""

echo "...deleting project container persistent storage"
ansible-playbook -i "$SCRIPT_DIR"/../../ryo-host/configuration/inventory_"$hostname" "$SCRIPT_DIR"/../backup-restore/delete-project-persistent-storage.yml --extra-vars "project_id="$PROJECT_ID" host_id="$hostname""
echo ""

echo "Project containers deleted"
echo ""
