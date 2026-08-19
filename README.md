# Calce

A 3-in-1 calculator — Basic, Graphing, and CAS — for Windows, Linux and Android.

## Features

- **Basic** — arithmetic, memory, and history. No menus; the UI is display plus keypad only.
- **Graphing** — 2D-focused: y=f(x), parametric, polar, and implicit plots with zoom, pan, and trace. 3D surfaces are available in a submenu.
- **CAS** — simplify, factor, expand, differentiate, integrate, limit, series, and solve. Progressive disclosure: top commands reachable in at most 2 clicks, sub-options in at most 3, and any command can be held to pin it to the top bar, with a `..` up-menu to navigate back.
- **Exact math** — arbitrary-precision rationals throughout. Results render as exact decimals only when they terminate within 3 decimal places; otherwise they are proposed in notation (π, √, e, scientific) with a swap-format button.
- **Display tiers** — MathPrint (LaTeX-style, default), Classic (single-line with font glyphs), and Basic (plain text, monospace functions versus cursive variables).

## Architecture

Pure Rust end to end: egui/eframe for the UI, num-bigint/num-rational for the exact arithmetic core, an in-house CAS, and Typst-based math rendering.

## Project layout

```
Cargo.toml
src/
  main.rs
  app.rs
  lib.rs
.cargo/
  config.toml
rust-toolchain.toml
scripts/
  *.sh
```

## Building

Prerequisites: [rustup](https://rustup.rs) — nothing else. The `rust-lld` linker ships with the Rust toolchain, and the setup script downloads every other dependency user-locally.

Run the one-time toolchain setup, then build for your target platform:

```sh
./scripts/install-toolchains.sh
```

This downloads everything into your user directory (~5GB total) — no root/sudo required:

- Android SDK + NDK (r26d)
- A Temurin JRE 17 (needed for APK signing)
- The MinGW-w64 runtime (w64devkit), used when linking for Windows
- cargo-apk (Android APK builder), plus the rustup targets for Windows and Android

The build scripts auto-source the generated `~/.config/calce/env.sh`, which sets `ANDROID_HOME`, `NDK_VERSION`, and the MinGW library paths — no manual environment setup is needed.

```sh
./scripts/build-linux.sh
./scripts/build-windows.sh
./scripts/build-android.sh
./scripts/build-all.sh
```

Each script prints the expected artifact path for its target.

## Cross-compilation approach

Cross-compilation uses rustup targets for Windows (`x86_64-pc-windows-gnu`) and Android (`aarch64-linux-android`, `armv7-linux-androideabi`, `x86_64-linux-android`) — see `.cargo/config.toml` for the exact linker configuration.

- **Windows (`x86_64-pc-windows-gnu`)** — rustc links self-contained: its bundled CRT plus the `rust-lld` linker. The MinGW-w64 runtime libraries come from a user-local w64devkit install and are passed via `-L` linker arguments.
- **Android (`aarch64-linux-android`, `armv7-linux-androideabi`, `x86_64-linux-android`)** — `link-self-contained` is not supported on Android targets, so the NDK's clang driver is used as the linker. APK packaging goes through cargo-apk, which builds the cdylib target and enters via `android_main` in `src/lib.rs`.

The whole toolchain stays under ~5GB in the user's home directory and requires no sudo.

## Status

Milestone 1 — cross-platform skeleton app (Basic/Graph/CAS shell + About/Credits).

## License

MIT — see LICENSE. Copyright (c) 2026 Enderman-brewer.

## Contributors

- Enderman-brewer

Contributors are also listed in-app in the About → Credits screen.
