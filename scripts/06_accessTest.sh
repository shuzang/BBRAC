#!/bin/bash
echo "Test1: success" 
	node 02_request_legal1.js
	node 02_request_legal1.js
	node 02_request_legal1.js
echo "Test2: failed"
	node 02_request_legal1.js

sleep 20
echo "Test3: failed"
	node 03_request_illegal1.js
sleep 20
echo "Test4: failed"
	node 03_request_illegal2.js
	
echo "Test End"
