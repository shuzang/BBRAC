#!/bin/bash
 
echo "Note: Every 1 minutes, send an access request"

for((i=1;i<=30;i++));  do   
  echo -e "\nThe $i-th request" 
  node requester_legal.js
  sleep 120
done  
