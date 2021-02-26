#!/bin/bash

echo "Test begin"

for ((i=1;i<=100;i++));  do   
  echo "the $i test"
  /usr/bin/time -ao timeTestResult.txt -f '%S' node 05_deleteAttribute.js
  sleep 1
  /usr/bin/time -ao timeTestResult.txt -f '%S' node 03_addAttribute.js
  sleep 1
  /usr/bin/time -ao timeTestResult.txt -f '%S' node 04_getAttribute.js
  sleep 5
done 

echo "Test done"