//
//  ProblemCardView.swift
//  MathGate
//

import SwiftUI

/// Renders a math problem card that adapts its display to the problem's subject.
/// — Integrals: full ∫ notation with bounds
/// — Derivatives: styled "f(x) = …  f'(x) = ?" with evaluation point
/// — Algebra / SAT Math / Word Problems: plain text question card
struct ProblemCardView: View {
    let problem: MathProblem

    var body: some View {
        VStack(spacing: 4) {
            // Header row
            HStack {
                Label(problem.level.displayName, systemImage: "chart.bar.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(levelColor, in: Capsule())

                Spacer()

                Text(problem.technique)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider().padding(.vertical, 6)

            // Subject-aware body
            switch problem.subject {
            case .integrals:
                // Applied/word problems are in the integrals bank but render as plain text
                if problem.category == .applied {
                    PlainTextCardBody(problem: problem)
                        .padding(.vertical, 8)
                } else {
                    IntegralNotationView(
                        integrand: integrandString,
                        lowerBound: problem.lowerBound,
                        upperBound: problem.upperBound
                    )
                    .padding(.vertical, 8)
                }

            case .derivatives:
                DerivativeCardBody(problem: problem)
                    .padding(.vertical, 8)

            case .algebra, .satMath, .physics:
                PlainTextCardBody(problem: problem)
                    .padding(.vertical, 8)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(levelColor.opacity(0.3), lineWidth: 1.5)
        )
    }

    private var integrandString: String {
        problem.displayPrimary
            .replacingOccurrences(of: "∫ ", with: "")
            .replacingOccurrences(of: "∫", with: "")
            .trimmingCharacters(in: .whitespaces)
    }

    private var levelColor: Color {
        switch problem.level {
        case .basic:        return .green
        case .intermediate: return .orange
        case .advanced:     return .pink
        case .expert:       return .purple
        }
    }
}

// MARK: - Integral Notation

struct IntegralNotationView: View {
    let integrand: String
    let lowerBound: String
    let upperBound: String

    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            VStack(spacing: 0) {
                Text(upperBound)
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .foregroundStyle(.secondary)
                Text("∫")
                    .font(.system(size: 52, weight: .ultraLight, design: .serif))
                    .foregroundStyle(.primary)
                Text(lowerBound)
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .foregroundStyle(.secondary)
            }
            Text(integrand)
                .font(.system(size: 24, weight: .regular, design: .serif))
                .foregroundStyle(.primary)
                .padding(.leading, 2)
        }
    }
}

// MARK: - Derivative Card Body

struct DerivativeCardBody: View {
    let problem: MathProblem

    var body: some View {
        VStack(spacing: 12) {
            Text(problem.displayPrimary)
                .font(.system(size: 22, weight: .regular, design: .serif))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            if !problem.lowerBound.isEmpty {
                Text("Find f ′(\(evalPoint))")
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // Extract the numeric/symbolic part from "x = 3" → "3"
    private var evalPoint: String {
        problem.lowerBound
            .replacingOccurrences(of: "x = ", with: "")
            .replacingOccurrences(of: "x=", with: "")
    }
}

// MARK: - Plain Text Card Body (Algebra / SAT / Word)

struct PlainTextCardBody: View {
    let problem: MathProblem

    var body: some View {
        VStack(spacing: 12) {
            Text(problem.displayPrimary)
                .font(.system(size: 19, weight: .regular, design: .default))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            if !problem.lowerBound.isEmpty && problem.lowerBound != "=" {
                Text(problem.lowerBound + " ?")
                    .font(.system(size: 15, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        ProblemCardView(problem: MathProblem(
            displayPrimary: "∫ x dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(2),
            level: .basic, category: .integral,
            technique: "Power Rule",
            explanation: "∫x dx = x²/2. At 2: 2. Answer = 2.",
            hint: "Use the power rule.",
            subject: .integrals
        ))
        ProblemCardView(problem: MathProblem(
            displayPrimary: "f(x) = x²",
            lowerBound: "x = 3", upperBound: "",
            answerType: .integer(6),
            level: .basic, category: .derivative,
            technique: "Power Rule",
            explanation: "f'(x) = 2x. f'(3) = 6.",
            hint: "f'(xⁿ) = nxⁿ⁻¹.",
            subject: .derivatives
        ))
        ProblemCardView(problem: MathProblem(
            displayPrimary: "Solve: 2x + 5 = 13",
            lowerBound: "x =", upperBound: "",
            answerType: .integer(4),
            level: .basic, category: .algebra,
            technique: "Linear Equation",
            explanation: "2x = 8, x = 4.",
            hint: "Subtract 5, divide by 2.",
            subject: .algebra
        ))
    }
    .padding()
}
