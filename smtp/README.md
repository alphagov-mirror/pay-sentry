## Setting up SMTP for Sentry

Sentry needs access to an SMTP server to send email notificiations. To deploy a
simple SMTP server using postfix into the PaaS environment follow these instructions:

1. log into the correct org and space e.g. `cf target -s build`
2. Run `./add_sentry_smtp.sh` which will:
  - Prompt for various SMTP and PaaS application values
  - Push a simple smtp server app using the `sentry_smtp_manifest.yml` in this directory
  - Add a network policy to permit the sentry app to connect to the smtp server
  app.
  - Add the SMTP server settings to the sentry app
  - Restart the Sentry app so that changes take effect.
  - Setup can be tested visiting `/manage/status/mail/`
