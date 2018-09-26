#!/bin/bash

cd tool
trash fabric*
INIT=$1
CHANNEL=mychannel

# import utils
. ../scripts/utils.sh
# copy chaincode
trash ./artifacts/src/*
cp -r ../chaincodes/* ./artifacts/src

enroll
#enroll user by time
if [ "$INIT" == "init" ]; then
	inits $CHANNEL ../artifacts/channel/mychannel.tx
	# default to join two peer
fi

# main function
# installAndInstantiate chaincodePath chaincodeName version

# upgrade sample
# installAndInstantiate repay scf-repay v1
