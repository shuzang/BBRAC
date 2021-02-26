#!/bin/bash
echo "--------------------Test begin---------------------------"
echo -en "block number:" 
node 19_getBlocknumber.js
echo -en "blockchain size: "
du -sk ~/network/4-nodes-istanbul-bash/qdata/dd1/geth/chaindata

echo -e "\n---------------------------------------------------------"
echo "Deploy 0-50 contract"

for ((i=1;i<=50;i++));  do   
  node 20_deploy.js
  let t=$i*2
  printf "%s%%\r" $t
  sleep 1
done 

echo -en "\nAfter deploying 50 contracts"
echo -en "\nblock number:" 
node 19_getBlocknumber.js
echo -en "blockchain size: "
du -sk ~/network/4-nodes-istanbul-bash/qdata/dd1/geth/chaindata

echo -e "\n---------------------------------------------------------"
echo "Deploy 50-100 contracts"

for ((i=1;i<=50;i++));  do   
  node 20_deploy.js
  let t=$i*2
  printf "%s%%\r" $t
  sleep 1
done 

echo -en "\nAfter deploying 100 contracts"
echo -en "\nblock number:" 
node 19_getBlocknumber.js
echo -en "blockchain size: "
du -sk ~/network/4-nodes-istanbul-bash/qdata/dd1/geth/chaindata

echo -e "\n---------------------------------------------------------"
echo "Deploy 100-200 contracts"

for ((i=1;i<=100;i++));  do   
  node 20_deploy.js
  let t=$i
  printf "%s%%\r" $t
  sleep 1
done 

echo -en "\nAfter deploying 200 contracts"
echo -en "\nblock number:" 
node 19_getBlocknumber.js
echo -en "blockchain size: "
du -sk ~/network/4-nodes-istanbul-bash/qdata/dd1/geth/chaindata

echo -e "\n---------------------------------------------------------"
echo "Deploy 200-500 contracts"

for ((i=1;i<=300;i++));  do   
  node 20_deploy.js
  let t=$i/3
  printf "%s%%\r" $t
  sleep 1
done 

echo -en "\nAfter deploying 500 contracts"
echo -en "\nblock number:" 
node 19_getBlocknumber.js
echo -en "blockchain size: "
du -sk ~/network/4-nodes-istanbul-bash/qdata/dd1/geth/chaindata

echo -e "\n---------------------------------------------------------"
echo "Deploy 500-1000 contracts"

for ((i=1;i<=500;i++));  do   
  node 20_deploy.js
  let t=$i/5
  printf "%s%%\r" $t
  sleep 1
done 

echo -en "\nAfter deploying 1000 contracts"
echo -en "\nblock number:" 
node 19_getBlocknumber.js
echo -en "blockchain size: "
du -sk ~/network/4-nodes-istanbul-bash/qdata/dd1/geth/chaindata
echo "------------------------Test done-----------------------------"

