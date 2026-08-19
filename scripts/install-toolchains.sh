#!/usr/bin/env bash
set -euo pipefail

# Determine project root and tool directories
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$HOME/.local/calce-tools"
ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"

# Create necessary directories
mkdir -p "$TOOLS_DIR" "$ANDROID_HOME"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to log messages with timestamps
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# Install JRE 17 (Temurin) if not present
if [ ! -f "$TOOLS_DIR/jre/bin/java" ]; then
    log "Installing Temurin JRE 17..."
    curl -fSL -o "$TOOLS_DIR/jre.tar.gz" \
        "https://api.adoptium.net/v3/binary/latest/17/ga/linux/x64/jre/hotspot/normal/eclipse"
    rm -rf "$TOOLS_DIR/jre"
    mkdir -p "$TOOLS_DIR/jre"
    tar -xzf "$TOOLS_DIR/jre.tar.gz" -C "$TOOLS_DIR/jre" --strip-components=1
    if [ ! -x "$TOOLS_DIR/jre/bin/java" ]; then
        echo "Error: JRE installation failed" >&2
        exit 1
    fi
    log "JRE installed at $TOOLS_DIR/jre"
fi

export JAVA_HOME="$TOOLS_DIR/jre"
export PATH="$JAVA_HOME/bin:$PATH"

# Install Rust cross-compilation targets
log "Setting up Rust toolchain..."
if ! command_exists rustc; then
    echo "Rust not found. Please install Rust using rustup and re-run this script."
    echo "Download instructions: https://rustup.rs/"
    exit 1
fi

rustup target add \
    x86_64-pc-windows-gnu \
    aarch64-linux-android \
    armv7-linux-androideabi \
    x86_64-linux-android

# Install cargo-apk if not present
if ! command_exists cargo-apk; then
    log "Installing cargo-apk..."
    cargo install cargo-apk --quiet
fi

# Install Android SDK components
log "Installing Android SDK components..."
# Download and install commandlinetools if not present
if [ ! -f "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
    echo "Downloading Android SDK cmdline-tools..."
    curl -fSL -o "$TOOLS_DIR/commandlinetools.zip" \
        "https://dl.google.com/android/repository/commandlinetools-linux-latest.zip"
    unzip -q "$TOOLS_DIR/commandlinetools.zip" -d "$ANDROID_HOME/cmdline-tools"
    rm -f "$TOOLS_DIR/commandlinetools.zip"
    log "Android cmdline-tools installed"
fi

export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$ANDROID_HOME/platform-tools:$PATH"

# Accept licenses and install SDK packages
if ! yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" \
    --sdk_root="$ANDROID_HOME" \
    "platform-tools" \
    "build-tools;34.0.0" \
    "platforms;android-34" \
    "ndk;25.1.8394850" 2>&1 | grep -E "Installing|Installed"; then
    echo "Warning: SDK package installation may have failed"
fi

# Install MinGW runtime (w64devkit) for Windows linking
if [ ! -f "$TOOLS_DIR/w64devkit/x86_64-w64-mingw32/lib/libmingwex.a" ]; then
    log "Downloading w64devkit..."
    curl -fSL -o "$TOOLS_DIR/w64devkit-x64-2.9.1.7z.exe" \
        "https://github.com/skeeto/w64devkit/releases/download/v2.9.1/w64devkit-x64-2.9.1.7z.exe"
    mkdir -p "$TOOLS_DIR/w64devkit"
    7z x -o"$TOOLS_DIR/w64devkit" "$TOOLS_DIR/w64devkit-x64-2.9.1.7z.exe" >/dev/null
    if [ ! -f "$TOOLS_DIR/w64devkit/x86_64-w64-mingw32/lib/libmingwex.a" ]; then
        echo "Error: MinGW runtime extraction failed" >&2
        exit 1
    fi
    log "MinGW runtime installed"
fi

# Write environment configuration file
echo "Writing environment configuration..."
cat > "$HOME/.config/calce/env.sh" <<ENV
export ANDROID_HOME="$ANDROID_HOME"
export JAVA_HOME="$JAVA_HOME"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH:$ANDROID_HOME/platform-tools:$PATH:$JAVA_HOME/bin:$PATH"
ENV
chmod 644 "$HOME/.config/calce/env.sh"
log "Environment configuration written to $HOME/.config/calce/env.sh"

echo "Source the environment file with: source $HOME/.config/calce/env.sh"

log "All toolchains installed successfully!"
