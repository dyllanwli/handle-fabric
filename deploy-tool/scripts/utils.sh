#!/bin/bash

# function below is used to handel the api
USER=$(date '+T1%Y%m%d%H%M%S')

function enroll() {
	echo "POST request Enroll on Org1  ..."
	echo
	ORG1_TOKEN=$(curl -s -X POST \
		http://localhost:4000/users \
		-H "content-type: application/x-www-form-urlencoded" \
		-d "username=$USER&orgName=Org1")
	ORG1_TOKEN=$(echo $ORG1_TOKEN | jq ".token" | sed "s/\"//g")
	echo
	echo "ORG1 token is $ORG1_TOKEN"
	echo
	echo "POST request Enroll on Org2 ..."
	echo
	ORG2_TOKEN=$(curl -s -X POST \
		http://localhost:4000/users \
		-H "content-type: application/x-www-form-urlencoded" \
		-d "username=$USER&orgName=Org2")
	ORG2_TOKEN=$(echo $ORG2_TOKEN | jq ".token" | sed "s/\"//g")
	echo
	echo "ORG2 token is $ORG2_TOKEN"
	echo
}

function inits() {
	CNN=$1
	# channelname
	CNP=$2
	# channelpath
	echo
	echo "POST request Create channel  ..."
	echo
	curl -s -X POST \
		http://localhost:4000/channels \
		-H "authorization: Bearer $ORG1_TOKEN" \
		-H "content-type: application/json" \
		-d "{
    \"channelName\":\"$CNN\",
    \"channelConfigPath\":\"$CNP\"
  }"
	echo
	echo
	sleep 5
	echo "POST request Join channel on Org1"
	echo
	curl -s -X POST \
		http://localhost:4000/channels/$CNN/peers \
		-H "authorization: Bearer $ORG1_TOKEN" \
		-H "content-type: application/json" \
		-d '{
    "peers": ["peer0.org1.example.com","peer1.org1.example.com"]
  }'
	echo
	echo

	echo "POST request Join channel on Org2"
	echo
	curl -s -X POST \
		http://localhost:4000/channels/$CNN/peers \
		-H "authorization: Bearer $ORG2_TOKEN" \
		-H "content-type: application/json" \
		-d '{
    "peers": ["peer0.org2.example.com","peer1.org2.example.com"]
  }'
	echo
	echo
}

function installAndInstantiate() {
	CCP=$1
	# chaincodepath
	CCN=$2
	# chaincodename
	CCV=$3
	# chaincodeversion
	echo "Installing and instatiating chaincode; name: $CCN, path: $CCP"

	echo "POST Install chaincode on Org1"
	echo
	curl -s -X POST \
		http://localhost:4000/chaincodes \
		-H "authorization: Bearer $ORG1_TOKEN" \
		-H "content-type: application/json" \
		-d "{
        \"peers\": [\"peer0.org1.example.com\",\"peer1.org1.example.com\"],
        \"chaincodeName\":\"$CCN\",
        \"chaincodePath\":\"$CCP\",
        \"chaincodeType\": \"golang\",
        \"chaincodeVersion\":\"$CCV\"
    }"
	echo
	echo

	echo "POST Install chaincode on Org2"
	echo
	curl -s -X POST \
		http://localhost:4000/chaincodes \
		-H "authorization: Bearer $ORG2_TOKEN" \
		-H "content-type: application/json" \
		-d "{
        \"peers\": [\"peer0.org2.example.com\",\"peer1.org2.example.com\"],
        \"chaincodeName\":\"$CCN\",
        \"chaincodePath\":\"$CCP\",
        \"chaincodeType\": \"golang\",
        \"chaincodeVersion\":\"$CCV\"
    }"
	echo
	echo

	echo "POST instantiate chaincode on peer1 of Org1"
	echo
	curl -s -X POST \
		http://localhost:4000/channels/$CHANNEL/chaincodes \
		-H "authorization: Bearer $ORG1_TOKEN" \
		-H "content-type: application/json" \
		-d "{
        \"chaincodeName\":\"$CCN\",
        \"chaincodeVersion\":\"$CCV\",
        \"chaincodeType\": \"golang\",
        \"args\":[]
    }"
	echo
	echo
}

function queryBlock(){
	NUM=$1
	TARGETPEER=$2
	echo "GET query Block by blockNumber"
	echo
	curl -s -X GET \
	"http://localhost:4000/channels/$CHANNEL/blocks/$NUM?peer=$TARGETPEER" \
	-H "authorization: Bearer $ORG1_TOKEN" \
	-H "content-type: application/json"
	echo
	echo
}

function query() {
	QUERYTXID=$1
	TARGETPEER=$2
	echo "GET query Transaction by TransactionID"
	echo
	curl -s -X GET http://localhost:4000/channels/$CHANNEL/transactions/$QUERYTXID?peer=$TARGETPEER \
		-H "authorization: Bearer $ORG1_TOKEN" \
		-H "content-type: application/json"
	echo
	echo
}

function invoke() {
	CCN=$1
	FCN=$2
	ARG=$3
	echo "POST invoke chaincode on peers of Org1"
	echo "$ARG"
	TRX_ID=$(curl -s -X POST \
		http://localhost:4000/channels/$CHANNEL/chaincodes/$CCN \
		-H "authorization: Bearer $ORG1_TOKEN" \
		-H "content-type: application/json" \
		-d "{
		\"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
		\"fcn\": \"$FCN\",
		\"args\":[\"$ARG\"]
	}")
	echo "Transacton ID is $TRX_ID"
	echo
	# query $TRX_ID peer0.org1.example.com
}

# for CHAINCODE in repay receivable; do

#       echo
# done
