#!/bin/bash

for ((i=1;i<=500;i++));  do   
  ./xtime node request.js
  sleep 5
done 
