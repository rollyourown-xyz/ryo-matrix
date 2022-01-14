#!/bin/bash

# backup.sh
# This script backs up the persistent storage for the modules required for the project and for the project's components 

# Required modules (space-separated list in the form "module_1 module_2 module_3")
MODULES="ryo-ingress-proxy ryo-postgres ryo-coturn ryo-wellknown"


# Help and error messages
#########################

helpMessage()
{
  echo "backup.sh: Back up project container persistent storage from the host to the control node"
  echo ""
  echo "Help: backup.sh"
  echo "Usage: ./backup.sh -n hostname -m mode"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host from which to back up project container persistent storage"
  echo -e "-h \t\t\tPrint this help message"
  echo ""
  exit 1
}

errorMessage()
{
  echo "Invalid option or input variables are missing"
  echo "Use \"./backup.sh -h\" for help"
  exit 1
}


# Command-line input handling
#############################

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


# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Get Project ID from configuration file
PROJECT_ID="$(yq eval '.project_id' "$SCRIPT_DIR"/configuration/configuration_"$hostname".yml)"

# Get Project IdP mode from configuration file
PROJECT_IDP_MODE="$(yq eval '.project_idp_mode' "$SCRIPT_DIR"/configuration/configuration_"$hostname".yml)"

modeErrorMessage()
{
  echo "Invalid IdP mode \""$PROJECT_IDP_MODE"\". Please check configuration."
  exit 1
}

# Check IdP mode in configuration is supported
if [ ! "$PROJECT_IDP_MODE" == "standalone" ] && [ ! "$PROJECT_IDP_MODE" == "gitea" ]; then
  modeErrorMessage
fi


# Info
echo "rollyourown.xyz backup script for "$PROJECT_ID""


# Update project repository
###########################

echo ""
echo "Refreshing project repository with git pull to ensure the current version"
git pull


# Stop project containers
##########################

echo ""
echo "Stop project containers on "$hostname""
/bin/bash "$SCRIPT_DIR"/scripts-project/stop-project-containers.sh -n "$hostname" -m "$PROJECT_IDP_MODE"


# Back up project container persistent storage
##############################################

###
### TODO: Try without become
###
echo ""
echo "Back up project container persistent storage on "$hostname""
ansible-playbook -i "$SCRIPT_DIR"/../ryo-host/configuration/inventory_"$hostname" "$SCRIPT_DIR"/backup-restore/backup-container-storage.yml --extra-vars "host_id="$hostname""


# Back up Modules
#################

# TODO
## WITH USER INPUT WHETHER TO BACK UP MODULES AND WHICH ONES



# Start project containers
##########################

echo ""
echo "Start project containers on "$hostname""
/bin/bash "$SCRIPT_DIR"/scripts-project/start-project-containers.sh -n "$hostname" -m "$PROJECT_IDP_MODE"