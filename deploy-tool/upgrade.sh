#!/bin/bash

cd tool
trash fabric*
CHANNEL=mychannel
CHAINCODEPATH=$1
CHAINCODENAME=$2
CHAINCODEVERSION=$3

# import utils
. ../scripts/utils.sh
# copy chaincode
trash ./artifacts/src/*
cp -r ../chaincodes/* ./artifacts/src

enroll 
#enroll user by time
installAndInstantiate $CHAINCODEPATH $CHAINCODENAME $CHAINCODEVERSION
# upgrade sample
# installAndInstantiate repay scf-repay v1