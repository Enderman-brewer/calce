#!/usr/bin/env bash
set -euo pipefail

echo "=== Building for all platforms ==="
echo "[1/3] Linux"
bash "$(dirname "$0")/build-linux.sh"
echo "[2/3] Windows"
bash "$(dirname "$0")/build-windows.sh"
echo "[3/3] Android"
bash "$(dirname "$0")/build-android.sh"
echo "All builds complete!"
