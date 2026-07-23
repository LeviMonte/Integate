//
//  OnboardingView.swift
//  Integate
//
//  Last page lets the user grant Screen Time permission and pick which
//  apps/categories to block, right on first launch — no digging through
//  Settings later required.
//

import SwiftUI
import FamilyControls

struct OnboardingView: View {
    let onDismiss: () -> Void

    @EnvironmentObject var screenTime: ScreenTimeManager

    @State private var page = 0
    @State private var showPicker       = false
    @State private var isRequestingAuth = false

    private struct PageData {
        let icon: String
        let title: String
        let body: String
        let accent: Color
    }

    private let pages: [PageData] = [
        PageData(
            icon: "🧮",
            title: "Welcome to Integate",
            body: "No math, no scroll. Solve problems to earn screen time — the harder the math, the more time you unlock.",
            accent: .indigo
        ),
        PageData(
            icon: "⏱",
            title: "Earn Time, Build Streaks",
            body: "Each correct first-try answer builds your streak and multiplies your reward. Risk it all with Double-or-Nothing for 2× time.",
            accent: .orange
        ),
        PageData(
            icon: "📚",
            title: "Five Subjects",
            body: "Integrals, Derivatives, Algebra, SAT Math, and Physics — each with four difficulty levels to unlock. Study first in the Learn tab.",
            accent: .purple
        ),
    ]

    /// Total tab count = static intro pages + the final setup page.
    private var pageCount: Int { pages.count + 1 }
    private var isSetupPage: Bool { page == pages.count }
    private var accentForCurrentPage: Color { isSetupPage ? .indigo : pages[page].accent }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background gradient that shifts with page
            LinearGradient(
                colors: [accentForCurrentPage.opacity(0.08), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.4), value: page)

            // Page content
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { i in
                    pageSlide(pages[i]).tag(i)
                }
                setupSlide.tag(pages.count)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Controls overlay
            VStack(spacing: 24) {
                // Dot indicators
                HStack(spacing: 8) {
                    ForEach(0..<pageCount, id: \.self) { i in
                        Capsule()
                            .fill(i == page ? accentForCurrentPage : Color.gray.opacity(0.3))
                            .frame(width: i == page ? 28 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: page)
                    }
                }

                if page < pageCount - 1 {
                    Button("Continue") {
                        withAnimation(.spring(response: 0.4)) { page += 1 }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(accentForCurrentPage)
                    .controlSize(.large)
                    .animation(.easeInOut(duration: 0.2), value: page)
                } else {
                    Button("Get Started") { onDismiss() }
                        .buttonStyle(.borderedProminent)
                        .tint(accentForCurrentPage)
                        .controlSize(.large)
                }
            }
            .padding(.bottom, 56)
        }
        .familyActivityPicker(isPresented: $showPicker, selection: $screenTime.activitySelection)
    }

    @ViewBuilder
    private func pageSlide(_ pg: PageData) -> some View {
        VStack(spacing: 32) {
            Spacer()

            Text(pg.icon)
                .font(.system(size: 90))
                .shadow(color: pg.accent.opacity(0.2), radius: 20)

            VStack(spacing: 16) {
                Text(pg.title)
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)

                Text(pg.body)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
            Spacer()  // extra space so bottom controls don't overlap
        }
        .padding()
    }

    // MARK: - Setup Page (Screen Time permission + app picker)

    private var selectedAppCount: Int { screenTime.activitySelection.applicationTokens.count }
    private var selectedCatCount: Int { screenTime.activitySelection.categoryTokens.count }
    private var hasSelection:     Bool { selectedAppCount > 0 || selectedCatCount > 0 }

    private var setupSlide: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 12)

            Text("🔒")
                .font(.system(size: 80))
                .shadow(color: Color.indigo.opacity(0.2), radius: 20)

            VStack(spacing: 12) {
                Text("Choose What to Block")
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)

                Text("Pick the apps or categories you want gated behind math problems. You can change this anytime in Settings.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: 14) {
                if !screenTime.isAuthorized {
                    Button {
                        isRequestingAuth = true
                        Task {
                            await screenTime.requestAuthorization()
                            isRequestingAuth = false
                        }
                    } label: {
                        HStack {
                            if isRequestingAuth {
                                ProgressView().tint(.white)
                            } else {
                                Label("Grant Screen Time Permission", systemImage: "lock.shield.fill")
                                    .font(.subheadline.weight(.semibold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                    .controlSize(.large)
                    .disabled(isRequestingAuth)
                } else {
                    Button {
                        showPicker = true
                    } label: {
                        Label(
                            hasSelection ? "Change Selected Apps & Categories" : "Choose Apps to Block",
                            systemImage: "plus.circle.fill"
                        )
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                    .controlSize(.large)

                    if hasSelection {
                        HStack(spacing: 12) {
                            if selectedAppCount > 0 {
                                Label("\(selectedAppCount) app\(selectedAppCount == 1 ? "" : "s")", systemImage: "app.fill")
                                    .foregroundStyle(.indigo)
                            }
                            if selectedCatCount > 0 {
                                Label("\(selectedCatCount) categor\(selectedCatCount == 1 ? "y" : "ies")", systemImage: "square.grid.2x2.fill")
                                    .foregroundStyle(.purple)
                            }
                        }
                        .font(.caption.weight(.medium))
                    } else {
                        Text("Nothing selected yet — you can also do this later from Settings.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 36)

            Spacer()
            Spacer()
        }
        .padding()
    }
}
