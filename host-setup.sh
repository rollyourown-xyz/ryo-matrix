#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
   echo "host-setup.sh: Use ansible to configure a remote host for project deployment"
   echo ""
   echo "Help: host-setup.sh"
   echo "Usage: ./host-setup.sh -n hostname"
   echo "Flags:"
   echo -e "-n hostname \t\t(Mandatory) Name of the host to be configured"
   echo -e "-h \t\t\tPrint this help message"
   echo ""
   exit 1
}

errorMessage()
{
   echo "Invalid option or mandatory input variable is missing"
   echo "Use \"./host-setup.sh -h\" for help"
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

# Module-specific host setup
echo "Running module-specific host setup playbooks"
echo ""

## Module-specific host setup for ryo-service-proxy
if [ -f ""$SCRIPT_DIR"/../ryo-service-proxy/configuration/"$hostname"_playbooks_executed" ]
then
   echo "Host setup for ryo-service-proxy module has already been done on "$hostname""
   echo ""
else
   echo "Running module-specific host setup script for ryo-service-proxy on "$hostname""
   echo ""
   "$SCRIPT_DIR"/../ryo-service-proxy/host-setup.sh -n "$hostname"
fi

# Module-specific host setup for ryo-postgres
if [ -f ""$SCRIPT_DIR"/../ryo-postgres/configuration/"$hostname"_playbooks_executed" ]
then
   echo "Host setup for ryo-postgres module has already been done on "$hostname""
   echo ""
else
   echo "Running module-specific host setup script for ryo-postgres on "$hostname""
   echo ""
   "$SCRIPT_DIR"/../ryo-postgres/host-setup.sh -n "$hostname"
fi

## Module-specific host setup for ryo-wellknown
if [ -f ""$SCRIPT_DIR"/../ryo-wellknown/configuration/"$hostname"_playbooks_executed" ]
then
   echo "Host setup for ryo-wellknown module has already been done on "$hostname""
   echo ""
else
   echo "Running module-specific host setup script for ryo-wellknown on "$hostname""
   echo ""
   "$SCRIPT_DIR"/../ryo-wellknown/host-setup.sh -n "$hostname"
fi

# Module-specific host setup for ryo-coturn
if [ -f ""$SCRIPT_DIR"/../ryo-coturn/configuration/"$hostname"_playbooks_executed" ]
then
   echo "Host setup for ryo-coturn module has already been done on "$hostname""
   echo ""
else
   echo "Running module-specific host setup script for ryo-coturn on "$hostname""
   echo ""
   "$SCRIPT_DIR"/../ryo-coturn/host-setup.sh -n "$hostname"
fi

## Project-specific host setup
if [ -f ""$SCRIPT_DIR"/configuration/"$hostname"_playbooks_executed" ]
then
   echo "Host setup for ryo-matrix-standalone project has already been done on "$hostname""
   echo ""
else
   echo "Executing project-specific host setup playbooks on "$hostname""
   echo ""
   echo "DEBUG: "
   ansible-playbook -i "$SCRIPT_DIR"/../ryo-host/configuration/inventory_"$hostname" "$SCRIPT_DIR"/host-setup/main.yml --extra-vars "host_id="$hostname""
   touch "$SCRIPT_DIR"/configuration/"$hostname"_playbooks_executed
fi
