//
//  UserProgress.swift
//  Integate
//

import Foundation
import Combine

class UserProgress: ObservableObject {

    // MARK: - Published Properties

    @Published var currentLevel: MathLevel {
        didSet { UserDefaults.standard.set(currentLevel.rawValue, forKey: Keys.currentLevel) }
    }
    @Published var xp: Int {
        didSet { UserDefaults.standard.set(xp, forKey: Keys.xp) }
    }
    @Published var currentStreak: Int {
        didSet { UserDefaults.standard.set(currentStreak, forKey: Keys.currentStreak) }
    }
    @Published var longestStreak: Int {
        didSet { UserDefaults.standard.set(longestStreak, forKey: Keys.longestStreak) }
    }
    @Published var dailyStreakDays: Int {
        didSet { UserDefaults.standard.set(dailyStreakDays, forKey: Keys.dailyStreakDays) }
    }
    @Published var lastSolveDate: Date? {
        didSet { UserDefaults.standard.set(lastSolveDate, forKey: Keys.lastSolveDate) }
    }
    @Published var totalSolved: Int {
        didSet { UserDefaults.standard.set(totalSolved, forKey: Keys.totalSolved) }
    }
    @Published var totalFirstTryCorrect: Int {
        didSet { UserDefaults.standard.set(totalFirstTryCorrect, forKey: Keys.totalFirstTryCorrect) }
    }
    @Published var totalTimeEarned: TimeInterval {
        didSet { UserDefaults.standard.set(totalTimeEarned, forKey: Keys.totalTimeEarned) }
    }

    // Per-subject solve counts
    @Published var solvedPerSubject: [String: Int] {
        didSet { UserDefaults.standard.set(solvedPerSubject, forKey: Keys.solvedPerSubject) }
    }
    @Published var firstTryPerSubject: [String: Int] {
        didSet { UserDefaults.standard.set(firstTryPerSubject, forKey: Keys.firstTryPerSubject) }
    }

    // Per-subject unlock: [subject.rawValue: [level.rawValue]]
    @Published private var unlockedPerSubject: [String: [Int]] {
        didSet { UserDefaults.standard.set(unlockedPerSubject, forKey: Keys.unlockedPerSubject) }
    }

    // MARK: - Computed

    static let xpForIntermediate = 50
    static let xpForAdvanced     = 120
    static let xpForExpert       = 200

    // Solve thresholds per subject (independent of global XP)
    private static let solvesForIntermediate = 5
    private static let solvesForAdvanced     = 12
    private static let solvesForExpert       = 20

    /// Union of all unlocked levels (used by ProgressView level dots)
    var unlockedLevels: Set<MathLevel> {
        Set(unlockedPerSubject.values.flatMap { $0 }.compactMap { MathLevel(rawValue: $0) })
    }

    func isUnlocked(_ level: MathLevel, for subject: MathSubject) -> Bool {
        (unlockedPerSubject[subject.rawValue] ?? [1]).contains(level.rawValue)
    }

    /// How many more solves in this subject to unlock the target level.
    func solvesToUnlock(_ level: MathLevel, for subject: MathSubject) -> Int {
        let threshold: Int
        switch level {
        case .basic:        return 0
        case .intermediate: threshold = Self.solvesForIntermediate
        case .advanced:     threshold = Self.solvesForAdvanced
        case .expert:       threshold = Self.solvesForExpert
        }
        let done = solvedPerSubject[subject.rawValue, default: 0]
        return max(0, threshold - done)
    }

    var xpToNextLevel: Int {
        switch currentLevel {
        case .basic:        return Self.xpForIntermediate
        case .intermediate: return Self.xpForAdvanced
        case .advanced:     return Self.xpForExpert
        case .expert:       return .max
        }
    }

    var xpProgress: Double {
        guard xpToNextLevel != .max else { return 1.0 }
        let base: Int
        switch currentLevel {
        case .basic:        base = 0
        case .intermediate: base = Self.xpForIntermediate
        case .advanced:     base = Self.xpForAdvanced
        case .expert:       return 1.0
        }
        let range = xpToNextLevel - base
        return min(Double(xp - base) / Double(range), 1.0)
    }

    var firstTryAccuracy: Double {
        guard totalSolved > 0 else { return 0 }
        return Double(totalFirstTryCorrect) / Double(totalSolved)
    }

    // MARK: - Init

