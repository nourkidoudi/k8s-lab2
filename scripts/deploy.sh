#!/usr/bin/env bash
set -euo pipefail
export KUBECONFIG=/home/nour/.kube/config
cd "$(dirname "$0")/.."

echo "== 1. Validate"
kubectl apply --dry-run=server -f manifests/

echo "== 2. Deploy"
kubectl apply -f manifests/

echo "== 3. Wait for rollout"
if ! kubectl rollout status deployment/web -n lab2 --timeout=120s; then
  echo "== Rollout failed: rolling back"
  kubectl rollout undo deployment/web -n lab2
  exit 1
fi

echo "== 4. Smoke test"
if ! curl -fsS --retry 5 --retry-delay 3 --retry-connrefused -o /dev/null http://192.168.237.131:30080; then
  echo "== Smoke test failed: rolling back"
  kubectl rollout undo deployment/web -n lab2
  exit 1
fi
echo "== Deployment OK"
