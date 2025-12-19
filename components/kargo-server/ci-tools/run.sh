#!/usr/bin/env bash
set -euo pipefail

command -v kargo >/dev/null 2>&1 || {
  echo "Error: kargo CLI is required but not found in PATH" >&2
  exit 1
}

KARGO_PROJECT=${KARGO_PROJECT:-kargo-default-project}
APP=${APP:?"APP must be set"}
TAG=${TAG:?"TAG must be set"}
STAGE=${STAGE:?"STAGE must be set"}
REPO="docker.io/admarketplace/${APP}"

KARGO_SERVER_URL=${KARGO_SERVER_URL:?"KARGO_SERVER_URL must be set"}
KARGO_PW=${KARGO_PW:?"KARGO_PW must be set"}

echo "[INFO] Logging in to Kargo server ${KARGO_SERVER_URL}"
kargo login "$KARGO_SERVER_URL" --admin --password "$KARGO_PW"

echo "[INFO] Refreshing warehouse ${APP}-warehouse in project ${KARGO_PROJECT}"
kargo refresh warehouse docker-warehouse --project "$KARGO_PROJECT" --wait

TEMPLATE='{{range .items}}{{ $alias := .alias }}{{range .images}}{{if and (eq .repoURL "'"$REPO"'") (eq .tag "'"$TAG"'")}}{{ $alias }}{{"\n"}}{{end}}{{end}}{{end}}'
ALIAS="$(kargo get freight --project "$KARGO_PROJECT" -o go-template="$TEMPLATE" | head -n1)"

if [[ -z "${ALIAS}" ]]; then
  echo "Error: No freight found for repo $REPO with tag $TAG" >&2
  exit 1
fi

echo "[INFO] Promoting freight alias $ALIAS to stage $STAGE"
kargo promote --project "$KARGO_PROJECT" --stage="$STAGE" --freight-alias="$ALIAS" --wait
echo "[INFO] Promotion completed"
