//
//  ContentView.swift
//  Integate
//
//  Created by Levi Monte on 6/23/26.
//

import SwiftUI
import FamilyControls

struct ContentView: View {
    @EnvironmentObject var screenTime: ScreenTimeManager
    @EnvironmentObject var progress: UserProgress

    var body: some View {
        TabView {
            UnlockView()
                .tabItem {
                    Label("Unlock", systemImage: "lock.open.fill")
                }

            LearningView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }

            ProgressTabView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.indigo)
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var screenTime: ScreenTimeManager
    @EnvironmentObject var progress:   UserProgress

    @AppStorage("mg_timeCap")        private var timeCap:        Int  = 15
    @AppStorage("mg_showTimeOfDay")  private var showTimeOfDay:  Bool = true

    @State private var showAppPicker       = false
    @State private var showResetConfirm    = false
    @State private var showReport          = false

    private let capOptions = [5, 10, 15, 20, 30]

    var body: some View {
        NavigationStack {
            List {
                // ── Active unlock status ──────────────────
                if screenTime.isUnlocked {
                    Section("Currently Unlocked") {
                        HStack {
                            Image(systemName: "timer").foregroundStyle(.green)
                            Text("\(screenTime.formattedTimeRemaining) remaining")
                                .fontWeight(.medium)
                            Spacer()
                            Button("End Early") { screenTime.revokeTimeNow() }
                                .foregroundStyle(.red).font(.subheadline)
                        }
                    }
                }

                // ── Time Cap ──────────────────────────────
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Max time earned per session")
                            .font(.subheadline.weight(.semibold))
                        HStack(spacing: 8) {
                            ForEach(capOptions, id: \.self) { cap in
                                Button {
                                    timeCap = cap
                                } label: {
                                    Text("\(cap)m")
                                        .font(.subheadline.weight(.medium))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            timeCap == cap ? Color.indigo : Color.gray.opacity(0.12),
                                            in: Capsule()
                                        )
                                        .foregroundStyle(timeCap == cap ? .white : .primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Session Limit")
                } footer: {
                    Text("How much time can stack up from solving problems in one session. Won't cut time you've already earned.")
                }

                // ── Display ───────────────────────────────
                Section("Display") {
                    Toggle(isOn: $showTimeOfDay) {
                        Label("Show time-of-day label", systemImage: "clock")
                    }
                    .tint(.indigo)
                }

                // ── Timer Behavior ─────────────────────────
                Section {
                    Toggle(isOn: $screenTime.activeUseOnlyMode) {
                        Label("Only count down while using apps", systemImage: "hourglass")
                    }
                    .tint(.indigo)
                } header: {
                    Text("Timer Behavior")
                } footer: {
                    Text(screenTime.activeUseOnlyMode
                         ? "Earned time only depletes while you're actually in a blocked app. Leave it or lock your phone and the clock pauses."
                         : "Earned time counts down continuously from the moment you solve a problem, whether or not you're using a blocked app.")
                }

                // ── App Blocking ──────────────────────────
                Section("App Blocking") {
                    Button {
                        showAppPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "lock.app.dashed").foregroundStyle(.indigo)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Manage Blocked Apps")
                                let apps = screenTime.activitySelection.applicationTokens.count
                                let cats = screenTime.activitySelection.categoryTokens.count
                                if apps > 0 || cats > 0 {
                                    Text("\(apps > 0 ? "\(apps) app\(apps == 1 ? "" : "s")" : "")\(apps > 0 && cats > 0 ? ", " : "")\(cats > 0 ? "\(cats) categor\(cats == 1 ? "y" : "ies")" : "")")
                                        .font(.caption).foregroundStyle(.secondary)
                                } else {
                                    Text("No apps blocked yet")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)

                    if !screenTime.isAuthorized {
                        Label("Grant Screen Time permission to enable real blocking", systemImage: "info.circle")
                            .font(.caption).foregroundStyle(.orange)
                    }
                }

                // ── Danger zone ───────────────────────────
                Section("Data") {
                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        Label("Reset All Progress", systemImage: "trash")
                    }
                }

                Section("Feedback") {
                    Button {
                        showReport = true
                    } label: {
                        Label("Report a Problem", systemImage: "exclamationmark.bubble")
                    }
                    .foregroundStyle(.primary)
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0")
                    LabeledContent("Blocking", value: screenTime.isAuthorized ? "FamilyControls ✓" : "Not authorized")
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showAppPicker) {
                AppPickerView()
                    .environmentObject(screenTime)
            }
            .sheet(isPresented: $showReport) {
                ReportProblemView()
            }
            .confirmationDialog(
                "Reset All Progress?",
                isPresented: $showResetConfirm,
                titleVisibility: .visible
            ) {
                Button("Reset Everything", role: .destructive) {
                    progress.resetAll()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently erases all XP, solves, streaks, and unlocked levels. It cannot be undone.")
            }
        }
    }
}
