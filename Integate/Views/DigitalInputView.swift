//
//  DigitalInputView.swift
//  Integate
//

import SwiftUI

// MARK: - DigitInputView
//
// Core mechanic:
//   • Answer has N digits → N blank slots at the top
//   • Budget = 2N key presses
//   • Each correct digit fills the next blank
//   • Wrong digit costs 1 press without advancing
//   • For negative answers: user must toggle sign (±) before last digit
//   • Budget exhausted → failure; all slots filled with correct sign → success

struct DigitInputView: View {
    let problem: MathProblem
    var onSuccess: (Bool) -> Void   // passes firstTry: Bool
    var onFailure: () -> Void

    // ── State ──────────────────────────────────────────────
    @State private var filledDigits: [String?]
    @State private var pressesUsed: Int = 0
    @State private var shakeSlot: Int? = nil
    @State private var firstTry: Bool = true
    @State private var wrongPressSet: Set<Int> = []

    // Sign handling for negative-answer problems
    @State private var userIsNegative: Bool = false
    @State private var signOffset: CGFloat = 0   // for shake animation

    // Derived
    private var expectedDigits: [String] { problem.inputDigits }
    private var budget: Int               { problem.digitBudget }
    private var currentSlot: Int          { filledDigits.firstIndex(where: { $0 == nil }) ?? expectedDigits.count }
    private var pressesLeft: Int          { budget - pressesUsed }
    private var isDone: Bool              { currentSlot >= expectedDigits.count }

    init(problem: MathProblem, onSuccess: @escaping (Bool) -> Void, onFailure: @escaping () -> Void) {
        self.problem   = problem
        self.onSuccess = onSuccess
        self.onFailure = onFailure
        _filledDigits  = State(initialValue: Array(repeating: nil, count: problem.inputDigits.count))
    }

    // ── Body ───────────────────────────────────────────────

    var body: some View {
        VStack(spacing: 24) {
            answerSlotsView
            budgetView
            numpadView
        }
    }

    // MARK: - Answer Slots

    private var answerSlotsView: some View {
        HStack(spacing: 10) {
            // Interactive sign toggle — only shown for negative-answer problems
            if problem.isNegative {
                signToggleButton
            }

            // Digit slots
            ForEach(0..<expectedDigits.count, id: \.self) { i in
                // Fraction separator
                if case .fraction(let n, _) = problem.answerType,
                   i == String(abs(n)).count {
                    Text("/")
                        .font(.system(size: 24, weight: .light, design: .monospaced))
                        .foregroundStyle(.secondary)
                }

                DigitSlotView(
                    filled: filledDigits[i],
                    isCurrent: i == currentSlot,
                    shake: shakeSlot == i
                )
            }
        }
    }

    private var signToggleButton: some View {
        Button {
            withAnimation(.spring(response: 0.25)) {
                userIsNegative.toggle()
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(userIsNegative ? Color.indigo.opacity(0.15) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(
                                userIsNegative ? Color.indigo : Color.gray.opacity(0.35),
                                lineWidth: userIsNegative ? 2 : 1
                            )
                    )
                    .frame(width: 48, height: 60)

                Text(userIsNegative ? "−" : "+")
                    .font(.system(size: 26, weight: .light, design: .monospaced))
                    .foregroundStyle(userIsNegative ? Color.indigo : Color.secondary)
            }
        }
        .buttonStyle(.plain)
        .offset(x: signOffset)
    }

    // MARK: - Budget Display

