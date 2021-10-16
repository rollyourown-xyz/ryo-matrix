#!/bin/bash

echo "Getting project-specific modules from repositories..."
echo ""

## Service proxy module
if [ -d "../ryo-service-proxy" ]
then
   echo "Module ryo-service-proxy already cloned to this control node"
else
   echo "Cloning ryo-service-proxy repository. Executing 'git clone' for ryo-service-proxy repository"
   #git clone https://github.com/rollyourown-xyz/ryo-service-proxy ../ryo-service-proxy
   git clone https://git.rollyourown.xyz/ryo-projects/ryo-service-proxy ../ryo-service-proxy
fi

# PostgreSQL Database module
if [ -d "../ryo-postgres" ]
then
   echo "Module ryo-postgres already cloned to this control node"
else
   echo "Cloning ryo-postgres repository. Executing 'git clone' for ryo-postgres repository"
   #git clone https://github.com/rollyourown-xyz/ryo-postgres ../ryo-postgres 
   git clone https://git.rollyourown.xyz/ryo-projects/ryo-postgres ../ryo-postgres 
fi

## Wellknown Server module
if [ -d "../ryo-wellknown" ]
then
   echo "Module ryo-wellknown already cloned to this control node"
else
   echo "Cloning ryo-wellknown repository. Executing 'git clone' for ryo-wellknown repository"
   #git clone https://github.com/rollyourown-xyz/ryo-wellknown ../ryo-wellknown
   git clone https://git.rollyourown.xyz/ryo-projects/ryo-wellknown ../ryo-wellknown
fi

# STUN/TURN Server module
if [ -d "../ryo-coturn" ]
then
   echo "Module ryo-coturn already cloned to this control node"
else
   echo "Cloning ryo-coturn repository. Executing 'git clone' for ryo-coturn repository"
   #git clone https://github.com/rollyourown-xyz/ryo-coturn ../ryo-coturn
   git clone https://git.rollyourown.xyz/ryo-projects/ryo-coturn ../ryo-coturn
fi
