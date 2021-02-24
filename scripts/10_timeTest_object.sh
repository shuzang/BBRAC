#!/bin/bash

echo "Test begin"

for ((i=1;i<=100;i++));  do   
  echo "the $i test"
  /usr/bin/time -ao timeTestResult.txt -f '%S' node 11_addResourceAttr.js
  sleep 1
  /usr/bin/time -ao timeTestResult.txt -f '%S' node 12_getResourceAttr.js
  sleep 1
  /usr/bin/time -ao timeTestResult.txt -f '%S' node 13_updateResourceAttr.js
  sleep 1
  /usr/bin/time -ao timeTestResult.txt -f '%S' node 14_deleteResourceAttr.js
  sleep 5
done 

echo "Test done"
