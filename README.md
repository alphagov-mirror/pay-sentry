# Sentry

[Sentry](https://www.sentry.io) is an open-source error tracking tool. Some Sentry
files have been copied from [paas-incubator/sentry](https://github.com/alphagov/paas-incubator/tree/master/sentry)
. Since we have an additional requirement to send email notifications the manifest
and sentry.conf.py have been amended.

## Requirements

- A Postgres instance
- A Redis instance

## Setup

The plans chosen here are to minimise costs, rather than provide a highly
available setup.


Create Postgres instance

```
$ cf create-service postgres tiny-unencrypted-10 sentry-postgres
```

Create Redis instance

```
$ cf create-service redis tiny-3.2 sentry-redis`
```

Wait for services to provision before continuing. The status of the provisioning can be checked with.
```
$ cf services
```

## Push the app
The following script will ask for settings and push the sentry app and a simple
smtp server to allow it to send email alerts.
```
./cli/deploy_sentry.sh
```

## Configure Sentry

```
export deployment='my-deployment-name'

$ cf v3-ssh ${deployment}-sentry -t -c "/tmp/lifecycle/shell"

# Ensure Sentry has run all migrations
vcap@... $ sentry upgrade

...

# We need to create the internal Sentry project
vcap@... $ sentry shell
python> from sentry.models import Project
...
python> from sentry.receivers.core import create_default_projects
...
python> create_default_projects([Project])
...
python> exit()

vcap@... $ exit

# Log in to Sentry
$ open "https://${deployment}-sentry.london.cloudapps.digital"
```

## Configure Sentry via the Web UI

After you've created the initial project, you need to set up an administrative
user, then configure GitHub OAuth (both via the Web UI).
