//
//  AppPickerView.swift
//  Integate
//
//  Uses FamilyActivityPicker to let the user select real apps to block.
//  The selection is stored in ScreenTimeManager and applied via ManagedSettingsStore.
//

import SwiftUI
import FamilyControls

struct AppPickerView: View {
    @EnvironmentObject var screenTime: ScreenTimeManager
    @Environment(\.dismiss) private var dismiss

    @State private var showPicker       = false
    @State private var showAuthAlert    = false
    @State private var isRequestingAuth = false

    var selectedAppCount: Int    { screenTime.activitySelection.applicationTokens.count }
    var selectedCatCount: Int    { screenTime.activitySelection.categoryTokens.count }
    var hasSelection:     Bool   { selectedAppCount > 0 || selectedCatCount > 0 }

    var body: some View {
        NavigationStack {
            List {

                // ── Auth warning ──────────────────────────────
                if !screenTime.isAuthorized {
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Screen Time Permission Needed", systemImage: "lock.shield.fill")
                                .font(.headline).foregroundStyle(.orange)
                            Text("This app needs Screen Time permission to actually block apps. Without it, Integate can't enforce anything — solving problems is entirely optional until you grant it.")
                                .font(.caption).foregroundStyle(.secondary)
                            Button {
                                isRequestingAuth = true
                                Task {
                                    await screenTime.requestAuthorization()
                                    isRequestingAuth = false
                                }
                            } label: {
                                if isRequestingAuth {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Grant Permission")
                                        .font(.subheadline.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                            .disabled(isRequestingAuth)
                        }
                        .padding(.vertical, 4)
                    }
                }

                // ── Picker button ─────────────────────────────
                Section {
                    Button {
                        if screenTime.isAuthorized {
                            showPicker = true
                        } else {
                            showAuthAlert = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill").foregroundStyle(.indigo)
                            Text(hasSelection ? "Change Selected Apps & Categories" : "Choose Apps to Block")
                        }
                    }
                    .foregroundStyle(.primary)
                } footer: {
                    Text("When you open a blocked app, a math problem screen will appear. Solve it to unlock the app.")
                }

                // ── Selection summary ─────────────────────────
                if selectedAppCount > 0 || selectedCatCount > 0 {
                    Section("Currently Blocking") {
                        if selectedAppCount > 0 {
                            Label(
                                "\(selectedAppCount) app\(selectedAppCount == 1 ? "" : "s")",
                                systemImage: "app.fill"
                            )
                            .foregroundStyle(.indigo)
                        }
                        if selectedCatCount > 0 {
                            Label(
                                "\(selectedCatCount) categor\(selectedCatCount == 1 ? "y" : "ies")  (e.g. Social, Games)",
                                systemImage: "square.grid.2x2.fill"
                            )
                            .foregroundStyle(.purple)
                        }
                    }

                    Section {
                        Button(role: .destructive) {
                            screenTime.activitySelection = FamilyActivitySelection()
                            screenTime.removeRestrictions()
                        } label: {
                            Label("Remove All Blocks", systemImage: "xmark.circle.fill")
                        }
                    }
                }

                // ── How it works ──────────────────────────────
                Section("How it Works") {
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(icon: "hand.tap.fill", color: .indigo,
                                text: "You open Instagram → a math problem screen appears immediately.")
                        InfoRow(icon: "function",      color: .purple,
                                text: "Solve the problem → the app opens and your earned time starts.")
                        InfoRow(icon: "timer",         color: .green,
                                text: "Time runs out → the block re-activates automatically.")
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Blocked Apps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .familyActivityPicker(isPresented: $showPicker,
                                   selection: $screenTime.activitySelection)
            .alert("Permission Required", isPresented: $showAuthAlert) {
                Button("OK") {}
            } message: {
                Text("Grant Screen Time permission first (see the yellow section above).")
            }
        }
    }
}

// MARK: - Info Row

private struct InfoRow: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(color)
                .frame(width: 22)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
