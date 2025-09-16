#!/bin/bash
set -Eeuo pipefail
IFS=$'\n\t'

echo "=== 🚀 Firebase Hosting deploy ==="

if ! command -v firebase >/dev/null 2>&1; then
  echo "❌ firebase CLI not found"
  exit 1
fi

PROJECT_ID=${FIREBASE_PROJECT_ID:-""}
EXTRA_FLAGS="--non-interactive"
if [ "${FIREBASE_DEBUG:-}" = "1" ]; then
  EXTRA_FLAGS="$EXTRA_FLAGS --debug"
fi
if [ -z "$PROJECT_ID" ]; then
  echo "ℹ️ FIREBASE_PROJECT_ID not set, firebase will use default project from .firebaserc if exists"
fi

DEPLOY_DIR=${1:-"app"}
echo "📁 Deploy dir: $DEPLOY_DIR"

if [ ! -f "firebase.json" ]; then
  echo "ℹ️ Creating minimal firebase.json"
  cat > firebase.json << 'JSON'
{
  "hosting": {
    "public": "app",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ]
  }
}
JSON
fi

ADC=${GOOGLE_APPLICATION_CREDENTIALS:-""}
if [ -n "$ADC" ] && [ -f "$ADC" ]; then
  echo "🔐 Using ADC at $ADC"
  if [ -n "$PROJECT_ID" ]; then
    firebase deploy --only hosting --project "$PROJECT_ID" $EXTRA_FLAGS
  else
    firebase deploy --only hosting $EXTRA_FLAGS
  fi
else
  echo "🔑 Using FIREBASE_TOKEN auth"
  if [ -z "${FIREBASE_TOKEN:-}" ]; then
    echo "❌ FIREBASE_TOKEN is empty and GOOGLE_APPLICATION_CREDENTIALS not set."
    exit 1
  fi
  if [ -n "$PROJECT_ID" ]; then
    firebase deploy --only hosting --project "$PROJECT_ID" --token "$FIREBASE_TOKEN" $EXTRA_FLAGS
  else
    firebase deploy --only hosting --token "$FIREBASE_TOKEN" $EXTRA_FLAGS
  fi
fi

echo "✅ Firebase deploy done"


