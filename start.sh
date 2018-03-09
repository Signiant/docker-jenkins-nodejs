#!/bin/bash -e

echo "Running build script"
su - bldmgr
whoami
node_version=$(grep "FROM node" app/Dockerfile | sed "s/.*node://g")
re='^[0-9]+'
if ! [[ $node_version =~ $re ]]; then
	 # Node version is not a number - default to stable
	 echo "Cannot determine node version from Docker file - defaulting to stable"
	 node_version="stable"
fi
sudo n $node_version

cd ./app
#npm install --production
#WHITESOURCE PLACEHOLDER
echo "Installing all npm packages and running grunt tasks"
npm install
grunt
exit -1
