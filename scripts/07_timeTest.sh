#!/bin/bash
echo "Time test"

for ((i=1;i<=100;i++));  do   
  /usr/bin/time -ao accessTime.txt -f '%S' node 02_request_legal.js
  sleep 5
  /usr/bin/time -ao accessTime.txt -f '%S' node 03_request_illegal3.js
  echo "the $i test"
  sleep 5
done 

echo "Test done"
