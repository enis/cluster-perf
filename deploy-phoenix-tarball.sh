#!/bin/bash

source ./env.sh

if [ "$#" -eq "0" ] ; then
  echo "usage: $0 <tarball> "
  exit
fi

TARBALL=$1
SERVER_JAR=$2

echo "***********************************"
echo "deploy phoenix from tarball $TARBALL";
echo "***********************************"

extractTarball() {
  echo "Extracting tarball $TARBALL"
  tar zxf $TARBALL
  TARBALL=`tar tvf $TARBALL | head -n 1  | cut -d ":" -f 2 | cut -d " " -f 2  | cut -d "/" -f 1`
}

deploy() {
  echo "deploying $TARBALL"
  local HOSTS_FILE=$1
  local TARGET_DIR=$2
  local TARBALL=$3
  pdsh -R exec -w ^$HOSTS_FILE ssh $SSH_ARGS -l %u %h "rm -rf $TARGET_DIR/*";
  pdsh -R exec -w ^$HOSTS_FILE scp $SSH_ARGS -r $TARBALL/* %h:$TARGET_DIR/
  server_jar=`ls $TARBALL | grep "server.jar"`
  client_jar=`ls $TARBALL | grep "client.jar" | grep -v "thin"`
  thin_client_jar=`ls $TARBALL | grep "thin-client.jar"`

  # link Phoenix 
  pdsh -R exec -w ^$HOSTS_FILE ssh $SSH_ARGS -l %u %h "cd $TARGET_DIR && ln -s $server_jar phoenix-server.jar"
  pdsh -R exec -w ^$HOSTS_FILE ssh $SSH_ARGS -l %u %h "cd $TARGET_DIR && ln -s $client_jar phoenix-client.jar"
  pdsh -R exec -w ^$HOSTS_FILE ssh $SSH_ARGS -l %u %h "cd $TARGET_DIR && ln -s $thin_client_jar phoenix-thin-client.jar"
  pdsh -R exec -w ^$HOSTS_FILE ssh $SSH_ARGS -l %u %h "cd /usr/hdp/current/hbase-regionserver/lib/ && ln -s /usr/hdp/current/phoenix-server/phoenix-server.jar phoenix-server.jar"
}

case $TARBALL in
  *.tar.gz) extractTarball;;
  *) ;;
esac

deploy $HBASE_CONF_DIR/masters $HDP/phoenix-server/ $TARBALL
deploy $HBASE_CONF_DIR/regionservers $HDP/phoenix-server/ $TARBALL
