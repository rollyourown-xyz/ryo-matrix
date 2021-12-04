#!/bin/bash

# upgrade.sh
# This script upgrades the modules required for the project and the project components 

# Project ID
PROJECT_ID="ryo-matrix-standalone"

# Required modules (space-separated list in the form "module_1 module_2 module_3")
MODULES="ryo-service-proxy ryo-postgres ryo-coturn ryo-wellknown"

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Info
echo "rollyourown.xyz upgrade script for "$PROJECT_ID""


# Help and error messages
#########################

helpMessage()
{
  echo "upgrade.sh: Upgrade a rollyourown.xyz project"
  echo "Usage: ./upgrade.sh -n hostname -v version"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host on which to upgrade the project"
  echo -e "-v version \t\t(Mandatory) Version stamp for images to upgrade, e.g. 20210101-1"
  echo -e "-h \t\t\tPrint this help message"
  echo ""
  exit 1
}

errorMessage()
{
  echo "Invalid option or input variables are missing"
  echo "Use \"./deploy.sh -h\" for help"
  exit 1
}


# Command-line input handling
#############################

while getopts n:v:h flag
do
  case "${flag}" in
    n) hostname=${OPTARG};;
    v) version=${OPTARG};;
    h) helpMessage ;;
    ?) errorMessage ;;
  esac
done

if [ -z "$hostname" ] || [ -z "$version" ]; then
  errorMessage
fi


# Update project repository
###########################

echo "Refreshing project repository with git pull to get the current version"
git pull


# Upgrade Modules
#################

# For each module, do module upgrade if user agrees
echo ""
echo "Module upgrades"

for module in $MODULES
do
  echo ""
  echo -n "Upgrade "$module" module (default is 'n')? "
  read -e -p "[y/n]:" UPGRADE_MODULE
  UPGRADE_MODULE="${UPGRADE_MODULE:-"n"}"
  UPGRADE_MODULE="${UPGRADE_MODULE,,}"

  # Check input
  while [ ! "$UPGRADE_MODULE" == "y" ] && [ ! "$UPGRADE_MODULE" == "n" ]
  do
    echo "Invalid option "${UPGRADE_MODULE}". Please try again."
    echo -n "Upgrade "$module" module (default is 'n')? "
    read -e -p "[y/n]:" UPGRADE_MODULE
    UPGRADE_MODULE="${UPGRADE_MODULE:-"y"}"
    UPGRADE_MODULE="${UPGRADE_MODULE,,}"
  done

  if [ "$UPGRADE_MODULE" == "y" ]; then
    echo "Upgrading "$module" module."
    # git pull module repository
    echo ""
    echo "Updating "$module" repository..."
    /bin/bash "$SCRIPT_DIR"/scripts-modules/get-module.sh -m "$module"
    echo ""
    echo ""$module" module repository updated."
    # Run packer image build for modules
    echo ""
    echo "Building new image(s) for "$module" module on "$hostname"..."
    /bin/bash "$SCRIPT_DIR"/scripts-modules/build-image-module.sh -n "$hostname" -v "$version" -m "$module"
    echo ""
    echo ""$module" module image build(s) completed on "$hostname"."
    # Deploy module
    echo ""
    echo "Deploying new image(s) for "$module" module on "$hostname"..."
    /bin/bash "$SCRIPT_DIR"/scripts-modules/deploy-module.sh -n "$hostname" -v "$version" -m "$module"
    echo ""
    echo ""$module" module deployment completed."
  else
    echo "Skipping "$module" module upgrade."
  fi
done


# Upgrade project components
############################

# Build new project images
echo ""
echo "Building new image(s) for "$PROJECT_ID" on "$hostname""
/bin/bash "$SCRIPT_DIR"/scripts-project/build-image-project.sh -n "$hostname" -v "$version"

# Deploy project containers
echo ""
echo "Deploying new image(s) for "$PROJECT_ID" on "$hostname""
/bin/bash "$SCRIPT_DIR"/scripts-project/deploy-project.sh -n "$hostname" -v "$version"
