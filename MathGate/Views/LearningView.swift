//
//  LearningView.swift
//  MathGate
//

import SwiftUI

// MARK: - Learning View

struct LearningView: View {
    @EnvironmentObject var progress: UserProgress
    @AppStorage("mg_selectedSubject") private var selectedSubjectRaw: String = MathSubject.integrals.rawValue
    private var selectedSubject: MathSubject { MathSubject(rawValue: selectedSubjectRaw) ?? .integrals }

    private var filteredTopics: [LearningTopic] {
        LearningTopic.all.filter { $0.subject == selectedSubject }
    }

    var body: some View {
        NavigationStack {
            List(filteredTopics) { topic in
                NavigationLink {
                    TopicDetailView(topic: topic)
                } label: {
                    TopicRowView(topic: topic)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Learn")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { subjectDropdown }
            }
        }
    }

    private var subjectDropdown: some View {
        Menu {
            ForEach(MathSubject.allCases, id: \.rawValue) { subject in
                Button {
                    selectedSubjectRaw = subject.rawValue
                } label: {
                    if selectedSubject == subject {
                        Label("\(subject.icon)  \(subject.rawValue)", systemImage: "checkmark")
                    } else {
                        Text("\(subject.icon)  \(subject.rawValue)")
                    }
                }
            }
        } label: {
            HStack(spacing: 5) {
                Text(selectedSubject.icon).font(.system(size: 13, design: .serif))
                Text(selectedSubject.shortName).font(.subheadline.weight(.semibold))
                Image(systemName: "chevron.down").font(.caption2.weight(.semibold))
            }
            .foregroundStyle(selectedSubject.color)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(selectedSubject.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - Topic Row

struct TopicRowView: View {
    let topic: LearningTopic

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(topic.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Text(topic.icon).font(.title3)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(topic.name).font(.headline)
                Text(topic.subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text("L\(topic.level.rawValue)")
                .font(.caption.weight(.bold))
                .foregroundStyle(topic.color)
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(topic.color.opacity(0.1), in: Capsule())
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Topic Detail (rich layout)

struct TopicDetailView: View {
    let topic: LearningTopic
    @State private var showAllExamples = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // ── Header ──────────────────────────────────
                headerCard

                // ── Key Insight ──────────────────────────────
                if !topic.keyInsight.isEmpty {
                    insightCallout
                }

                // ── Formula ──────────────────────────────────
                formulaBox

                // ── Why It Works ─────────────────────────────
                if !topic.whyItWorks.isEmpty {
                    whyItWorksSection
                }

                // ── When to Use ──────────────────────────────
                whenToUseSection

                // ── Worked Examples ──────────────────────────
                workedExamplesSection

                // ── Common Mistakes ──────────────────────────
                if !topic.commonMistakes.isEmpty {
                    commonMistakesSection
                }

                // ── Video Resource ───────────────────────────
                if !topic.videoURL.isEmpty {
                    videoLinkButton
                }

                // ── Practice Problems ────────────────────────
                practiceSection
            }
            .padding()
        }
        .navigationTitle(topic.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    // MARK: Header

    private var headerCard: some View {
        HStack(spacing: 14) {
            Text(topic.icon)
                .font(.system(size: 40))
                .frame(width: 60, height: 60)
                .background(topic.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 4) {
                Text(topic.name).font(.title2.weight(.bold))
                Text(topic.subtitle).font(.subheadline).foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    Text(topic.level.emoji + " " + topic.level.displayName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(topic.color)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(topic.color.opacity(0.1), in: Capsule())
                    Text(topic.subject.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: Key Insight callout

    private var insightCallout: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.yellow)
                .font(.title3)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 4) {
                Text("Key Insight")
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
                Text(topic.keyInsight)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color.yellow.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.yellow.opacity(0.3), lineWidth: 1))
    }

    // MARK: Formula

    private var formulaBox: some View {
        VStack(alignment: .leading, spacing: 8) {
            LearnSectionHeader("Formula")
            Text(topic.formula)
                .font(.system(size: 17, design: .serif))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(topic.color.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(topic.color.opacity(0.2), lineWidth: 1))
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: Why It Works

    private var whyItWorksSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "brain").foregroundStyle(topic.color)
                LearnSectionHeader("Why It Works")
            }
            Text(topic.whyItWorks)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: When to Use

    private var whenToUseSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            LearnSectionHeader("When to Use")
            Text(topic.whenToUse)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: Worked Examples

    private var workedExamplesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            LearnSectionHeader("Worked Examples")

            // Primary example always shown
            ExampleCard(label: "Example 1", content: topic.workedExample, color: topic.color)

            // Extra examples with Show/Hide toggle
            if !topic.extraExamples.isEmpty {
                if showAllExamples {
                    ForEach(Array(topic.extraExamples.enumerated()), id: \.offset) { i, ex in
                        ExampleCard(label: "Example \(i + 2)", content: ex.solution, color: topic.color, problem: ex.problem)
                    }
                    Button("Hide Extra Examples") {
                        withAnimation { showAllExamples = false }
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(topic.color)
                } else {
                    Button {
                        withAnimation { showAllExamples = true }
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill").foregroundStyle(topic.color)
                            Text("Show \(topic.extraExamples.count) More Example\(topic.extraExamples.count == 1 ? "" : "s")")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(topic.color)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(topic.color.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: Common Mistakes

    private var commonMistakesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
                LearnSectionHeader("Common Mistakes")
            }
            ForEach(Array(topic.commonMistakes.enumerated()), id: \.offset) { _, mistake in
                HStack(alignment: .top, spacing: 10) {
                    Text("✗")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.red)
                        .padding(.top, 2)
                    Text(mistake)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.05), in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: Video Link

    private var videoLinkButton: some View {
        Link(destination: URL(string: topic.videoURL)!) {
            HStack(spacing: 12) {
                Image(systemName: "play.rectangle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.red, in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Watch on YouTube")
                        .font(.subheadline.weight(.semibold))
                    Text("Khan Academy / 3Blue1Brown")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.background, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    // MARK: Practice Problems

    private var practiceSection: some View {
        let problems = MathEngine.shared.problems(for: topic.level, subject: topic.subject)
            .filter { $0.technique == topic.technique }
        return Group {
            if !problems.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    LearnSectionHeader("Practice Problems")
                    ForEach(problems) { problem in
                        PracticeProblemRow(problem: problem)
                    }
                }
                .padding()
                .background(.background, in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}

// MARK: - Example Card

struct ExampleCard: View {
    let label: String
    let content: String
    let color: Color
    var problem: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(color)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(color.opacity(0.12), in: Capsule())
                if !problem.isEmpty {
                    Text(problem)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
            }
            Text(content)
                .font(.system(size: 14, design: .monospaced))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(Color.gray.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Practice Problem Row

struct PracticeProblemRow: View {
    let problem: MathProblem
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3)) { expanded.toggle() }
            } label: {
                HStack {
                    Text(problem.displayPrimary)
                        .font(.system(size: 16, design: .serif))
                        .lineLimit(2)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            if expanded {
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text(problem.explanation)
                        .font(.system(size: 14, design: .monospaced))
                    HStack(spacing: 6) {
                        Text("Answer:").font(.caption).foregroundStyle(.secondary)
                        Text(problem.answerDisplay)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.indigo)
                    }
                }
                .padding(14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.gray.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.gray.opacity(0.15), lineWidth: 1))
    }
}

// MARK: - Technique Detail (from failure screen deep-link)

struct TechniqueDetailView: View {
    let technique: String
    let explanation: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("How to: \(technique)")
                    .font(.title3.weight(.bold))
                Text(explanation)
                    .font(.system(size: 15, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .navigationTitle(technique)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Section Header

struct LearnSectionHeader: View {
    let title: String
    init(_ title: String) { self.title = title }
    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .textCase(.uppercase)
            .foregroundStyle(.secondary)
    }
}
