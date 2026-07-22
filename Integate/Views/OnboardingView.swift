//
//  OnboardingView.swift
//  Integate
//

import SwiftUI

struct OnboardingView: View {
    let onDismiss: () -> Void

    @State private var page = 0

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

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background gradient that shifts with page
            LinearGradient(
                colors: [pages[page].accent.opacity(0.08), Color.clear],
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
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Controls overlay
            VStack(spacing: 24) {
                // Dot indicators
                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { i in
                        Capsule()
                            .fill(i == page ? pages[page].accent : Color.gray.opacity(0.3))
                            .frame(width: i == page ? 28 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: page)
                    }
                }

                if page < pages.count - 1 {
                    Button("Continue") {
                        withAnimation(.spring(response: 0.4)) { page += 1 }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(pages[page].accent)
                    .controlSize(.large)
                    .animation(.easeInOut(duration: 0.2), value: page)
                } else {
                    Button("Get Started") { onDismiss() }
                        .buttonStyle(.borderedProminent)
                        .tint(pages[page].accent)
                        .controlSize(.large)
                }
            }
            .padding(.bottom, 56)
        }
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
}
