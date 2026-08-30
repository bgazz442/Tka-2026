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

application_id_file='android/app/build.gradle.kts'
if [[ ! -f "$application_id_file" ]]; then
  echo "Android application Gradle file not found: $application_id_file"
  rm -f android/app/google-services.json
  exit 1
fi

android_application_id="$(sed -n 's/^[[:space:]]*applicationId[[:space:]]*=[[:space:]]*"\([^"]*\)".*$/\1/p' "$application_id_file" | head -n 1)"
if [[ -z "$android_application_id" ]]; then
  echo "Could not determine Android applicationId from $application_id_file"
  rm -f android/app/google-services.json
  exit 1
fi

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

if ! jq -e --arg package_name "$android_application_id" \
  '[.client[]?.client_info.android_client_info.package_name] | index($package_name)' \
  android/app/google-services.json >/dev/null; then
  echo "The Firebase Android config does not contain the project's Android applicationId."
  echo "Download google-services.json for the Firebase Android app matching the project's applicationId."
  rm -f android/app/google-services.json
  exit 1
fi

echo "android/app/google-services.json created from GitHub secret."
