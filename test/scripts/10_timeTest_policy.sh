#!/bin/bash

echo "Test begin"

for ((i=1;i<=100;i++));  do   
  echo "the $i test"
  /usr/bin/time -ao timeTestResult.txt -f '%S' node 13_deletePolicy.js
  sleep 1
  /usr/bin/time -ao timeTestResult.txt -f '%S' node 11_addPolicy.js
  sleep 1
  /usr/bin/time -ao timeTestResult.txt -f '%S' node 12_getPolicy.js
  sleep 5
done 

echo "Test done"
