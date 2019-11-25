#!/bin/bash

read -p "Sentry app name [sentry]: " SENTRY_APP
SENTRY_APP=${SENTRY_APP:-sentry}

read -p "SMTP user name [sentry]: " SMTP_USER
SMTP_USER=${SMTP_USER:-sentry}

read -p "SMTP password: " SMTP_PASSWORD
if [ ${#SMTP_PASSWORD} -le 5 ]
then
  echo "Please enter a password at least 5 characters long"
  exit 1
fi

read -p "SMTP host [$(echo $SENTRY_APP).apps.internal]: " SMTP_HOST
SMTP_HOST=${SMTP_HOST:-$(echo $SENTRY_APP).apps.internal}

read -p "Sentry secret: " SENTRY_SECRET
if [ ${#SENTRY_SECRET} -le 5 ]
then
  echo "Please enter a secret at least 5 characters long"
  exit 1
fi

read -p "Github API secret: " GITHUB_API_SECRET
read -p "Github app id: " GITHUB_APP_ID

SENTRY_SERVER_EMAIL="sentry-alert@noreplay"
SMTP_PORT=25
echo "Applying sentry manifest"
cf7 push -f manifest.yml \
  --var sentry-name=$SENTRY_APP \
  --var sentry-secret-key=$SENTRY_SECRET \
  --var sentry-secret_key=$SENTRY_SECRET \
  --var github-app-id=$GITHUB_APP_ID \
  --var github-api-secret=$GITHUB_API_SECRET \
  --var sentry-server-email=$SENTRY_SERVER_EMAIL \
  --var smtp-host=$SMTP_HOST \
  --var smtp-port=$SMTP_PORT \
  --var smtp-user=$SMTP_USER \
  --var smtp-password=$SMTP_PASSWORD

if [ $? -gt 0 ]
then
  echo "Failed to push sentry"
  exit 1
fi

echo "Pushing sentry-smtp"
cf push -f smtp/sentry_smtp_manifest.yml \
  --var smtp_user_and_password=$SMTP_USER:$SMTP_PASSWORD \
  --var docker-username=$DOCKER_USERNAME \
  --var route=$SMTP_HOST

if [ $? -gt 0 ]
then
  echo "failed to create smtp server"
  exit 1
fi

echo "Adding network policy for sentry to smtp server"
cf add-network-policy $SENTRY_APP --destination-app sentry-smtp --protocol tcp --port 25

if [ $? -gt 0 ]
then
  echo "Failed to add network policies"
  exit 1
fi

if [ $? -eq 0 ]
then
  echo "Success"
else
  echo "Failed to restart sentry"
fi
