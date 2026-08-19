#!/usr/bin/env bash
set -euo pipefail
source "$HOME/.config/calce/env.sh" 2>/dev/null || { echo "Run scripts/install-toolchains.sh first" >&2; exit 1; }

cd "$(dirname "${BASH_SOURCE[0]}")/.."
if [ -z "$ANDROID_HOME" ] || [ -z "$JAVA_HOME" ]; then
    echo "ERROR: ANDROID_HOME or JAVA_HOME not set. Run install-toolchains.sh."
    exit 1
fi

cargo apk build --release

# Find the APK
echo "Finding APK..."
APK=$(find target -name "*.apk" -type f -newer Cargo.toml | head -n1)
if [ -z "$APK" ]; then
    echo "ERROR: APK not found after build"
    exit 1
fi
echo "Built: $APK"
