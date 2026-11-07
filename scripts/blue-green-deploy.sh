#!/usr/bin/env bash

set -Eeuo pipefail

NAMESPACE="employee-api"
SERVICE="employee-api-service"
CHART="helm/employee-api"

TARGET_COLOR="${1:?Usage: $0 <blue|green> <image-tag>}"
IMAGE_TAG="${2:?Usage: $0 <blue|green> <image-tag>}"

if [[ "$TARGET_COLOR" != "blue" && "$TARGET_COLOR" != "green" ]]; then
    echo "ERROR: Target color must be blue or green."
    exit 1
fi

if [[ "$TARGET_COLOR" == "blue" ]]; then
    PREVIOUS_COLOR="green"
else
    PREVIOUS_COLOR="blue"
fi

RELEASE="employee-${TARGET_COLOR}"
DEPLOYMENT="${RELEASE}-employee-api-${TARGET_COLOR}"

GREEN_TEST_PORT=18000
SERVICE_TEST_PORT=18001

PORT_FORWARD_PID=""

cleanup() {
    if [[ -n "$PORT_FORWARD_PID" ]]; then
        kill "$PORT_FORWARD_PID" 2>/dev/null || true
    fi
}

trap cleanup EXIT

echo "=================================="
echo "Starting Blue-Green Deployment"
echo "Target: $TARGET_COLOR"
echo "Image: $IMAGE_TAG"
echo "Previous: $PREVIOUS_COLOR"
echo "=================================="

# 1. Deploy the target version
echo "Deploying $TARGET_COLOR..."

helm upgrade --install "$RELEASE" "$CHART" \
    -f "$CHART/values-${TARGET_COLOR}.yaml" \
    --set image.tag="$IMAGE_TAG" \
    --namespace "$NAMESPACE" \
    --create-namespace \
    --wait \
    --timeout 5m

# 2. Wait for deployment readiness
echo "Waiting for deployment readiness..."

kubectl rollout status deployment/"$DEPLOYMENT" \
    -n "$NAMESPACE" \
    --timeout=300s

# 3. Test target version before switching traffic
echo "Starting port-forward for target deployment..."

kubectl port-forward \
    -n "$NAMESPACE" \
    deployment/"$DEPLOYMENT" \
    "${GREEN_TEST_PORT}:8000" \
    >/tmp/employee-api-target-port-forward.log 2>&1 &

PORT_FORWARD_PID=$!

for i in {1..30}; do
    if curl -fsS "http://127.0.0.1:${GREEN_TEST_PORT}/health" >/dev/null; then
        echo "Target health check passed."
        break
    fi

    if [[ "$i" -eq 30 ]]; then
        echo "ERROR: Target health check failed."
        cat /tmp/employee-api-target-port-forward.log
        exit 1
    fi

    sleep 2
done

# Stop target port-forward
kill "$PORT_FORWARD_PID" 2>/dev/null || true
wait "$PORT_FORWARD_PID" 2>/dev/null || true
PORT_FORWARD_PID=""

# 4. Switch traffic to target version
echo "Switching traffic to $TARGET_COLOR..."

kubectl patch service "$SERVICE" \
    -n "$NAMESPACE" \
    --type merge \
    -p "{\"spec\":{\"selector\":{\"app\":\"employee-api\",\"version\":\"${TARGET_COLOR}\"}}}"

# 5. Smoke test through stable Service
echo "Starting Service port-forward..."

kubectl port-forward \
    -n "$NAMESPACE" \
    service/"$SERVICE" \
    "${SERVICE_TEST_PORT}:8000" \
    >/tmp/employee-api-service-port-forward.log 2>&1 &

PORT_FORWARD_PID=$!

SMOKE_TEST_PASSED=false

for i in {1..30}; do
    if curl -fsS "http://127.0.0.1:${SERVICE_TEST_PORT}/health" >/dev/null &&
       curl -fsS "http://127.0.0.1:${SERVICE_TEST_PORT}/version" >/dev/null; then
        SMOKE_TEST_PASSED=true
        break
    fi

    sleep 2
done

cleanup
PORT_FORWARD_PID=""

# 6. Roll back if smoke tests fail
if [[ "$SMOKE_TEST_PASSED" != "true" ]]; then
    echo "ERROR: Smoke tests failed."
    echo "Rolling traffic back to $PREVIOUS_COLOR..."

    kubectl patch service "$SERVICE" \
        -n "$NAMESPACE" \
        --type merge \
        -p "{\"spec\":{\"selector\":{\"app\":\"employee-api\",\"version\":\"${PREVIOUS_COLOR}\"}}}"

    exit 1
fi

echo "=================================="
echo "Deployment successful!"
echo "Active version: $TARGET_COLOR"
echo "=================================="
