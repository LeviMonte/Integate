//
//  ReportProblemView.swift
//  Integate
//
//  Opens the native iOS mail composer pre-filled with problem context.
//  The user taps Send themselves — nothing is sent on their behalf.
//

import SwiftUI
import MessageUI

// MARK: - Report Sheet

struct ReportProblemView: View {
    /// Pass the currently active problem when calling from the solving screen.
    var currentProblem: MathProblem? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var userMessage = ""
    @State private var showComposer = false
    @State private var showFallbackAlert = false

    private let recipient = "Levimonte18@gmail.com"

    private var subject: String {
        guard let p = currentProblem else { return "Integate — Problem Report" }
        return "Integate Report: \(p.displayPrimary)"
    }

    private var emailBody: String {
        var lines: [String] = []
        if let p = currentProblem {
            lines += [
                "── Problem ──────────────────",
                "Display:   \(p.displayPrimary)",
                "Answer:    \(p.answerDisplay)",
                "Technique: \(p.technique)",
                "Subject:   \(p.subject.rawValue)  |  Level: \(p.level.displayName)",
                "",
            ]
        }
        lines += [
            "── Report ───────────────────",
            userMessage.isEmpty ? "(no message)" : userMessage,
        ]
        return lines.joined(separator: "\n")
    }

    var body: some View {
        NavigationStack {
            Form {
                // ── Problem context (read-only preview) ──────
                if let p = currentProblem {
                    Section("Problem Being Reported") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(p.displayPrimary)
                                .font(.system(size: 16, design: .serif))
                            HStack(spacing: 6) {
                                Chip(p.subject.rawValue)
                                Chip(p.level.displayName)
                                Chip(p.technique)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // ── User message ──────────────────────────────
                Section {
                    ZStack(alignment: .topLeading) {
                        if userMessage.isEmpty {
                            Text("Describe the issue — wrong answer, typo, confusing wording…")
                                .foregroundStyle(.tertiary)
                                .font(.subheadline)
                                .padding(.top, 8).padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                        TextEditor(text: $userMessage)
                            .frame(minHeight: 120)
                    }
                } header: {
                    Text("What's Wrong?")
                } footer: {
                    Text("This will open your Mail app with the details pre-filled.")
                }

                // ── Open mail ─────────────────────────────────
                Section {
                    Button {
                        if MFMailComposeViewController.canSendMail() {
                            showComposer = true
                        } else {
                            // Fallback: mailto: URL
                            let sub = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                            let bod = emailBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                            if let url = URL(string: "mailto:\(recipient)?subject=\(sub)&body=\(bod)"),
                               UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                                dismiss()
                            } else {
                                showFallbackAlert = true
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Label("Open in Mail", systemImage: "envelope.fill")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .tint(.indigo)
                }
            }
            .navigationTitle("Report a Problem")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showComposer) {
                MailComposer(recipient: recipient, subject: subject, body: emailBody) {
                    dismiss()
                }
            }
            .alert("Mail Not Set Up", isPresented: $showFallbackAlert) {
                Button("OK") {}
            } message: {
                Text("No Mail account is configured on this device. Email \(recipient) directly.")
            }
        }
    }
}

// MARK: - MFMailComposeViewController wrapper

private struct MailComposer: UIViewControllerRepresentable {
    let recipient: String
    let subject:   String
    let body:      String
    let onDone:    () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onDone: onDone) }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients([recipient])
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onDone: () -> Void
        init(onDone: @escaping () -> Void) { self.onDone = onDone }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            controller.dismiss(animated: true) { self.onDone() }
        }
    }
}

// MARK: - Chip label

private struct Chip: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 7).padding(.vertical, 3)
            .background(Color.gray.opacity(0.1), in: Capsule())
    }
}
