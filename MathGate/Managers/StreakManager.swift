//
//  StreakManager.swift
//  MathGate
//
//  Created by Levi Monte on 6/23/26.
//

import Foundation
import Combine

/// Tracks the "first-try solve" streak and calculates how much unlock time to award.
class StreakManager: ObservableObject {

    // MARK: - State

    /// How many problems in a row the user solved correctly on their first attempt.
    @Published var consecutiveFirstTry: Int = 0

    /// Whether Double-or-Nothing mode is active (next solve doubles time, or resets streak).
    @Published var doubleOrNothingActive: Bool = false

    /// Result of the most recent solve — used to animate feedback.
    @Published var lastResult: SolveResult? = nil

    enum SolveResult {
        case firstTry(timeSeconds: Int)
        case secondTry(timeSeconds: Int)
        case failed
    }

    // MARK: - Time Calculation

    /// Base time per level (seconds). Also defined on MathLevel, but centralised here
    /// so streak modifiers are applied in one place.
    private func baseTime(for level: MathLevel) -> Int {
        level.baseTimeSeconds
    }

    /// Time earned (seconds) given the current streak and level.
    /// Streak bonus: 1–3 = ×1.0, 4–6 = ×1.5, 7–10 = ×2.0, 11+ = ×2.5
    func timeEarned(for level: MathLevel, firstTry: Bool) -> Int {
        let base = baseTime(for: level)

        // Second-try correct still earns time, but at the base rate and resets streak.
        guard firstTry else { return base }

        let multiplier: Double
        switch consecutiveFirstTry {   // value BEFORE this solve increments it
        case 0..<4:   multiplier = 1.0
        case 4..<7:   multiplier = 1.5
        case 7..<11:  multiplier = 2.0
        default:      multiplier = 2.5
        }

        let earned = Int(Double(base) * multiplier)

        // If Double-or-Nothing is queued, this solve doubles the award.
        if doubleOrNothingActive {
            return earned * 2
        }
        return earned
    }

    // MARK: - Solve Recording

    /// Call after a problem attempt finishes (pass `nil` result if the user gave up).
    /// Returns the number of seconds to grant.
    @discardableResult
    func recordAttempt(level: MathLevel, solvedCorrectly: Bool, firstTry: Bool) -> Int {
        doubleOrNothingActive = false   // DON always consumed on next attempt

        guard solvedCorrectly else {
            consecutiveFirstTry = 0
            lastResult = .failed
            return 0
        }

        let seconds = timeEarned(for: level, firstTry: firstTry)

        if firstTry {
            consecutiveFirstTry += 1
            lastResult = .firstTry(timeSeconds: seconds)
        } else {
            consecutiveFirstTry = 0
            lastResult = .secondTry(timeSeconds: seconds)
        }

        return seconds
    }

    // MARK: - Double or Nothing

    /// Activates the Double-or-Nothing bet.
    /// On the next problem: if correct first try → 2× time. If wrong → 0 time and streak resets.
    func activateDoubleOrNothing() {
        doubleOrNothingActive = true
    }

    func cancelDoubleOrNothing() {
        doubleOrNothingActive = false
    }

    // MARK: - Streak Display Helpers

    var streakBadge: String {
        switch consecutiveFirstTry {
        case 0:      return ""
        case 1..<4:  return "🔥"
        case 4..<7:  return "🔥🔥"
        case 7..<11: return "🔥🔥🔥"
        default:     return "💎"
        }
    }

    var streakMultiplierLabel: String {
        switch consecutiveFirstTry {
        case 0..<4:  return "×1.0"
        case 4..<7:  return "×1.5"
        case 7..<11: return "×2.0"
        default:     return "×2.5"
        }
    }

    var nextMilestone: Int? {
        switch consecutiveFirstTry {
        case 0..<4:  return 4
        case 4..<7:  return 7
        case 7..<11: return 11
        default:     return nil
        }
    }

    // MARK: - Time Formatting

    static func format(seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        if s == 0 { return "\(m) min" }
        return "\(m)m \(s)s"
    }
}
