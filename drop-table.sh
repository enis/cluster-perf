#!/bin/bash

if [ "$#" -eq "0" ] ; then
  echo "usage: $0 <table_name> "
  exit
fi

TABLE=$1
echo "disable '$TABLE'; drop '$TABLE'" | hbase shell
