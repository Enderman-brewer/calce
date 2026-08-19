#!/usr/bin/env bash
set -euo pipefail
source "$HOME/.config/calce/env.sh" 2>/dev/null || true

cd "$(dirname "${BASH_SOURCE[0]}")/.."
cargo build --release
echo "Built: target/release/calce"
