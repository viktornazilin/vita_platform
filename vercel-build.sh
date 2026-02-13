#!/usr/bin/env bash
set -e

# 1) install Flutter (stable) locally in build container
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:$PWD/flutter/bin"

flutter --version
flutter config --enable-web

# 2) build app
flutter pub get
flutter build web --release --dart-define=GOOGLE_WEB_CLIENT_ID=${GOOGLE_WEB_CLIENT_ID}
