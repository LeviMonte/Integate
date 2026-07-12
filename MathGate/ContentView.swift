//
//  ContentView.swift
//  MathGate
//
//  Created by Levi Monte on 6/23/26.
//

import SwiftUI

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
                        Text("Daily Time Cap")
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
                    Text("Time Cap")
                } footer: {
                    Text("Maximum time that can accumulate per session. Doesn't cut existing earned time.")
                }

                // ── Display ───────────────────────────────
                Section("Display") {
                    Toggle(isOn: $showTimeOfDay) {
                        Label("Show time-of-day label", systemImage: "clock")
                    }
                    .tint(.indigo)
                }

                // ── Apps I commit to limit ─────────────────
                Section("Apps I Commit to Limit") {
                    Button {
                        showAppPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.pencil").foregroundStyle(.indigo)
                            Text(screenTime.blockedAppNames.isEmpty ? "Add apps…" : "Edit list")
                            Spacer()
                            if !screenTime.blockedAppNames.isEmpty {
                                Text("\(screenTime.blockedAppNames.count) app\(screenTime.blockedAppNames.count == 1 ? "" : "s")")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)

                    ForEach(screenTime.blockedAppNames, id: \.self) { name in
                        Label(name, systemImage: "app.fill")
                            .foregroundStyle(.secondary).font(.subheadline)
                    }
                }

                // ── Honor System note ──────────────────────
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Honor System Mode", systemImage: "hand.raised.fill")
                            .font(.headline).foregroundStyle(.indigo)
                        Text("Real app blocking requires Apple's FamilyControls entitlement. For now, MathGate sends a notification when your time expires — the commitment to stay off listed apps is yours.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
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
                    LabeledContent("Blocking", value: "Notification-based")
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showAppPicker) {
                AppPickerView(appNames: $screenTime.blockedAppNames)
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
