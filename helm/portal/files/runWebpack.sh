#!/usr/bin/env bash
set -euo pipefail
export APP="${APP:-dev}"
export NODE_ENV="${NODE_ENV:-dev}"
export HOSTNAME="${HOSTNAME:-revproxy-service}"
export BASENAME="${BASENAME:-}"
export GEN3_BUNDLE="${GEN3_BUNDLE:-commons}"
export TIER_ACCESS_LEVEL="${TIER_ACCESS_LEVEL:-private}"
export TIER_ACCESS_LIMIT="${TIER_ACCESS_LIMIT:-1000}"
export USE_INDEXD_AUTHZ="${USE_INDEXD_AUTHZ:-false}"
export LOGOUT_INACTIVE_USERS="${LOGOUT_INACTIVE_USERS:-true}"
export WORKSPACE_TIMEOUT_IN_MINUTES="${WORKSPACE_TIMEOUT_IN_MINUTES:-480}"
export WEBPACK_OUTDIR="${WEBPACK_OUTDIR:-$(pwd)/dist}"
export WEBPACK_CACHE_DIR="${WEBPACK_CACHE_DIR:-${WEBPACK_OUTDIR}/.webpack-cache}"
mkdir -p "${WEBPACK_OUTDIR}" "${WEBPACK_CACHE_DIR}"
bash custom/customize.sh || true
if [[ "$GEN3_BUNDLE" != "workspace" ]]; then
    npm run schema
    npm run relay
fi
echo "INFO: Generating parameters.json"
npm run params || true
if [[ "$GEN3_BUNDLE" != "workspace" ]]; then
    npm run sanity-check || true
fi
echo "INFO: Building to ${WEBPACK_OUTDIR}"
export NODE_OPTIONS='--max-old-space-size=3584'
export NODE_ENV="production"
npx webpack build --mode production