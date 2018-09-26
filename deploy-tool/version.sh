#!/bin/bash

# This scripts is used to change the version of the channel artifacts and cofnig file.
CUR_DIR=${PWD}
VER_DIR=$CUR_DIR/artifacts-restore
CON_DIR=$CUR_DIR/config

function down() {
	echo "down network and clean the tmp"
	cd $CUR_DIR/artifacts
	docker-compose down
	yes | docker network prune
	trash /tmp/*, trash ~/.hfc-key-store
	docker rm -f $(docker ps -a | grep dev | awk '{print $1}')
	# delete docker chaincode container
	docker rmi -f $(docker images | grep dev | awk '{print $3}')
	# delete chaincode images
	
	trash /data/ordererdata/*/*
	trash /data/peerdata/*/*/*/*
}

function up(){
	echo "start up the network"
    cd $CUR_DIR/artifacts
    trash /tmp/hfc-*; trash ~/.hfc-key-store
    docker-compose up -d
}

function restart(){
	echo "restart the network"
    down
    up
}

function version(){
    ver=$1
	art=$2
	echo "switching the artifacts to the $ver"
	cd $CON_DIR
	trash ./network-config.json
	cd $CUR_DIR/artifacts
	trash ./*

	set -x
	cp -rf $CUR_DIR/artifacts-restore/artifacts-$art/* ./
	cp -rf ./network-config.json $CON_DIR/network-config.json
	set +x

	cd $CUR_DIR/tool
	trash ./*
	echo "Switching tool and artifacts"
	set -x
	cp -rf $CUR_DIR/tools-restore/tool-$ver/* ./
	cp -rf $CUR_DIR/artifacts ./
	set +x
	if [ ! -e "$CUR_DIR/node_modules" ]; then
		echo "npm install this project first"
		exit 1
	else
		cd $CUR_DIR/node_modules
		trash fabric-ca-client fabric-client
		cd $CUR_DIR
		npm install fabric-ca-client@$ver
		npm install fabric-client@$ver
	fi
	
	echo "Switching binaries files"
	cd $CUR_DIR/binaries-restore/bin-$ver
	trash $CUR_DIR/networklauncher/fabric/build/bin/*
	cp -rf ./bin-$ver.zip $CUR_DIR/networklauncher/fabric/build/bin/
	cd $CUR_DIR/networklauncher/fabric/build/bin
	unzip -o bin-$ver.zip
	chmod +x ./*
	ls
}

function check(){
	echo "checking fabric version..."
	npm list | grep fabric
}

# clear temp lock file
trash package-lock.json
trash /tmp/*
chmod +x *.sh
chmod +x ./*/*.sh
MODE=$1
shift
if [ "$MODE" == "up" ]; then
	up
elif [ "$MODE" == "down" ]; then
	down
elif [ "$MODE" == "restart" ]; then
    restart
elif [ "$MODE" == "check" ]; then
    check
elif [ "$MODE" == "1.0.6" ]; then
    version 1.0.6 1.0.6
elif [ "$MODE" == "1.1.0" ]; then
    version 1.1.0 1.1.0
elif [ "$MODE" == "1.2.0" ]; then
    version 1.2.0 1.2.0
else
	echo "Not matching any parameters"
	exit 1
fi