    private var budgetView: some View {
        HStack(spacing: 6) {
            ForEach(0..<budget, id: \.self) { i in
                Circle()
                    .fill(
                        i < pressesUsed
                            ? (wrongPressSet.contains(i) ? Color.red.opacity(0.7) : Color.indigo)
                            : Color.gray.opacity(0.25)
                    )
                    .frame(width: 8, height: 8)
            }
            Spacer()
            Text("\(pressesLeft) press\(pressesLeft == 1 ? "" : "es") left")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Numpad

    private var numpadView: some View {
        VStack(spacing: 12) {
            ForEach([[1,2,3],[4,5,6],[7,8,9]], id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { digit in
                        NumpadButton(digit: "\(digit)") { handlePress("\(digit)") }
                    }
                }
            }

            // Bottom row: ± toggle (if negative problem) + 0
            if problem.isNegative {
                HStack(spacing: 12) {
                    // ± button (free — no budget cost)
                    Button {
                        withAnimation(.spring(response: 0.25)) { userIsNegative.toggle() }
                    } label: {
                        Text("±")
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .frame(width: 76, height: 56)
                            .background(
                                userIsNegative ? Color.indigo.opacity(0.2) : Color.gray.opacity(0.1),
                                in: RoundedRectangle(cornerRadius: 14)
                            )
                            .foregroundStyle(userIsNegative ? Color.indigo : Color.primary)
                    }
                    .buttonStyle(.plain)

                    NumpadButton(digit: "0") { handlePress("0") }

                    // Balance spacer
                    Color.clear.frame(width: 76, height: 56)
                }
                // Hint label for negative problems
                Text("Tap ± to set the sign, then enter digits")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 12) {
                    NumpadButton(digit: "0") { handlePress("0") }
                }
            }
        }
    }

    // MARK: - Key Press Logic

    private func handlePress(_ digit: String) {
        guard !isDone, pressesLeft > 0 else { return }

        let expected = expectedDigits[currentSlot]
        let isLastSlot = (currentSlot + 1 >= expectedDigits.count)

        pressesUsed += 1

        if digit == expected {
            // Digit is right — on the last slot also verify sign for negative problems
            if isLastSlot && problem.isNegative && userIsNegative != problem.isNegative {
                // Sign mismatch on final slot
                firstTry = false
                wrongPressSet.insert(pressesUsed - 1)
                shakeSignIndicator()
                if pressesUsed >= budget {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { onFailure() }
                }
            } else {
                // Correct!
                withAnimation(.spring(response: 0.3)) {
                    filledDigits[currentSlot] = digit
                }
                if isLastSlot {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { onSuccess(firstTry) }
                }
            }
        } else {
            // Wrong digit
            firstTry = false
            wrongPressSet.insert(pressesUsed - 1)
            let slot = currentSlot
            shakeSlot = slot
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { shakeSlot = nil }
            if pressesUsed >= budget {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { onFailure() }
            }
        }
    }

    private func shakeSignIndicator() {
        withAnimation(.easeInOut(duration: 0.07).repeatCount(4, autoreverses: true)) {
            signOffset = 6
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation { signOffset = 0 }
        }
    }
}

// MARK: - DigitSlotView

struct DigitSlotView: View {
    let filled: String?
    let isCurrent: Bool
    let shake: Bool

    @State private var offset: CGFloat = 0

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(filled != nil ? Color.indigo.opacity(0.15) : Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            isCurrent ? Color.indigo : (filled != nil ? Color.indigo.opacity(0.4) : Color.gray.opacity(0.3)),
                            lineWidth: isCurrent ? 2 : 1
                        )
                )
                .frame(width: 48, height: 60)

            if let d = filled {
                Text(d)
                    .font(.system(size: 28, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.indigo)
                    .transition(.scale.combined(with: .opacity))
            } else if isCurrent {
                Rectangle()
                    .fill(Color.indigo)
                    .frame(width: 2, height: 28)
                    .opacity(0.7)
            }
        }
        .offset(x: offset)
        .onChange(of: shake) { _, isShaking in
            guard isShaking else { return }
            withAnimation(.easeInOut(duration: 0.07).repeatCount(4, autoreverses: true)) {
                offset = 6
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation { offset = 0 }
            }
        }
    }
}

// MARK: - NumpadButton

struct NumpadButton: View {
    let digit: String
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: {
            withAnimation(.easeIn(duration: 0.05)) { pressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation { pressed = false }
                action()
            }
        }) {
            Text(digit)
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .frame(width: 76, height: 56)
                .background(pressed ? Color.indigo.opacity(0.2) : Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
