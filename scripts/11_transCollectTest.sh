#!/bin/bash

echo "Test begin"

for ((i=1;i<=500;i++));  do   
  printf "%s\r" $i
  if [[ (( $i -gt 1 && $i -lt 50 )) || (( $i -gt 150 && $i -lt 170 )) ]];then
  	node 03_request_illegal1.js
  else
  	node 02_request_legal2.js
  fi
  sleep 10
  echo -en "Block number: "
  node 10_getBlocknumber.js
done 

echo "Test done"
