//
//  UnlockView.swift
//  Integate
//

import SwiftUI

/// The main "earn screen time" screen.
/// Tabs at the top let users choose a subject; each subject has its own
/// problem bank. Time earned scales with subject.timeMultiplier.
struct UnlockView: View {
    @EnvironmentObject var screenTime: ScreenTimeManager
    @EnvironmentObject var streaks:    StreakManager
    @EnvironmentObject var progress:   UserProgress

    // Shared with LearningView via AppStorage so tab selection carries over
    @AppStorage("mg_selectedSubject")  private var selectedSubjectRaw: String = MathSubject.integrals.rawValue
    @AppStorage("mg_showTimeOfDay")    private var showTimeOfDay: Bool = true
    private var selectedSubject: MathSubject {
        get { MathSubject(rawValue: selectedSubjectRaw) ?? .integrals }
        set { selectedSubjectRaw = newValue.rawValue }
    }

    @State private var currentProblem: MathProblem? = nil
    @State private var selectedLevel: MathLevel = .basic   // remembers last tapped level
    @State private var phase: Phase = .idle
    @State private var showHint  = false
    @State private var hintUsed  = false      // tracks if hint was revealed this problem
    @State private var showSolution = false   // worked solution on failure screen
    @State private var earnedSeconds: Int = 0
    @State private var showReport = false     // report-a-problem sheet

    enum Phase {
        case idle, solving, success, failed
    }

