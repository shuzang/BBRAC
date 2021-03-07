#!/bin/bash
echo "--------------------Test begin---------------------------"
echo -en "blockchain size: "
du -sk ~/network/4-nodes-istanbul-bash/qdata/dd1/geth/chaindata

echo -e "\n---------------------------------------------------------"

for ((n=1;n<=10;n++)); do

	for ((i=1;i<=10;i++));  do   
	  node 08_deploy.js
	  let t=$i*10
	  printf "%s%%\r" $t
	  sleep 1
	done 
	echo -en "blockchain size: "
	du -sk ~/network/4-nodes-istanbul-bash/qdata/dd1/geth/chaindata
done

echo "------------------------Test done-----------------------------"

