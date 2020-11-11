#!/bin/bash
NUMBER_OF_NODES=4
case "$1" in ("" | *[!0-9]*)
  echo 'Please provide the number of the node to attach to (i.e. ./attach.sh 2)' >&2
  exit 1
esac

if [ "$1" -lt 1 ] || [ "$1" -gt $NUMBER_OF_NODES ]; then
  echo "$1 is not a valid node number. Must be between 1 and $NUMBER_OF_NODES." >&2
  exit 1
fi

BIN_GETH=/home/shuzang/.quorum-wizard/bin/quorum/2.6.0/geth
BIN_CAKESHOP=/home/shuzang/.quorum-wizard/bin/cakeshop/0.11.0/cakeshop.war

$BIN_GETH attach qdata/dd$1/geth.ipc