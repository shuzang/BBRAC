#!/bin/bash
if [ -z $1 ] || [ ! -f $1 ]; then
  echo "Please provide a valid script file to execute (i.e. ./runscript.sh private_contract.js)" >&2
  exit 1
fi

BIN_GETH=/home/shuzang/.quorum-wizard/bin/quorum/2.6.0/geth
BIN_CAKESHOP=/home/shuzang/.quorum-wizard/bin/cakeshop/0.11.0/cakeshop.war

$BIN_GETH --exec "loadScript(\"$1\")" attach qdata/dd1/geth.ipc
