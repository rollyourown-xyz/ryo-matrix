#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
   echo "build-images.sh: Use packer to build images for deployment"
   echo ""
   echo "Help: build-images.sh"
   echo "Usage: ./build-images.sh -m -n hostname -g grav_version -v version"
   echo "Flags:"
   echo -e "-m \t\t\t(Optional) Flag to also build images for modules"
   echo -e "-n hostname \t\t(Mandatory) Name of the host for which to build images"
   echo -e "-v version \t\t(Mandatory) Version stamp to apply to images, e.g. 20210101-1"
   echo -e "-h \t\t\tPrint this help message"
   echo ""
   exit 1
}

errorMessage()
{
   echo "Invalid option or mandatory input variable is missing"
   echo "Use \"./build-images.sh -h\" for help"
   exit 1
}

# Default software package versions
element_version='1.9.2'
synapse_version='1.44.0'

build_modules='false'

while getopts mn:v:h flag
do
    case "${flag}" in
        m) build_modules='true';;
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

# Build ryo-service-proxy module images if -m flag is present
if [ $build_modules == 'true' ]
then
   echo "Running build-images script for ryo-service-proxy module on "$hostname""
   echo ""
   "$SCRIPT_DIR"/../ryo-service-proxy/build-images.sh -n "$hostname" -v "$version"
else
   echo "Skipping image build for modules"
   echo ""
fi

# Build ryo-postgres module images if -m flag is present
if [ $build_modules == 'true' ]
then
   echo "Running build-images script for ryo-postgres module on "$hostname""
   echo ""
   "$SCRIPT_DIR"/../ryo-postgres/build-images.sh -n "$hostname" -v "$version"
else
   echo "Skipping image build for modules"
   echo ""
fi

# Build ryo-coturn module images if -m flag is present
if [ $build_modules == 'true' ]
then
   echo "Running build-images script for ryo-coturn module on "$hostname""
   echo ""
   "$SCRIPT_DIR"/../ryo-coturn/build-images.sh -n "$hostname" -v "$version"
else
   echo "Skipping image build for modules"
   echo ""
fi

# Build ryo-wellknown module images if -m flag is present
if [ $build_modules == 'true' ]
then
   echo "Running build-images script for ryo-wellknown module on "$hostname""
   echo ""
   "$SCRIPT_DIR"/../ryo-wellknown/build-images.sh -n "$hostname" -v "$version"
else
   echo "Skipping image build for modules"
   echo ""
fi


# Build project images
echo "Building element-web image on "$hostname""
echo "Executing command: packer build -var \"host_id="$hostname"\" -var \"element_version=$element_version\" -var \"version=$version\" "$SCRIPT_DIR"/image-build/element.pkr.hcl"
echo ""
packer build -var "host_id="$hostname"" -var "element_version=$element_version" -var "version=$version" "$SCRIPT_DIR"/image-build/element.pkr.hcl

echo "Building matrix-synapse image on "$hostname""
echo "Executing command: packer build -var \"host_id="$hostname"\" -var \"version=$version\" -var \"synapse_version=$synapse_version\" "$SCRIPT_DIR"/image-build/synapse.pkr.hcl"
echo ""
packer build -var "host_id="$hostname"" -var "version=$version" -var "synapse_version=$synapse_version" "$SCRIPT_DIR"/image-build/synapse.pkr.hcl

###
### !!! TODO: Add synapse-admin
###

echo "Completed"
