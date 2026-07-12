//
//  AppPickerView.swift
//  MathGate
//
//  Created by Levi Monte on 6/23/26.
//

import SwiftUI

/// Honor-system app list — no FamilyControls needed.
/// The user types in which apps they commit to not opening without solving first.
struct AppPickerView: View {
    @Binding var appNames: [String]
    @Environment(\.dismiss) private var dismiss

    @State private var newAppName: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("e.g. Instagram", text: $newAppName)
                            .autocorrectionDisabled()
                        Button {
                            let trimmed = newAppName.trimmingCharacters(in: .whitespaces)
                            guard !trimmed.isEmpty else { return }
                            appNames.append(trimmed)
                            newAppName = ""
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.indigo)
                                .font(.title3)
                        }
                        .buttonStyle(.plain)
                        .disabled(newAppName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                } header: {
                    Text("Add an app")
                }

                if !appNames.isEmpty {
                    Section("Your commitment list") {
                        ForEach(appNames, id: \.self) { name in
                            Label(name, systemImage: "app.fill")
                        }
                        .onDelete { appNames.remove(atOffsets: $0) }
                    }
                }

                Section {
                    Label("These apps won't actually be blocked — that requires Apple's FamilyControls entitlement, which is pending. This list is a personal commitment: don't open them without solving a problem first.", systemImage: "info.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Apps to Limit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
        }
    }
}
