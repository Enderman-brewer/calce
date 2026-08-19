#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

/// Desktop entry point.
///
/// All application logic lives in the `calce` library so the same code also
/// builds as an Android cdylib (see `android_main` in `src/lib.rs`).
fn main() -> eframe::Result {
    calce::run()
}