#!/bin/bash -e

echo "Running build script"
sudo chown bldmgr:users ~/.npmrc
sudo chmod 777 ~/.npmrc
node_version=$(grep "FROM node" app/Dockerfile | sed "s/.*node://g")
re='^[0-9]+'
if ! [[ $node_version =~ $re ]]; then
	 # Node version is not a number - default to stable
	 echo "Cannot determine node version from Docker file - defaulting to stable"
	 node_version="stable"
fi
sudo n $node_version
mkdir /app
cp -R /app_files/* /app/
cd /app
#npm install --production
#WHITESOURCE PLACEHOLDER
echo "Installing all npm packages and running grunt tasks"
npm config set unsafe-perm true
npm install
grunt
cp -rf /app/* /app_files/
