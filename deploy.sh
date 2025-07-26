#!/usr/bin/env bash

set -exuo pipefail

# FIXME: 2025-07-26 - Use proper way for tramsitting the secrets.

RAILS_MASTER_KEY=$(cat ./config/master.key)
RAILS_ENV="production"

set -a
source ./.env
set +a

helm upgrade --install "${APP_NAME}-${RAILS_ENV}" ./charts \
  --namespace "${APP_NAME}-${RAILS_ENV}" \
  --create-namespace \
  --values ./charts/values.yaml \
  --set image.repository="${APP_REGISTRY}/${APP_NAME}" \
  --set secrets.railsMasterKey=${RAILS_MASTER_KEY}
