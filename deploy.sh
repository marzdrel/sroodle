#!/usr/bin/env bash

# Builds and pushes the image, then deploys it with Helm.
#
# Reads .env: APP_NAME, APP_REGISTRY, APP_DOMAIN, and optionally APP_TAG
# (defaults to the current git SHA) and SMTP_PASSWORD.

set -euo pipefail

RAILS_ENV="production"
PLATFORM="linux/amd64"

set -a
source ./.env
set +a

APP_TAG="${APP_TAG:-$(git rev-parse --short HEAD)}"
RELEASE="${APP_NAME}-${RAILS_ENV}"
NAMESPACE="${RELEASE}"
IMAGE="${APP_REGISTRY}/${APP_NAME}"

set -x

docker build --platform "${PLATFORM}" -t "${APP_NAME}:${APP_TAG}" .
docker tag "${APP_NAME}:${APP_TAG}" "${IMAGE}:${APP_TAG}"
docker push "${IMAGE}:${APP_TAG}"

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

# The master key is read from the file and sent through stdin, so it never
# shows up in a command line or in the Helm release values.
set +x
SECRET_ARGS=(--from-file=rails-master-key=./config/master.key)
if [[ -n "${SMTP_PASSWORD:-}" ]]; then
  SECRET_ARGS+=(--from-literal=smtp-password="${SMTP_PASSWORD}")
fi
kubectl create secret generic "${RELEASE}-secrets" \
  --namespace "${NAMESPACE}" "${SECRET_ARGS[@]}" \
  --dry-run=client -o yaml | kubectl apply -f -
set -x

helm upgrade --install "${RELEASE}" ./charts \
  --namespace "${NAMESPACE}" \
  --values ./charts/values.yaml \
  --set image.repository="${IMAGE}" \
  --set image.tag="${APP_TAG}" \
  --set ingress.host="${APP_DOMAIN}" \
  --wait
