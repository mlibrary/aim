#!/bin/bash

#must be run from the project root directory
if [ -f ".env" ]; then
  echo "🌎 .env exists. Leaving alone"
else
  echo "🌎 .env does not exist. Copying .env-example to .env"
  cp env.example .env
fi

ssh_key_count=`find ./sftp/ssh -type f  -name ssh_client_rsa_key | wc -l`
if [ $ssh_key_count == 1 ]; then
  echo "🔑 development ssh keys exist. Not re-running"
else
  echo "🔑 setting up development ssh keys"
  ./set_up_development_ssh_keys.sh
fi

echo "🛠️ Set up sftp/sms directory for sms scripts"
./bin/sms/setup.sh

echo "🚢 Build docker images"
docker compose build

echo "📦 Installing Gems"
docker compose run --rm app bundle