    private let engine = MathEngine.shared

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [selectedSubject.color.opacity(0.06), Color.purple.opacity(0.03)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                        VStack(spacing: 20) {
                            // Shown when user tapped "Open Integate →" on a shield screen
                            // Hide once they start solving — no need to nag mid-problem
                            if screenTime.pendingUnlockActive && phase == .idle {
                                pendingUnlockBanner
                            }
                            if screenTime.timeRemainingSeconds > 0 {
                                timeRemainingBanner
                            }
                            if streaks.consecutiveFirstTry > 0 {
                                streakBanner
                            }

                            switch phase {
                            case .idle:    idleContent
                            case .solving:
                                if let p = currentProblem { solvingContent(problem: p) }
                            case .success: successContent
                            case .failed:  failedContent
                            }
                        }
                        .padding()
                }
            }
            .onChange(of: selectedSubjectRaw) {
                // Exit any active problem when the subject changes
                if phase != .idle {
                    withAnimation { phase = .idle }
                    currentProblem = nil
                    showHint = false
                }
            }
            .navigationTitle("Integate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if showTimeOfDay {
                    ToolbarItem(placement: .topBarLeading) {
                        Label(TimeOfDay.current.label, systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 4) {
                        // Report button — only visible while a problem is active
                        if phase == .solving, currentProblem != nil {
                            Button {
                                showReport = true
                            } label: {
                                Image(systemName: "exclamationmark.bubble")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        subjectDropdown
                    }
                }
            }
            .sheet(isPresented: $showReport) {
                ReportProblemView(currentProblem: currentProblem)
            }
        }
    }

    // MARK: - Subject Dropdown

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
                Text(selectedSubject.icon)
                    .font(.system(size: 13, design: .serif))
                Text(selectedSubject.shortName)
                    .font(.subheadline.weight(.semibold))
                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.semibold))
            }
            .foregroundStyle(selectedSubject.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(selectedSubject.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Banners

    /// Shows when the user tapped "Open Integate →" on a blocked-app shield.
    private var pendingUnlockBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 10) {
                Image(systemName: "lock.app.dashed")
                    .font(.title2).foregroundStyle(.indigo)
                VStack(alignment: .leading, spacing: 2) {
                    Text("App locked — solve to unlock")
                        .font(.headline)
                    Text("Defaulting to your highest difficulty. Change below if you want.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }

            // Quick subject picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MathSubject.allCases, id: \.rawValue) { subject in
                        Button {
                            selectedSubjectRaw = subject.rawValue
                        } label: {
                            Text("\(subject.icon) \(subject.shortName)")
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(
                                    selectedSubject == subject
                                        ? subject.color.opacity(0.2)
                                        : Color.gray.opacity(0.08),
                                    in: Capsule()
                                )
                                .foregroundStyle(selectedSubject == subject ? subject.color : .secondary)
                                .overlay(
                                    Capsule().strokeBorder(
                                        selectedSubject == subject ? subject.color.opacity(0.4) : Color.clear,
                                        lineWidth: 1
                                    )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Quick level picker
            HStack(spacing: 8) {
                ForEach(MathLevel.allCases, id: \.rawValue) { level in
                    let unlocked = progress.isUnlocked(level, for: selectedSubject)
                    Button {
                        guard unlocked else { return }
                        selectedLevel = level
                    } label: {
                        let isSelected = selectedLevel == level && unlocked
                        let bgColor: Color = isSelected ? Color.indigo.opacity(0.15) : Color.gray.opacity(0.06)
                        let fgColor: Color = !unlocked ? Color.secondary.opacity(0.4) : (selectedLevel == level ? Color.indigo : Color.secondary)
                        let borderColor: Color = isSelected ? Color.indigo.opacity(0.4) : Color.clear
                        VStack(spacing: 2) {
                            Text(level.emoji).font(.system(size: 14))
                            Text(level.displayName)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(bgColor, in: RoundedRectangle(cornerRadius: 8))
                        .foregroundStyle(fgColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8).strokeBorder(borderColor, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!unlocked)
                }
            }

            // Solve button — picks highest unlocked if current is locked
            Button {
                let best = [MathLevel.expert, .advanced, .intermediate, .basic]
                    .first { progress.isUnlocked($0, for: selectedSubject) } ?? .basic
                selectedLevel = best
                startNewProblem()
            } label: {
                Label("Solve Now →", systemImage: "function")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.indigo)
        }
        .padding()
        .background(Color.indigo.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.indigo.opacity(0.2), lineWidth: 1))
    }

    private var timeRemainingBanner: some View {
        HStack {
            Image(systemName: "timer")
            VStack(alignment: .leading, spacing: 1) {
                Text("Unlocked · \(screenTime.formattedTimeRemaining) remaining")
                    .fontWeight(.medium)
                if screenTime.activeUseOnlyMode {
                    Text("Only ticks down while you're in a blocked app")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button("Solve Another") { startNewProblem() }
                .font(.caption.weight(.semibold))
                .foregroundStyle(selectedSubject.color)
        }
        .padding()
        .background(Color.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.green.opacity(0.3), lineWidth: 1))
    }

    private var streakBanner: some View {
        HStack(spacing: 8) {
            Text(streaks.streakBadge).font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text("Streak: \(streaks.consecutiveFirstTry) in a row")
                    .font(.subheadline.weight(.semibold))
                Text("Multiplier: \(streaks.streakMultiplierLabel)")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if let next = streaks.nextMilestone {
                Text("\(next - streaks.consecutiveFirstTry) to next bonus")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Idle Content

    private var idleContent: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 20)

            // Subject description
            VStack(spacing: 6) {
                Text(selectedSubject.icon)
                    .font(.system(size: 40))
                Text(selectedSubject.rawValue)
                    .font(.title2.weight(.bold))
                Text(subjectDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Time multiplier note (non-integrals)
            if selectedSubject != .integrals {
                let mult = selectedSubject.timeMultiplier
                let pct  = Int(mult * 100)
                Text("⏱ Time reward: \(pct)% of integral rate")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1), in: Capsule())
            }

            // Level selector
            VStack(alignment: .leading, spacing: 10) {
                Text("Select level")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                ForEach(MathLevel.allCases, id: \.rawValue) { level in
                    let unlocked = progress.isUnlocked(level, for: selectedSubject)
                    Button {
                        guard unlocked else { return }
                        startProblem(at: level, subject: selectedSubject)
                    } label: {
                        HStack {
                            Text(level.emoji)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(level.displayName).fontWeight(.medium)
                                if !unlocked {
                                    let n = progress.solvesToUnlock(level, for: selectedSubject)
                                    Text("~\(n) solve\(n == 1 ? "" : "s") to unlock")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            if unlocked {
                                let baseMin = Int(Double(level.baseTimeSeconds) * selectedSubject.timeMultiplier) / 60
                                Text("+\(baseMin) min base")
                                    .font(.caption).foregroundStyle(.secondary)
                            } else {
                                Image(systemName: "lock.fill")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .padding(14)
                        .background(
                            unlocked
                                ? selectedSubject.color.opacity(0.08)
                                : Color.gray.opacity(0.06),
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!unlocked)
                }
            }

            // Double or Nothing
            if streaks.consecutiveFirstTry >= 2 && !streaks.doubleOrNothingActive {
                doubleOrNothingButton
            } else if streaks.doubleOrNothingActive {
                doubleOrNothingActiveLabel
            }
        }
    }

    // MARK: - Solving Content

    private func solvingContent(problem: MathProblem) -> some View {
        VStack(spacing: 20) {
            ProblemCardView(problem: problem)

            if showHint {
                HStack {
                    Image(systemName: "lightbulb.fill").foregroundStyle(.yellow)
                    Text(problem.hint)
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(12)
                .background(Color.yellow.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            DigitInputView(
                problem: problem,
                onSuccess: { firstTry in handleSuccess(firstTry: firstTry) },
                onFailure: { handleFailure() }
            )
            .id(problem.id)

            HStack {
                Button(role: .cancel) {
                    withAnimation { phase = .idle }
                } label: {
                    Label("Back", systemImage: "xmark").font(.subheadline)
                }
                .buttonStyle(.bordered).tint(.secondary)

                Spacer()

                Button {
                    withAnimation {
                        if !showHint { hintUsed = true }  // penalty: once peeked, always penalised
                        showHint.toggle()
                    }
                } label: {
                    Label(showHint ? "Hide Hint" : "Hint", systemImage: "lightbulb")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered).tint(hintUsed ? .orange : .yellow)
            }
        }
    }

    // MARK: - Success Content

    private var successContent: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64)).foregroundStyle(.green)

            VStack(spacing: 8) {
                Text("Correct! 🎉").font(.title.weight(.bold))
                Text("+\(StreakManager.format(seconds: earnedSeconds)) unlocked")
                    .font(.title3).foregroundStyle(.secondary)
                if hintUsed {
                    Label("Hint used · 50% time penalty", systemImage: "lightbulb.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1), in: Capsule())
                }
            }

            if streaks.doubleOrNothingActive {
                Label("Double-or-Nothing paid off!", systemImage: "flame.fill")
                    .foregroundStyle(.orange).fontWeight(.semibold)
            }

            VStack(spacing: 12) {
                Button("Solve Another") { startNewProblem() }
                    .buttonStyle(.borderedProminent)
                    .tint(selectedSubject.color)
                    .controlSize(.large)

                if streaks.consecutiveFirstTry >= 2 {
                    Button("Double or Nothing 🎲") {
                        streaks.activateDoubleOrNothing()
                        phase = .idle
                    }
                    .buttonStyle(.bordered).tint(.orange)
                }

                Button("Done for Now") { phase = .idle }
                    .buttonStyle(.plain).foregroundStyle(.secondary).font(.subheadline)
            }
        }
        .padding()
    }

    // MARK: - Failed Content

    private var failedContent: some View {
        VStack(spacing: 24) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 64)).foregroundStyle(.red)

            VStack(spacing: 8) {
                Text("Not quite 😔").font(.title.weight(.bold))
                Text("Streak reset to 0").foregroundStyle(.secondary)
                if let p = currentProblem {
                    Text("The answer was \(p.answerDisplay)")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
            }

            // Worked solution (expandable)
            if let p = currentProblem {
                workedSolutionCard(for: p)
            }

            VStack(spacing: 12) {
                Button("Try Again") { startNewProblem() }
                    .buttonStyle(.borderedProminent)
                    .tint(selectedSubject.color)
                    .controlSize(.large)

                if let p = currentProblem {
                    NavigationLink {
                        TechniqueDetailView(technique: p.technique, explanation: p.explanation)
                    } label: {
                        Label("Learn \(p.technique)", systemImage: "book.fill")
                    }
                    .buttonStyle(.bordered).tint(.purple)
                }

                Button("Back") { phase = .idle }
                    .buttonStyle(.plain).foregroundStyle(.secondary).font(.subheadline)
            }
        }
        .padding()
    }

    @ViewBuilder
    private func workedSolutionCard(for problem: MathProblem) -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35)) { showSolution.toggle() }
            } label: {
                HStack {
                    Label("See Worked Solution", systemImage: "function")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.purple)
                    Spacer()
                    Image(systemName: showSolution ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(Color.purple.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)

            if showSolution {
                VStack(alignment: .leading, spacing: 12) {
                    Text(problem.technique.uppercased())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.purple)

                    Text(problem.explanation)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 6) {
                        Text("Answer:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(problem.answerDisplay)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.purple)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.purple.opacity(0.05), in: RoundedRectangle(cornerRadius: 14))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Double or Nothing

    private var doubleOrNothingButton: some View {
        Button { streaks.activateDoubleOrNothing() } label: {
            HStack {
                Image(systemName: "die.face.6.fill").foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Double or Nothing").fontWeight(.semibold)
                    Text("Next correct = 2× time. Wrong = streak resets.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(14)
            .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.orange.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var doubleOrNothingActiveLabel: some View {
        HStack {
            Image(systemName: "flame.fill").foregroundStyle(.orange)
            Text("Double or Nothing Active — solve to double your time!")
                .font(.subheadline.weight(.medium)).foregroundStyle(.orange)
        }
        .padding(12)
        .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Actions

    private func startProblem(at level: MathLevel, subject: MathSubject) {
        selectedLevel = level   // persist so "Solve Another" repeats same level
        let problem = engine.problem(for: level, subject: subject)
        currentProblem = problem
        showHint = false
        hintUsed = false
        showSolution = false
        withAnimation { phase = .solving }
    }

    private func startNewProblem() {
        startProblem(at: selectedLevel, subject: selectedSubject)
    }

    private func handleSuccess(firstTry: Bool) {
        guard let problem = currentProblem else { return }

        let baseSeconds = streaks.recordAttempt(level: problem.level, solvedCorrectly: true, firstTry: firstTry)
        // Apply subject multiplier, then 50% hint penalty if hint was used
        let hintMultiplier: Double = hintUsed ? 0.5 : 1.0
        let seconds = max(30, Int(Double(baseSeconds) * problem.subject.timeMultiplier * hintMultiplier))
        earnedSeconds = seconds

        progress.recordSolve(level: problem.level, subject: problem.subject, firstTry: firstTry)
        progress.recordTimeEarned(seconds)
        screenTime.grantTime(seconds: seconds)

        withAnimation(.spring()) { phase = .success }
    }

    private func handleFailure() {
        streaks.recordAttempt(level: currentProblem?.level ?? .basic, solvedCorrectly: false, firstTry: false)
        progress.resetStreak()
        withAnimation(.spring()) { phase = .failed }
    }

    // MARK: - Helpers

    private var subjectDescription: String {
        switch selectedSubject {
        case .integrals:   return "Calculus I–III integrals, u-sub, IBP, trig sub + applied"
        case .derivatives: return "Power rule, chain rule, product rule, trig"
        case .algebra:     return "Precalc & Algebra 2: logs, systems, polynomials"
        case .satMath:     return "SAT-style arithmetic, geometry, functions"
        case .physics:     return "Levels 1–2: algebra-based  ·  Levels 3–4: AP Physics C"
        }
    }
}
