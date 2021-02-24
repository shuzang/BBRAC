#!/bin/bash

echo "Test begin"

for ((i=1;i<=100;i++));  do   
  echo "the $i test"
  /usr/bin/time -ao timeTestResult.txt -f '%S' node 06_addAttribute.js
  sleep 1
  /usr/bin/time -ao timeTestResult.txt -f '%S' node 07_getAttribute.js
  sleep 1
  /usr/bin/time -ao timeTestResult.txt -f '%S' node 08_updateAttribute.js
  sleep 1
  /usr/bin/time -ao timeTestResult.txt -f '%S' node 09_deleteAttribute.js
  sleep 5
done 

echo "Test done"
