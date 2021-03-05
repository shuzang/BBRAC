#!/bin/bash

echo "Test begin"

for ((i=1;i<=500;i++));  do   
  printf "%s\r" $i
  if [[ $i -eq 20 || $i -eq 90 ]];then
  	node 10_transCollect_illegal.js
  else
  	node 09_transCollect_legal.js
  fi
  sleep 10
  echo -en "Block number: "
  node 11_getBlocknumber.js
done 

echo "Test done"
