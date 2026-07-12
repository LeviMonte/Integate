//
//  MathProblem.swift
//  MathGate
//

import Foundation
import SwiftUI

// MARK: - MathSubject

enum MathSubject: String, CaseIterable, Codable {
    case integrals   = "Integrals"
    case derivatives = "Derivatives"
    case algebra     = "Algebra"
    case satMath     = "SAT Math"
    case physics     = "Physics"

    var shortName: String {
        switch self {
        case .satMath: return "SAT"
        default:       return rawValue
        }
    }

    var icon: String {
        switch self {
        case .integrals:   return "∫"
        case .derivatives: return "∂"
        case .algebra:     return "𝑥²"
        case .satMath:     return "📐"
        case .physics:     return "⚛️"
        }
    }

    /// Multiplier applied to level base time for this subject.
    var timeMultiplier: Double {
        switch self {
        case .algebra:     return 0.5
        case .satMath:     return 0.6
        case .derivatives: return 0.75
        case .physics:     return 0.9
        case .integrals:   return 1.0
        }
    }

    var color: Color {
        switch self {
        case .integrals:   return .indigo
        case .derivatives: return .blue
        case .algebra:     return .green
        case .satMath:     return .orange
        case .physics:     return .cyan
        }
    }
}

// MARK: - MathCategory

enum MathCategory: String, CaseIterable, Codable {
    case integral   = "Integral"
    case derivative = "Derivative"
    case algebra    = "Algebra"
    case applied    = "Applied"
}

// MARK: - MathLevel

enum MathLevel: Int, CaseIterable, Comparable, Codable {
    case basic        = 1
    case intermediate = 2
    case advanced     = 3
    case expert       = 4

    static func < (lhs: MathLevel, rhs: MathLevel) -> Bool { lhs.rawValue < rhs.rawValue }

    var displayName: String {
        switch self {
        case .basic:        return "Basic"
        case .intermediate: return "Intermediate"
        case .advanced:     return "Advanced"
        case .expert:       return "Expert"
        }
    }

    var emoji: String {
        switch self {
        case .basic:        return "🌱"
        case .intermediate: return "🔥"
        case .advanced:     return "⚡️"
        case .expert:       return "💎"
        }
    }

    /// Base time (seconds) before subject multiplier and streak multiplier.
    var baseTimeSeconds: Int {
        switch self {
        case .basic:        return 180
        case .intermediate: return 300
        case .advanced:     return 480
        case .expert:       return 720
        }
    }

    var xpReward: Int {
        switch self {
        case .basic:        return 10
        case .intermediate: return 25
        case .advanced:     return 50
        case .expert:       return 100
        }
    }
}

// MARK: - AnswerType

enum AnswerType {
    case integer(Int)
    case fraction(Int, Int)
    case decimal(String)

    var inputDigits: [String] {
        switch self {
        case .integer(let n):           return String(abs(n)).map { String($0) }
        case .fraction(let num, let den): return (String(abs(num)) + String(abs(den))).map { String($0) }
        case .decimal(let s):           return s.filter { $0.isNumber }.map { String($0) }
        }
    }

    var digitBudget: Int { inputDigits.count * 2 }

    var displayString: String {
        switch self {
        case .integer(let n):             return String(n)
        case .fraction(let num, let den): return "\(num)/\(den)"
        case .decimal(let s):             return s
        }
    }

    var isNegative: Bool {
        switch self {
        case .integer(let n):    return n < 0
        case .fraction(let n,_): return n < 0
        case .decimal(let s):    return s.hasPrefix("-")
        }
    }
}

// MARK: - MathProblem

struct MathProblem: Identifiable {
    let id = UUID()

    let displayPrimary: String  // expression / question text
    let lowerBound: String      // integral lower bound  OR  evaluation point for derivatives
    let upperBound: String      // integral upper bound  OR  "" for other subjects

    let answerType: AnswerType
    let level: MathLevel
    let category: MathCategory
    let technique: String
    let explanation: String
    let hint: String
    let subject: MathSubject

    init(
        displayPrimary: String,
        lowerBound: String,
        upperBound: String,
        answerType: AnswerType,
        level: MathLevel,
        category: MathCategory,
        technique: String,
        explanation: String,
        hint: String,
        subject: MathSubject = .integrals   // default keeps existing 114 problems unchanged
    ) {
        self.displayPrimary  = displayPrimary
        self.lowerBound      = lowerBound
        self.upperBound      = upperBound
        self.answerType      = answerType
        self.level           = level
        self.category        = category
        self.technique       = technique
        self.explanation     = explanation
        self.hint            = hint
        self.subject         = subject
    }

    var answerDisplay: String  { answerType.displayString }
    var inputDigits:  [String] { answerType.inputDigits }
    var digitBudget:  Int      { answerType.digitBudget }
    var isNegative:   Bool     { answerType.isNegative }
    var fullDisplay:  String   { "\(displayPrimary)  [\(lowerBound) → \(upperBound)]" }
}
