#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${FIREBASE_GOOGLE_SERVICES_JSON:-}" ]]; then
  echo "Missing GitHub secret: FIREBASE_GOOGLE_SERVICES_JSON"
  echo "Create it in GitHub -> Settings -> Secrets and variables -> Actions"
  echo "and paste the full content of android/app/google-services.json"
  exit 1
fi

mkdir -p android/app
printf '%s' "$FIREBASE_GOOGLE_SERVICES_JSON" > android/app/google-services.json
chmod 600 android/app/google-services.json

if ! jq empty android/app/google-services.json >/dev/null 2>&1; then
  echo "FIREBASE_GOOGLE_SERVICES_JSON is not valid JSON."
  rm -f android/app/google-services.json
  exit 1
fi

if ! jq -e '.project_info.project_id and (.client | length > 0)' \
  android/app/google-services.json >/dev/null; then
  echo "The Firebase Android config is missing project_info.project_id or client."
  rm -f android/app/google-services.json
  exit 1
fi

if ! jq -e '[.client[]?.client_info.android_client_info.package_name] | index("com.example.futureee")' \
  android/app/google-services.json >/dev/null; then
  echo "The Firebase Android config does not contain package com.example.futureee."
  echo "Download google-services.json for the Firebase Android app with this exact package name."
  rm -f android/app/google-services.json
  exit 1
fi

echo "android/app/google-services.json created from GitHub secret."
