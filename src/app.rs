use eframe::egui;

/// The three operating modes of Calce.
///
/// The modes are exposed as plain selectable labels in the top bar;
/// cluttered menus are reserved for CAS mode only.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Mode {
    /// Plain arithmetic calculator.
    Basic,
    /// Function graphing.
    Graph,
    /// Computer algebra system.
    Cas,
}

/// Top-level application state.
pub struct CalceApp {
    /// Currently selected mode.
    mode: Mode,
    /// Whether the "About Calce" window is open.
    show_about: bool,
}

impl CalceApp {
    /// Creates a new application instance with the Basic mode preselected.
    pub fn new(_cc: &eframe::CreationContext) -> Self {
        Self {
            mode: Mode::Basic,
            show_about: false,
        }
    }
}

impl eframe::App for CalceApp {
    fn ui(&mut self, ui: &mut egui::Ui, _frame: &mut eframe::Frame) {
        // Top bar: mode switcher on the left, About button on the right.
        egui::Panel::top("topbar").show(ui, |ui| {
            ui.horizontal(|ui| {
                ui.selectable_value(&mut self.mode, Mode::Basic, "Basic");
                ui.selectable_value(&mut self.mode, Mode::Graph, "Graph");
                ui.selectable_value(&mut self.mode, Mode::Cas, "CAS");

                ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                    if ui.button("About").clicked() {
                        self.show_about = true;
                    }
                });
            });
        });

        // Central panel: centered placeholder heading for the active mode.
        egui::CentralPanel::default().show(ui, |ui| {
            ui.vertical_centered(|ui| {
                let heading = match self.mode {
                    Mode::Basic => "Basic calculator — coming in milestone 3",
                    Mode::Graph => "Graphing — coming in milestone 4",
                    Mode::Cas => "CAS — coming in milestone 5",
                };
                ui.heading(heading);
            });
        });

        // About dialog.
        if self.show_about {
            egui::Window::new("About Calce")
                .collapsible(false)
                .resizable(false)
                .open(&mut self.show_about)
                .show(ui.ctx(), |ui| {
                    ui.heading("Calce 0.1.0");
                    ui.label("3-in-1 calculator for Windows · Linux · Android");
                    ui.separator();
                    ui.label("Contributor: Enderman-brewer");
                    ui.separator();
                    ui.label("Third-party:");
                    ui.label("• eframe / egui — MIT OR Apache-2.0");
                    ui.label("• num-bigint / num-rational — MIT OR Apache-2.0");
                    ui.label("• typst (planned) — Apache-2.0");
                    ui.label("• tiny-skia (planned) — BSD-3-Clause");
                    ui.separator();
                    ui.label("License: MIT — Copyright (c) 2026 Enderman-brewer");
                });
        }
    }
}
