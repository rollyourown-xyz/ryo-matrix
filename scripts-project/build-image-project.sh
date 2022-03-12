#!/bin/bash

# SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later

# Default project software versions
element_version="1.10.6"
synapse_version="1.54.0"
synapse_admin_version="0.8.5"

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
  echo "build-image-project.sh: Use packer to build project images for deployment"
  echo ""
  echo "Help: build-image-project.sh"
  echo "Usage: ./build-image-project.sh -m -n hostname -g grav_version -v version"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host for which to build images"
  echo -e "-v version \t\t(Mandatory) Version stamp to apply to images, e.g. 20210101-1"
  echo -e "-m mode \t\t(Mandatory) Mode for the project deployment, e.g. standalone"
  echo -e "-h \t\t\tPrint this help message"
  echo ""
  exit 1
}

errorMessage()
{
  echo "Invalid option or mandatory input variable is missing"
  echo "Use \"./build-image-project.sh -h\" for help"
  exit 1
}

while getopts n:v:m:h flag
do
  case "${flag}" in
    n) hostname=${OPTARG};;
    v) version=${OPTARG};;
    m) mode=${OPTARG};;
    h) helpMessage ;;
    ?) errorMessage ;;
  esac
done

if [ -z "$hostname" ] || [ -z "$version" ] || [ -z "$mode" ]
then
  errorMessage
fi


# Build project images

# Element-web webserver
echo ""
echo "Building element-web image on "$hostname""
echo "Executing command: packer build -var \"host_id="$hostname"\" -var \"element_version=$element_version\" -var \"version=$version\" "$SCRIPT_DIR"/../image-build/element.pkr.hcl"
packer build -var "host_id="$hostname"" -var "element_version=$element_version" -var "version=$version" "$SCRIPT_DIR"/../image-build/element.pkr.hcl
echo "Completed"

# Synapse homeserver
echo ""
echo "Building synapse image on "$hostname""
echo "Executing command: packer build -var \"host_id="$hostname"\" -var \"version=$version\" -var \"synapse_version=$synapse_version\" "$SCRIPT_DIR"/../image-build/synapse.pkr.hcl"
packer build -var "host_id="$hostname"" -var "version=$version" -var "synapse_version=$synapse_version" "$SCRIPT_DIR"/../image-build/synapse.pkr.hcl
echo "Completed"

# Synapse-admin webserver

if [ $mode == "standalone" ]
then
  echo ""
  echo "Building synapse-admin image on "$hostname""
  echo "Executing command: packer build -var \"host_id="$hostname"\" -var \"version=$version\" -var \"synapse_admin_version=$synapse_admin_version\" "$SCRIPT_DIR"/../image-build/synapse-admin.pkr.hcl"
  packer build -var "host_id="$hostname"" -var "version=$version" -var "synapse_admin_version=$synapse_admin_version" "$SCRIPT_DIR"/../image-build/synapse-admin.pkr.hcl
  echo "Completed"
fi