#!/bin/bash

source ./env.sh

if [ "$#" -eq "0" ] ; then
  echo "usage: $0 <tarball_path> "
  exit
fi

TARBALL=$1

echo "***********************************"
echo "deploy tcollector from tarball $TARBALL";
echo "***********************************"

deploy() {
  local HOSTS_FILE=$1
  local TARGET_DIR=$2
  pdsh -R exec -w ^$HOSTS_FILE ssh $SSH_ARGS -l %u %h "mkdir -p $TARGET_DIR"
  pdsh -R exec -w ^$HOSTS_FILE scp $SSH_ARGS -r $TARBALL/* %h:$TARGET_DIR/
}

deploy $ALL_NODES_PATH /home/enis/tcollector
