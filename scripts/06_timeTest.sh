#!/bin/bash

for ((i=1;i<=100;i++));  do   
  /usr/bin/time -ao accessTime.txt -f '%S' node 02_request_legal.js
  echo "the $i test"
  sleep 5
done 

echo "Test done"
