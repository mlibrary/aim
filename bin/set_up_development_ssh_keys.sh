#!/bin/bash

echo "📋 Check for dependencies"
if ! command -v ssh-keygen &> /dev/null
then
    echo "❌ ssh-keygen could not be found"
    exit
fi
echo "✅ ssh-keygen found"


echo "🧹 clear out any existing ssh keys"
rm -f .ssh/* 
rm -f sftp/ssh/ssh_host*
rm -f ssh_host*


echo "🔑 generate the host ssh keys for the sftp service"
ssh-keygen -t ed25519 -f ssh_host_ed25519_key < /dev/null
ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key < /dev/null


echo "🛻 move the keys into the sftp/ssh directory so they can be picked up"
echo "by docker-compose bind mounts for the sftp service"
mv ssh_host_ed25519_key sftp/ssh/
mv ssh_host_rsa_key sftp/ssh/
#this seems to be necessary
mv ssh_host_rsa_key.pub .ssh/known_hosts

echo "🧹 remove the unnecessary files"
rm ssh_host*

echo "🔑 generate actual host login keys"
ssh-keygen -t rsa -b 4096 -f ssh_client_rsa_key < /dev/null

echo "🛻 move the keys into the sftp/ssh directory"
mv ssh_client_rsa_key.pub sftp/ssh/
mv ssh_client_rsa_key sftp/ssh/
