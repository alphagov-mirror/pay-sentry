#!/usr/bin/env bash

set -e

SERVICE=${SERVICE:-"web"}

sentry run $SERVICE
