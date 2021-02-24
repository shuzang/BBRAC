#!/bin/bash

echo "Test begin"

for ((i=1;i<=100;i++));  do   
  echo "the $i test"
  /usr/bin/time -ao timeTestResult.txt -f '%S' node 16_addPolicy.js
  sleep 1
  /usr/bin/time -ao timeTestResult.txt -f '%S' node 17_getPolicy.js
  sleep 1
  /usr/bin/time -ao timeTestResult.txt -f '%S' node 18_deletePolicy.js
  sleep 5
done 

echo "Test done"
