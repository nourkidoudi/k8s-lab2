#!/usr/bin/env bash
export KUBECONFIG=/home/nour/.kube/config
export PATH=/usr/local/bin:/usr/bin:/bin
REPO=/home/nour/k8s-lab2
STATE="$REPO/.last-deployed"
cd "$REPO" || exit 1

git fetch -q origin main && git merge -q --ff-only origin/main
REMOTE_SHA=$(git rev-parse origin/main)
LAST_SHA=$(cat "$STATE" 2>/dev/null || echo none)

if [ "$REMOTE_SHA" != "$LAST_SHA" ]; then
  echo "$(date -Is) deploying $REMOTE_SHA (previous: $LAST_SHA)"
  echo "$REMOTE_SHA" > "$STATE"
  ./scripts/deploy.sh || echo "$(date -Is) deploy FAILED for $REMOTE_SHA"
fi
