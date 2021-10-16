#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
   echo "deploy-project.sh: Use terraform to deploy project"
   echo ""
   echo "Help: deploy-project.sh"
   echo "Usage: ./deploy-project.sh -v version"
   echo "Flags:"
   echo -e "-m \t\t\t(Optional) Flag to also deploy modules"
   echo -e "-n hostname \t\t(Mandatory) Name of the host on which to deploy the project"
   echo -e "-v version \t\tVersion stamp for images to deploy, e.g. 20210101-1"
   echo -e "-h \t\t\tPrint this help message"
   echo ""
   exit 1
}

errorMessage()
{
   echo "Invalid option or input variables are missing"
   echo "Use \"./deploy-project.sh -h\" for help"
   exit 1
}

# Project ID
project_id='ryo-matrix-standalone'

deploy_modules='false'

while getopts mn:v:h flag
do
    case "${flag}" in
        m) deploy_modules='true';;
        n) hostname=${OPTARG};;
        v) version=${OPTARG};;
        h) helpMessage ;;
        ?) errorMessage ;;
    esac
done

if [ -z "$hostname" ] || [ -z "$version" ]
then
   errorMessage
fi

# Deploy ryo-service-proxy if -m flag is present
if [ $deploy_modules == 'true' ]
then
   echo "Deploying ryo-service-proxy module on "$hostname" using images with version "$version""
   echo ""
   "$SCRIPT_DIR"/../ryo-service-proxy/deploy-module.sh -n "$hostname" -v "$version"
   echo ""
else
   echo "Skipping modules deployment"
   echo ""
fi

# Deploy ryo-postgres if -m flag is present
if [ $deploy_modules == 'true' ]
then
   echo "Deploying ryo-postgres module on "$hostname" using images with version "$version""
   echo ""
   "$SCRIPT_DIR"/../ryo-postgres/deploy-module.sh -n "$hostname" -v "$version"
   echo ""
else
   echo "Skipping modules deployment"
   echo ""
fi

# Deploy ryo-coturn if -m flag is present
if [ $deploy_modules == 'true' ]
then
   echo "Deploying ryo-coturn module on "$hostname" using images with version "$version""
   echo ""
   "$SCRIPT_DIR"/../ryo-coturn/deploy-module.sh -n "$hostname" -v "$version"
   echo ""
else
   echo "Skipping modules deployment"
   echo ""
fi

# Deploy ryo-wellknown if -m flag is present
if [ $deploy_modules == 'true' ]
then
   echo "Deploying ryo-wellknown module on "$hostname" using images with version "$version""
   echo ""
   "$SCRIPT_DIR"/../ryo-wellknown/deploy-module.sh -n "$hostname" -v "$version"
   echo ""
else
   echo "Skipping modules deployment"
   echo ""
fi


# Deploy project
echo "Deploying project on "$hostname" using images with version=$version"
echo ""

## Set up / switch to project workspace for host
if [ -f ""$SCRIPT_DIR"/configuration/"$hostname"_workspace_created" ]
then
   echo "Workspace for host "$hostname" already created, switching to workspace"
   echo ""
   echo "Executing command terraform -chdir="$SCRIPT_DIR"/project-deployment workspace select $hostname"
   echo ""
   terraform -chdir="$SCRIPT_DIR"/project-deployment workspace select $hostname
   echo ""
else
   echo "Creating workpsace for host "$hostname" and switching to it"
   echo ""
   echo "Executing command: terraform -chdir="$SCRIPT_DIR"/project-deployment workspace new $hostname"
   echo ""
   terraform -chdir="$SCRIPT_DIR"/project-deployment workspace new $hostname
   echo ""
   touch "$SCRIPT_DIR"/configuration/"$hostname"_workspace_created
fi

echo "Executing command: terraform -chdir="$SCRIPT_DIR"/project-deployment init"
echo ""
terraform -chdir="$SCRIPT_DIR"/project-deployment init
echo ""
echo "Executing command: terraform -chdir="$SCRIPT_DIR"/project-deployment apply -input=false -auto-approve -var \"host_id=$hostname\" -var \"image_version=$version\""
echo ""
terraform -chdir="$SCRIPT_DIR"/project-deployment apply -input=false -auto-approve -var "host_id=$hostname" -var "image_version=$version"
echo ""
echo "Completed"
