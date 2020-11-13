#!/bin/bash

for ((i=1;i<=500;i++));  do   
  /usr/bin/time -ao accessTime.txt -f '%U %S %e %P' node 02_request.js
  echo "the $i test"
  sleep 20
done 

echo "Test done"