    init() {
        let d = UserDefaults.standard

        solvedPerSubject   = d.dictionary(forKey: Keys.solvedPerSubject)   as? [String: Int] ?? [:]
        firstTryPerSubject = d.dictionary(forKey: Keys.firstTryPerSubject) as? [String: Int] ?? [:]

        // Load per-subject unlocks; default every subject to Basic only
        if let saved = d.dictionary(forKey: Keys.unlockedPerSubject) as? [String: [Int]], !saved.isEmpty {
            unlockedPerSubject = saved
        } else {
            unlockedPerSubject = Dictionary(
                uniqueKeysWithValues: MathSubject.allCases.map { ($0.rawValue, [1]) }
            )
        }

        let levelRaw = d.integer(forKey: Keys.currentLevel)
        currentLevel         = MathLevel(rawValue: levelRaw) ?? .basic
        xp                   = d.integer(forKey: Keys.xp)
        currentStreak        = d.integer(forKey: Keys.currentStreak)
        longestStreak        = d.integer(forKey: Keys.longestStreak)
        dailyStreakDays      = d.integer(forKey: Keys.dailyStreakDays)
        lastSolveDate        = d.object(forKey: Keys.lastSolveDate) as? Date
        totalSolved          = d.integer(forKey: Keys.totalSolved)
        totalFirstTryCorrect = d.integer(forKey: Keys.totalFirstTryCorrect)
        totalTimeEarned      = d.double(forKey: Keys.totalTimeEarned)
    }

    // MARK: - Update

    func recordSolve(level: MathLevel, subject: MathSubject = .integrals, firstTry: Bool) {
        solvedPerSubject[subject.rawValue, default: 0] += 1
        if firstTry { firstTryPerSubject[subject.rawValue, default: 0] += 1 }

        totalSolved += 1
        if firstTry {
            totalFirstTryCorrect += 1
            currentStreak += 1
            longestStreak = max(longestStreak, currentStreak)
        } else {
            currentStreak = 0
        }

        let today = Calendar.current.startOfDay(for: Date())
        if let last = lastSolveDate {
            let diff = Calendar.current.dateComponents(
                [.day], from: Calendar.current.startOfDay(for: last), to: today
            ).day ?? 0
            if diff == 1 { dailyStreakDays += 1 }
            else if diff > 1 { dailyStreakDays = 1 }
        } else {
            dailyStreakDays = 1
        }
        lastSolveDate = Date()

        let bonus = firstTry ? 1.5 : 1.0
        xp += Int(Double(level.xpReward) * bonus)

        checkSubjectLevelUp(for: subject)
        checkGlobalLevelUp()
    }

    /// Unlock higher levels independently per subject based on solve count.
    private func checkSubjectLevelUp(for subject: MathSubject) {
        let count = solvedPerSubject[subject.rawValue, default: 0]
        var levels = Set(unlockedPerSubject[subject.rawValue] ?? [1])
        if count >= Self.solvesForIntermediate { levels.insert(2) }
        if count >= Self.solvesForAdvanced     { levels.insert(3) }
        if count >= Self.solvesForExpert       { levels.insert(4) }
        unlockedPerSubject[subject.rawValue] = Array(levels)
    }

    /// Global XP level (used for "Solve Another" default and the XP bar).
    private func checkGlobalLevelUp() {
        if xp >= Self.xpForIntermediate, currentLevel == .basic        { currentLevel = .intermediate }
        else if xp >= Self.xpForAdvanced, currentLevel == .intermediate { currentLevel = .advanced }
        else if xp >= Self.xpForExpert,   currentLevel == .advanced     { currentLevel = .expert }
    }

    func recordTimeEarned(_ seconds: Int) { totalTimeEarned += TimeInterval(seconds) }
    func resetStreak() { currentStreak = 0 }

    func resetAll() {
        totalSolved          = 0
        totalFirstTryCorrect = 0
        totalTimeEarned      = 0
        xp                   = 0
        currentLevel         = .basic
        currentStreak        = 0
        longestStreak        = 0
        dailyStreakDays       = 0
        lastSolveDate        = nil
        UserDefaults.standard.removeObject(forKey: Keys.lastSolveDate)
        solvedPerSubject     = [:]
        firstTryPerSubject   = [:]
        unlockedPerSubject   = Dictionary(
            uniqueKeysWithValues: MathSubject.allCases.map { ($0.rawValue, [1]) }
        )
    }

    // MARK: - Per-Subject Helpers

    func solved(for subject: MathSubject) -> Int  { solvedPerSubject[subject.rawValue] ?? 0 }
    func firstTry(for subject: MathSubject) -> Int { firstTryPerSubject[subject.rawValue] ?? 0 }
    func accuracy(for subject: MathSubject) -> Double {
        let s = solved(for: subject); guard s > 0 else { return 0 }
        return Double(firstTry(for: subject)) / Double(s)
    }

    // MARK: - Keys

    private enum Keys {
        static let currentLevel         = "mg_currentLevel"
        static let xp                   = "mg_xp"
        static let currentStreak        = "mg_currentStreak"
        static let longestStreak        = "mg_longestStreak"
        static let dailyStreakDays      = "mg_dailyStreakDays"
        static let lastSolveDate        = "mg_lastSolveDate"
        static let totalSolved          = "mg_totalSolved"
        static let totalFirstTryCorrect = "mg_totalFirstTryCorrect"
        static let totalTimeEarned      = "mg_totalTimeEarned"
        static let unlockedPerSubject   = "mg_unlockedPerSubject"
        static let solvedPerSubject     = "mg_solvedPerSubject"
        static let firstTryPerSubject   = "mg_firstTryPerSubject"
    }
}
