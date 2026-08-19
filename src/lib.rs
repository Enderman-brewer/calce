//! Calce library crate.
//!
//! The library holds the whole app so that the same code compiles as a
//! desktop binary (src/main.rs) and as an Android cdylib (android_main below).

pub mod app;

use eframe::egui;

/// Default native options for the Calce window (desktop).
pub fn native_options() -> eframe::NativeOptions {
    eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default()
            .with_inner_size([960.0, 640.0])
            .with_min_inner_size([320.0, 480.0])
            .with_title("Calce"),
        ..Default::default()
    }
}

/// Desktop entry point (also what tests would call).
pub fn run() -> eframe::Result {
    eframe::run_native(
        "Calce",
        native_options(),
        Box::new(|cc| Ok(Box::new(app::CalceApp::new(cc)))),
    )
}

/// Android entry point. cargo-apk packages the cdylib; Android calls this.
#[cfg(target_os = "android")]
#[unsafe(no_mangle)]
fn android_main(app: winit::platform::android::activity::AndroidApp) {
    android_logger::init_once(
        android_logger::Config::default().with_max_level(log::LevelFilter::Info),
    );
    let options = eframe::NativeOptions {
        android_app: Some(app),
        ..Default::default()
    };
    eframe::run_native(
        "Calce",
        options,
        Box::new(|cc| Ok(Box::new(app::CalceApp::new(cc)))),
    )
    .unwrap();
}