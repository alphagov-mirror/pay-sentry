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

read -p "SMTP host [sentry-smtp.apps.internal]: " SMTP_HOST
SMTP_HOST=${SMTP_HOST:-sentry-smtp.apps.internal}

SMTP_PORT=25

echo "Pushing sentry-smtp"
cf push -f sentry_smtp_manifest.yml --var smtp_user_and_password=$SMTP_USER:$SMTP_PASSWORD --var docker-username=$DOCKER_USERNAME --var route=$SMTP_HOST

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

echo "Provisioning smtp environment variables to sentry"
cf se $SENTRY_APP SENTRY_SERVER_EMAIL sentry-alert@noreply
cf se $SENTRY_APP SENTRY_EMAIL_HOST $SMTP_HOST
cf se $SENTRY_APP SENTRY_EMAIL_PORT $SMTP_PORT
cf se $SENTRY_APP SENTRY_EMAIL_USER $SMTP_USER
cf se $SENTRY_APP SENTRY_EMAIL_PASSWORD $SMTP_PASSWORD
cf se $SENTRY_APP SENTRY_EMAIL_USER_TLS 'false'

if [ $? -gt 0 ]
then
  echo "Failed to add smtp environment variables"
  exit 1
fi

echo "Restarting sentry"
cf restart $SENTRY_APP

if [ $? -eq 0 ]
then
  echo "Success"
else
  echo "Failed to restart sentry"
fi
