#!/usr/bin/env bash
set -euo pipefail

echo "== VitaPlatform Vercel build =="
echo "ENV CHECK: GOOGLE_WEB_CLIENT_ID length = ${#GOOGLE_WEB_CLIENT_ID}"

if [ -z "${GOOGLE_WEB_CLIENT_ID}" ]; then
  echo "ERROR: GOOGLE_WEB_CLIENT_ID is empty. Set it in Vercel -> Project -> Settings -> Environment Variables (Production/Preview)."
  exit 1
fi

# 1) install Flutter (stable) locally in build container
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:$PWD/flutter/bin"

flutter --version
flutter config --enable-web

# 2) build app
flutter pub get

flutter build web --release \
  --dart-define="GOOGLE_WEB_CLIENT_ID=${GOOGLE_WEB_CLIENT_ID}"
