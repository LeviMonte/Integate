//
//  ProgressView.swift
//  Integate
//

import SwiftUI

struct ProgressTabView: View {
    @EnvironmentObject var progress: UserProgress
    @EnvironmentObject var streaks:  StreakManager

    /// nil = "Overall" (all subjects combined)
    @State private var selectedSubject: MathSubject? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // ── Static top section ──
                    levelCard
                    streakCard

                    // ── Subject tabs (below streaks only) ──
                    subjectTabBar

                    // ── Stats change with subject ──
                    statsGrid
                    timeCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Progress")
        }
    }

    // MARK: - Level Card (unchanged)

    private var levelCard: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(progress.currentLevel.emoji + " " + progress.currentLevel.displayName)
                        .font(.title2.weight(.bold))
                    Text("Level \(progress.currentLevel.rawValue) of 4")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack {
                    Text("\(progress.xp)")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.indigo)
                    Text("XP")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(Color.indigo.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            }

            if progress.xpToNextLevel != .max {
                VStack(alignment: .leading, spacing: 4) {
                    ProgressBar(value: progress.xpProgress, tint: .indigo)
                        .frame(height: 8)
                    HStack {
                        Text("\(progress.xp) XP").font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        Text("\(progress.xpToNextLevel) XP to \(nextLevelName)")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            } else {
                Label("Max Level Reached!", systemImage: "star.fill")
                    .foregroundStyle(.yellow).font(.subheadline.weight(.semibold))
            }

            HStack(spacing: 8) {
                ForEach(MathLevel.allCases, id: \.rawValue) { level in
                    let unlocked = progress.unlockedLevels.contains(level)
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(unlocked ? Color.indigo : Color.gray.opacity(0.2))
                                .frame(width: 36, height: 36)
                            if unlocked {
                                Text(level.emoji).font(.subheadline)
                            } else {
                                Image(systemName: "lock.fill")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        Text(level.displayName)
                            .font(.caption2)
                            .foregroundStyle(unlocked ? .primary : .secondary)
                    }
                    if level != MathLevel.allCases.last {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(maxWidth: .infinity, maxHeight: 1)
                            .padding(.bottom, 18)
                    }
                }
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Streak Card (unchanged)

    private var streakCard: some View {
        VStack(spacing: 14) {
            HStack {
                Text("🔥 Streaks").font(.headline)
                Spacer()
                if streaks.consecutiveFirstTry > 0 {
                    Text("\(streaks.streakMultiplierLabel) time bonus")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.orange.opacity(0.15), in: Capsule())
                        .foregroundStyle(.orange)
                }
            }

            HStack(spacing: 0) {
                StatBlock(value: "\(streaks.consecutiveFirstTry)", label: "Current\nFirst-Try Streak")
                Divider().frame(height: 44)
                StatBlock(value: "\(progress.longestStreak)", label: "Longest\nStreak")
                Divider().frame(height: 44)
                StatBlock(value: "\(progress.dailyStreakDays)", label: "Day\nStreak 📅")
            }

            let displayCount = min(max(11, streaks.consecutiveFirstTry), 20)
            LazyVGrid(columns: Array(repeating: .init(.fixed(28)), count: displayCount > 10 ? 11 : displayCount), spacing: 6) {
                ForEach(0..<displayCount, id: \.self) { i in
                    Circle()
                        .fill(i < streaks.consecutiveFirstTry ? Color.orange : Color.gray.opacity(0.2))
                        .frame(width: 22, height: 22)
                        .overlay {
                            if i < streaks.consecutiveFirstTry {
                                Text("🔥").font(.system(size: 10))
                            }
                        }
                }
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Subject Tab Bar (below streaks only)

    private var subjectTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "Overall" pill
                Button {
                    withAnimation(.spring(response: 0.3)) { selectedSubject = nil }
                } label: {
                    Text("Overall")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(
                            selectedSubject == nil ? Color.indigo : Color.gray.opacity(0.12),
                            in: Capsule()
                        )
                        .foregroundStyle(selectedSubject == nil ? .white : .primary)
                }
                .buttonStyle(.plain)

                ForEach(MathSubject.allCases, id: \.rawValue) { subject in
                    Button {
                        withAnimation(.spring(response: 0.3)) { selectedSubject = subject }
                    } label: {
                        HStack(spacing: 5) {
                            Text(subject.icon).font(.system(size: 12, design: .serif))
                            Text(subject.shortName).font(.subheadline.weight(.medium))
                        }
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(
                            selectedSubject == subject ? subject.color : Color.gray.opacity(0.12),
                            in: Capsule()
                        )
                        .foregroundStyle(selectedSubject == subject ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Stats Grid (subject-aware)

    private var statsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(selectedSubject.map { "\($0.rawValue) Stats" } ?? "All-Time Stats")
                .font(.headline)

            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 12) {
                StatCard(
                    icon: "checkmark.circle.fill", color: .green,
                    value: "\(solvedCount)",
                    label: "Problems Solved"
                )
                StatCard(
                    icon: "bolt.fill", color: .yellow,
                    value: "\(firstTryCount)",
                    label: "First-Try Correct"
                )
                StatCard(
                    icon: "percent", color: .blue,
                    value: String(format: "%.0f%%", accuracyValue * 100),
                    label: "First-Try Rate"
                )
                StatCard(
                    icon: "star.fill", color: .purple,
                    value: selectedSubject == nil ? "\(progress.xp) XP" : "—",
                    label: "Total XP"
                )
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 20))
        .animation(.easeInOut(duration: 0.2), value: selectedSubject?.rawValue)
    }

    // MARK: - Time Card

    private var timeCard: some View {
        HStack {
            Image(systemName: "clock.fill").foregroundStyle(.indigo).font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text("Total Screen Time Earned")
                    .font(.subheadline).foregroundStyle(.secondary)
                Text(formattedTotalTime)
                    .font(.title3.weight(.bold))
            }
            Spacer()
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Computed helpers

    private var solvedCount: Int {
        guard let s = selectedSubject else { return progress.totalSolved }
        return progress.solved(for: s)
    }
    private var firstTryCount: Int {
        guard let s = selectedSubject else { return progress.totalFirstTryCorrect }
        return progress.firstTry(for: s)
    }
    private var accuracyValue: Double {
        guard let s = selectedSubject else { return progress.firstTryAccuracy }
        return progress.accuracy(for: s)
    }

    private var nextLevelName: String {
        MathLevel(rawValue: progress.currentLevel.rawValue + 1)?.displayName ?? "Max"
    }

    private var formattedTotalTime: String {
        let total = Int(progress.totalTimeEarned)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes) min"
    }
}

// MARK: - Reusable Components

struct ProgressBar: View {
    let value: Double
    let tint: Color
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.gray.opacity(0.15))
                Capsule()
                    .fill(tint)
                    .frame(width: geo.size.width * CGFloat(value))
                    .animation(.easeInOut(duration: 0.5), value: value)
            }
        }
    }
}

struct StatBlock: View {
    let value: String
    let label: String
    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.title2.weight(.bold))
            Text(label)
                .font(.caption2).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatCard: View {
    let icon: String
    let color: Color
    let value: String
    let label: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).foregroundStyle(color).font(.title3)
            Text(value).font(.title3.weight(.bold))
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
    }
}
