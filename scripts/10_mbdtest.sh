#!/bin/bash

input="./timeseries.txt"
#for (( i=0; i<10; i=i+1)); do
#	echo "add attribute" "time"$((i)) 
#done

add=0
delete=0

while IFS= read var
do
  t=`echo $var | awk '{print int($1)}'`
  n=`echo $var | awk '{print int($2)}'`
  echo -e "\nsleep $t s"
  sleep $t
  case $n in
  	0) 
  		echo "add attribute" "time"$((add+1)) 
  		node 06_addAttribute.js "time"$((add++)) 
  		;;
  	1) 
  		if test $delete -lt $add; then
  			echo "update attribute" "time"$((delete)) 
  			node 07_updateAttribute.js "time"$((delete))
  		else
  			echo "update error: Insufficient attributes"
  		fi
  		;;
  	2) 
  		if test $delete -lt $add; then
  			echo "delete attribute" "time"$((delete+1))
  			node 08_deleteAttribute.js "time"$((delete++))
  		else
  			echo "delete error: Insufficient attributes"
  		fi
  		;;
  	3) 
  		echo "access authorized" 
  		node 02_request_legal.js
  		;;
  	4) 
  		echo "policy check failed" 
  		node 03_request_illegal.js
  		;;
  	5) 
  		echo "too frequent access" 
  		node 02_request_legal.js
  		node 02_request_legal.js
  		node 02_request_legal.js
  		node 02_request_legal.js
  		node 02_request_legal.js
  		;;
  esac
done < "$input"
