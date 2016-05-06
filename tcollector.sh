#!/bin/bash

source ./env.sh
source ./service.sh

echo "****************************"
echo "$cmd tcollector";
echo "****************************"

pdsh -R exec -w ^$ALL_NODES_PATH ssh $SSH_ARGS -l %u %h " $TCOLLECTOR_PATH/startstop $cmd -p 9999 ";
