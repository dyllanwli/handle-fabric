#!/bin/bash

# This scripts is used to post requests for invoke chaincode function
cd tool
trash fabric*
CHANNEL=mychannel
# import utils
. ../scripts/utils.sh
enroll

# sample invoke 
# invoke chaincodeName functionName arg

# sample query
# query <Transacton ID> peer0.org1.example.com
queryBlock 1 peer0.org1.example.com