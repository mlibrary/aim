#!/bin/bash

#must be run from the project root directory
if [ -f ".env" ]; then
  echo "🌎 .env exists. Leaving alone"
else
  echo "🌎 .env does not exist. Copying .env-example to .env"
  cp env.example .env
fi

if [ -f ".git/hooks/pre-commit" ]; then
  echo "🪝 .git/hooks/pre-commit exists. Leaving alone"
else
  echo " 🪝 .git/hooks/pre-commit does not exist. Copying .github/pre-commit to .git/hooks/"
  cp .github/pre-commit .git/hooks/pre-commit
fi

echo "🔑 Set up ssh keys for mock sftp server"
./bin/set_up_development_ssh_keys.sh

echo "🛠️ Set up sftp/sms directory for sms scripts"
./bin/sms/setup.sh

echo "🚢 Build docker images"
docker-compose build

echo "📦 Installing Gems"
docker-compose run --rm app bundle
