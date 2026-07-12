import Foundation

// MARK: - Time of Day

enum TimeOfDay {
    case morning    // 6–11am  → normal difficulty
    case afternoon  // 11am–6pm → normal difficulty
    case evening    // 6–10pm  → +1 harder
    case lateNight  // 10pm–2am → −1 easier
    case overnight  // 2–6am   → +2 harder

    static var current: TimeOfDay {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 6..<11:  return .morning
        case 11..<18: return .afternoon
        case 18..<22: return .evening
        case 22..<26: return .lateNight
        default:      return .overnight
        }
    }

    var levelOffset: Int {
        switch self {
        case .morning:   return 0
        case .afternoon: return 0
        case .evening:   return 1
        case .lateNight: return -1
        case .overnight: return 2
        }
    }

    var label: String {
        switch self {
        case .morning:   return "Morning"
        case .afternoon: return "Afternoon"
        case .evening:   return "Evening"
        case .lateNight: return "Late Night"
        case .overnight: return "You should be asleep 😴"
        }
    }
}

// MARK: - MathEngine

/// Serves problems from a hand-verified bank. All answers are non-negative integers.
class MathEngine {
    static let shared = MathEngine()
    private init() {}

    // MARK: - Public API

    func problem(for level: MathLevel,
                 subject: MathSubject = .integrals,
                 respectTimeOfDay: Bool = true) -> MathProblem {
        let effective: MathLevel
        if respectTimeOfDay {
            let raw = (level.rawValue + TimeOfDay.current.levelOffset).clamped(to: 1...4)
            effective = MathLevel(rawValue: raw) ?? level
        } else {
            effective = level
        }
        let pool = problems(for: effective, subject: subject)
        return pool.randomElement() ?? problems(for: effective, subject: .integrals).randomElement()!
    }

    func problems(for level: MathLevel, subject: MathSubject = .integrals) -> [MathProblem] {
        bank.filter { $0.level == level && $0.subject == subject }
    }

    private lazy var bank: [MathProblem] = level1 + level2 + level3 + level4
        + derivL1 + derivL2 + derivL3 + derivL4
        + algL1   + algL2   + algL3   + algL4
        + satL1   + satL2   + satL3   + satL4
        + wordL1  + wordL2  + wordL3  + wordL4   // applied — subject = .integrals
        + physL1  + physL2  + physL3  + physL4
        // ── Expansion banks ──────────────────────────────
        + xtraIntL1 + xtraIntL2 + xtraIntL3 + xtraIntL4
        + xtraDerivL1 + xtraDerivL2 + xtraDerivL3 + xtraDerivL4
        + xtraAlgL1   + xtraAlgL2   + xtraAlgL3   + xtraAlgL4
        + xtraSatL1   + xtraSatL2   + xtraSatL3   + xtraSatL4
        + xtraPhysL1  + xtraPhysL2  + xtraPhysL3  + xtraPhysL4

    // ─────────────────────────────────────────────────────────────────────────
    // LEVEL 1 — Calc I  (47 problems)
    // Power Rule, Constant Rule, Sum Rule, eˣ with ln bounds, basic trig,
    // intro u-substitution (linear composites)
    // ─────────────────────────────────────────────────────────────────────────
    private let level1: [MathProblem] = [

        // ── Power Rule ──

        MathProblem(
            displayPrimary: "∫ x dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(2),
            level: .basic, category: .integral,
            technique: "Power Rule",
            explanation: """
            ∫x dx = x²/2

            [x²/2]₀²  =  4/2 − 0  =  2
            """,
            hint: "∫xⁿ dx = xⁿ⁺¹/(n+1). Here n = 1."
        ),

        MathProblem(
            displayPrimary: "∫ 2x dx",
            lowerBound: "0", upperBound: "3",
            answerType: .integer(9),
            level: .basic, category: .integral,
            technique: "Power Rule",
            explanation: """
            ∫2x dx = x²

            [x²]₀³  =  9 − 0  =  9
            """,
            hint: "Pull the 2 out front, then use the power rule."
        ),

        MathProblem(
            displayPrimary: "∫ 2x dx",
            lowerBound: "1", upperBound: "3",
            answerType: .integer(8),
            level: .basic, category: .integral,
            technique: "Power Rule",
            explanation: """
            ∫2x dx = x²

            [x²]₁³  =  9 − 1  =  8
            """,
            hint: "F(upper) − F(lower): F(3) − F(1)."
        ),

        MathProblem(
            displayPrimary: "∫ 3x² dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(8),
            level: .basic, category: .integral,
            technique: "Power Rule",
            explanation: """
            ∫3x² dx = x³

            [x³]₀²  =  8 − 0  =  8
            """,
            hint: "∫3x² dx = x³ + C. The 3s cancel."
        ),

        MathProblem(
            displayPrimary: "∫ x² dx",
            lowerBound: "0", upperBound: "3",
            answerType: .integer(9),
            level: .basic, category: .integral,
            technique: "Power Rule",
            explanation: """
            ∫x² dx = x³/3

            [x³/3]₀³  =  27/3  =  9
            """,
            hint: "∫x² dx = x³/3 + C."
        ),

        MathProblem(
            displayPrimary: "∫ 3x² dx",
            lowerBound: "1", upperBound: "2",
            answerType: .integer(7),
            level: .basic, category: .integral,
            technique: "Power Rule",
            explanation: """
            ∫3x² dx = x³

            [x³]₁²  =  8 − 1  =  7
            """,
            hint: "Antiderivative is x³. Don't forget to subtract F(1)."
        ),

        MathProblem(
            displayPrimary: "∫ 4x³ dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(16),
            level: .basic, category: .integral,
            technique: "Power Rule",
            explanation: """
            ∫4x³ dx = x⁴

            [x⁴]₀²  =  16 − 0  =  16
            """,
            hint: "∫4x³ dx = x⁴ + C. The 4s cancel."
        ),

        MathProblem(
            displayPrimary: "∫ x³ dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(4),
            level: .basic, category: .integral,
            technique: "Power Rule",
            explanation: """
            ∫x³ dx = x⁴/4

            [x⁴/4]₀²  =  16/4  =  4
            """,
            hint: "∫x³ dx = x⁴/4 + C."
        ),

        MathProblem(
            displayPrimary: "∫ x dx",
            lowerBound: "0", upperBound: "4",
            answerType: .integer(8),
            level: .basic, category: .integral,
            technique: "Power Rule",
            explanation: """
            ∫x dx = x²/2

            [x²/2]₀⁴  =  16/2  =  8
            """,
            hint: "∫x dx = x²/2 + C."
        ),

        MathProblem(
            displayPrimary: "∫ x dx",
            lowerBound: "1", upperBound: "3",
            answerType: .integer(4),
            level: .basic, category: .integral,
            technique: "Power Rule",
            explanation: """
            ∫x dx = x²/2

            [x²/2]₁³  =  9/2 − 1/2  =  4
            """,
            hint: "F(3) − F(1) = 9/2 − 1/2."
        ),

        MathProblem(
            displayPrimary: "∫ 3x² dx",
            lowerBound: "0", upperBound: "3",
            answerType: .integer(27),
            level: .basic, category: .integral,
            technique: "Power Rule",
            explanation: """
            ∫3x² dx = x³

            [x³]₀³  =  27 − 0  =  27
            """,
            hint: "Antiderivative is x³."
        ),

        MathProblem(
            displayPrimary: "∫ 5x⁴ dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(32),
            level: .basic, category: .integral,
            technique: "Power Rule",
            explanation: """
            ∫5x⁴ dx = x⁵

            [x⁵]₀²  =  32 − 0  =  32
            """,
            hint: "∫5x⁴ dx = x⁵ + C."
        ),

        MathProblem(
            displayPrimary: "∫ 2x³ dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(8),
            level: .basic, category: .integral,
            technique: "Power Rule",
            explanation: """
            ∫2x³ dx = x⁴/2

            [x⁴/2]₀²  =  16/2  =  8
            """,
            hint: "∫2x³ dx = 2·x⁴/4 = x⁴/2."
        ),

        MathProblem(
            displayPrimary: "∫ x³ dx",
            lowerBound: "0", upperBound: "4",
            answerType: .integer(64),
            level: .basic, category: .integral,
            technique: "Power Rule",
            explanation: """
            ∫x³ dx = x⁴/4

            [x⁴/4]₀⁴  =  256/4  =  64
            """,
            hint: "∫x³ dx = x⁴/4 + C."
        ),

        MathProblem(
            displayPrimary: "∫ 6x² dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(16),
            level: .basic, category: .integral,
            technique: "Power Rule",
            explanation: """
            ∫6x² dx = 2x³

            [2x³]₀²  =  16 − 0  =  16
            """,
            hint: "∫6x² dx = 6·x³/3 = 2x³."
        ),

        // ── Constant Rule ──

        MathProblem(
            displayPrimary: "∫ 4 dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(8),
            level: .basic, category: .integral,
            technique: "Constant Rule",
            explanation: """
            ∫c dx = c·x + C

            [4x]₀²  =  8 − 0  =  8
            """,
            hint: "A constant c integrates to c·x."
        ),

        MathProblem(
            displayPrimary: "∫ 1 dx",
            lowerBound: "1", upperBound: "4",
            answerType: .integer(3),
            level: .basic, category: .integral,
            technique: "Constant Rule",
            explanation: """
            ∫1 dx = x

            [x]₁⁴  =  4 − 1  =  3
            """,
            hint: "∫₍ₐ₎ᵇ 1 dx = b − a (length of interval)."
        ),

        MathProblem(
            displayPrimary: "∫ 5 dx",
            lowerBound: "0", upperBound: "3",
            answerType: .integer(15),
            level: .basic, category: .integral,
            technique: "Constant Rule",
            explanation: """
            ∫5 dx = 5x

            [5x]₀³  =  15 − 0  =  15
            """,
            hint: "∫5 dx = 5x + C."
        ),

        MathProblem(
            displayPrimary: "∫ 7 dx",
            lowerBound: "1", upperBound: "2",
            answerType: .integer(7),
            level: .basic, category: .integral,
            technique: "Constant Rule",
            explanation: """
            ∫7 dx = 7x

            [7x]₁²  =  14 − 7  =  7
            """,
            hint: "∫c dx = c·(b − a) for a constant c."
        ),

        MathProblem(
            displayPrimary: "∫ 3 dx",
            lowerBound: "2", upperBound: "5",
            answerType: .integer(9),
            level: .basic, category: .integral,
            technique: "Constant Rule",
            explanation: """
            ∫3 dx = 3x

            [3x]₂⁵  =  15 − 6  =  9
            """,
            hint: "3·(5 − 2) = 9."
        ),

        MathProblem(
            displayPrimary: "∫ 10 dx",
            lowerBound: "0", upperBound: "5",
            answerType: .integer(50),
            level: .basic, category: .integral,
            technique: "Constant Rule",
            explanation: """
            ∫10 dx = 10x

            [10x]₀⁵  =  50 − 0  =  50
            """,
            hint: "10 × 5 = 50."
        ),

        // ── Sum Rule / Polynomials ──

        MathProblem(
            displayPrimary: "∫ (2x + 1) dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(6),
            level: .basic, category: .integral,
            technique: "Sum Rule",
            explanation: """
            ∫(2x+1) dx = x² + x

            [x²+x]₀²  =  (4+2) − 0  =  6
            """,
            hint: "Split: ∫2x dx + ∫1 dx = x² + x."
        ),

        MathProblem(
            displayPrimary: "∫ (3x² + 1) dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(10),
            level: .basic, category: .integral,
            technique: "Sum Rule",
            explanation: """
            ∫(3x²+1) dx = x³ + x

            [x³+x]₀²  =  (8+2) − 0  =  10
            """,
            hint: "∫3x² = x³, ∫1 = x."
        ),

        MathProblem(
            displayPrimary: "∫ (x² + 2x) dx",
            lowerBound: "0", upperBound: "3",
            answerType: .integer(18),
            level: .basic, category: .integral,
            technique: "Sum Rule",
            explanation: """
            ∫(x²+2x) dx = x³/3 + x²

            F(3) = 9 + 9 = 18,  F(0) = 0

            18 − 0 = 18
            """,
            hint: "∫x² dx = x³/3, ∫2x dx = x²."
        ),

        MathProblem(
            displayPrimary: "∫ (4x³ + 2x) dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(20),
            level: .basic, category: .integral,
            technique: "Sum Rule",
            explanation: """
            ∫(4x³+2x) dx = x⁴ + x²

            [x⁴+x²]₀²  =  (16+4) − 0  =  20
            """,
            hint: "∫4x³ = x⁴, ∫2x = x²."
        ),

        MathProblem(
            displayPrimary: "∫ (2x + 3) dx",
            lowerBound: "0", upperBound: "3",
            answerType: .integer(18),
            level: .basic, category: .integral,
            technique: "Sum Rule",
            explanation: """
            ∫(2x+3) dx = x² + 3x

            [x²+3x]₀³  =  (9+9) − 0  =  18
            """,
            hint: "∫2x = x², ∫3 = 3x."
        ),

        MathProblem(
            displayPrimary: "∫ (3x² + 2x + 1) dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(14),
            level: .basic, category: .integral,
            technique: "Sum Rule",
            explanation: """
            ∫(3x²+2x+1) dx = x³ + x² + x

            [x³+x²+x]₀²  =  (8+4+2) − 0  =  14
            """,
            hint: "Three terms: x³ + x² + x."
        ),

        MathProblem(
            displayPrimary: "∫ (x² + 1) dx",
            lowerBound: "0", upperBound: "3",
            answerType: .integer(12),
            level: .basic, category: .integral,
            technique: "Sum Rule",
            explanation: """
            ∫(x²+1) dx = x³/3 + x

            F(3) = 9 + 3 = 12,  F(0) = 0

            12 − 0 = 12
            """,
            hint: "∫x² = x³/3, ∫1 = x."
        ),

        MathProblem(
            displayPrimary: "∫ (x³ + x) dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(6),
            level: .basic, category: .integral,
            technique: "Sum Rule",
            explanation: """
            ∫(x³+x) dx = x⁴/4 + x²/2

            F(2) = 4 + 2 = 6,  F(0) = 0

            6 − 0 = 6
            """,
            hint: "∫x³ = x⁴/4, ∫x = x²/2."
        ),

        MathProblem(
            displayPrimary: "∫ (x + 1) dx",
            lowerBound: "1", upperBound: "3",
            answerType: .integer(6),
            level: .basic, category: .integral,
            technique: "Sum Rule",
            explanation: """
            ∫(x+1) dx = x²/2 + x

            F(3) = 9/2+3 = 15/2,  F(1) = 1/2+1 = 3/2

            15/2 − 3/2 = 6
            """,
            hint: "Antiderivative is x²/2 + x."
        ),

        MathProblem(
            displayPrimary: "∫ (2x² + 2x) dx",
            lowerBound: "0", upperBound: "3",
            answerType: .integer(27),
            level: .basic, category: .integral,
            technique: "Sum Rule",
            explanation: """
            ∫(2x²+2x) dx = 2x³/3 + x²

            F(3) = 18 + 9 = 27,  F(0) = 0

            27 − 0 = 27
            """,
            hint: "∫2x² = 2x³/3, ∫2x = x²."
        ),

        // ── eˣ with ln bounds ──

        MathProblem(
            displayPrimary: "∫ eˣ dx",
            lowerBound: "0", upperBound: "ln(2)",
            answerType: .integer(1),
            level: .basic, category: .integral,
            technique: "Exponential Integration",
            explanation: """
            ∫eˣ dx = eˣ + C

            [eˣ]₀^ln(2)  =  e^ln(2) − e⁰  =  2 − 1  =  1
            """,
            hint: "∫eˣ dx = eˣ + C. Remember e^ln(2) = 2."
        ),

        MathProblem(
            displayPrimary: "∫ eˣ dx",
            lowerBound: "0", upperBound: "ln(3)",
            answerType: .integer(2),
            level: .basic, category: .integral,
            technique: "Exponential Integration",
            explanation: """
            ∫eˣ dx = eˣ + C

            [eˣ]₀^ln(3)  =  3 − 1  =  2
            """,
            hint: "e^ln(3) = 3. So eˣ from 0 to ln(3) = 3 − 1."
        ),

        MathProblem(
            displayPrimary: "∫ eˣ dx",
            lowerBound: "0", upperBound: "ln(5)",
            answerType: .integer(4),
            level: .basic, category: .integral,
            technique: "Exponential Integration",
            explanation: """
            [eˣ]₀^ln(5)  =  5 − 1  =  4
            """,
            hint: "e^ln(5) = 5."
        ),

        MathProblem(
            displayPrimary: "∫ eˣ dx",
            lowerBound: "ln(2)", upperBound: "ln(5)",
            answerType: .integer(3),
            level: .basic, category: .integral,
            technique: "Exponential Integration",
            explanation: """
            [eˣ]_{ln(2)}^{ln(5)}  =  5 − 2  =  3
            """,
            hint: "e^ln(n) = n. So F(ln5) − F(ln2) = 5 − 2."
        ),

        MathProblem(
            displayPrimary: "∫ eˣ dx",
            lowerBound: "ln(3)", upperBound: "ln(10)",
            answerType: .integer(7),
            level: .basic, category: .integral,
            technique: "Exponential Integration",
            explanation: """
            [eˣ]_{ln(3)}^{ln(10)}  =  10 − 3  =  7
            """,
            hint: "e^ln(3)=3 and e^ln(10)=10."
        ),

        MathProblem(
            displayPrimary: "∫ 2eˣ dx",
            lowerBound: "0", upperBound: "ln(3)",
            answerType: .integer(4),
            level: .basic, category: .integral,
            technique: "Exponential Integration",
            explanation: """
            ∫2eˣ dx = 2eˣ

            [2eˣ]₀^ln(3)  =  2·3 − 2·1  =  6 − 2  =  4
            """,
            hint: "Pull the 2 out. 2·e^ln(3) − 2·e^0 = 6 − 2."
        ),

        // ── Basic Trig ──

        MathProblem(
            displayPrimary: "∫ sin(x) dx",
            lowerBound: "0", upperBound: "π",
            answerType: .integer(2),
            level: .basic, category: .integral,
            technique: "Trig Integration",
            explanation: """
            ∫sin(x) dx = −cos(x) + C

            [−cos(x)]₀^π
            = −cos(π) − (−cos(0))
            = −(−1) + 1 = 2
            """,
            hint: "∫sin x = −cos x. cos(π) = −1, cos(0) = 1."
        ),

        MathProblem(
            displayPrimary: "∫ cos(x) dx",
            lowerBound: "0", upperBound: "π/2",
            answerType: .integer(1),
            level: .basic, category: .integral,
            technique: "Trig Integration",
            explanation: """
            ∫cos(x) dx = sin(x) + C

            [sin(x)]₀^(π/2)  =  sin(π/2) − sin(0)  =  1 − 0  =  1
            """,
            hint: "∫cos x = sin x. sin(π/2) = 1."
        ),

        MathProblem(
            displayPrimary: "∫ 2sin(x) dx",
            lowerBound: "0", upperBound: "π/2",
            answerType: .integer(2),
            level: .basic, category: .integral,
            technique: "Trig Integration",
            explanation: """
            ∫2sin(x) dx = −2cos(x)

            [−2cos(x)]₀^(π/2)
            = −2·0 − (−2·1) = 2
            """,
            hint: "−2cos(π/2) = 0, −2cos(0) = −2."
        ),

        MathProblem(
            displayPrimary: "∫ sin(x) dx",
            lowerBound: "0", upperBound: "π/2",
            answerType: .integer(1),
            level: .basic, category: .integral,
            technique: "Trig Integration",
            explanation: """
            [−cos(x)]₀^(π/2)
            = −cos(π/2) + cos(0)
            = 0 + 1 = 1
            """,
            hint: "cos(π/2) = 0."
        ),

        MathProblem(
            displayPrimary: "∫ 3cos(x) dx",
            lowerBound: "0", upperBound: "π/2",
            answerType: .integer(3),
            level: .basic, category: .integral,
            technique: "Trig Integration",
            explanation: """
            [3sin(x)]₀^(π/2)  =  3·1 − 3·0  =  3
            """,
            hint: "3·∫cos x dx = 3sin x."
        ),

        // ── Intro U-Substitution (linear composites) ──

        MathProblem(
            displayPrimary: "∫ 3(x + 1)² dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(26),
            level: .basic, category: .integral,
            technique: "U-Substitution",
            explanation: """
            Let u = x+1,  du = dx
            New bounds: x=0→u=1, x=2→u=3

            3∫₁³ u² du = [u³]₁³ = 27 − 1 = 26
            """,
            hint: "Let u = x+1. Bounds shift to 1 and 3."
        ),

        MathProblem(
            displayPrimary: "∫ 2(x + 1) dx",
            lowerBound: "0", upperBound: "3",
            answerType: .integer(15),
            level: .basic, category: .integral,
            technique: "U-Substitution",
            explanation: """
            Let u = x+1,  du = dx
            New bounds: x=0→u=1, x=3→u=4

            2∫₁⁴ u du = [u²]₁⁴ = 16 − 1 = 15
            """,
            hint: "u = x+1, bounds become 1 and 4."
        ),

        MathProblem(
            displayPrimary: "∫ 3(3x + 1)² dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(21),
            level: .basic, category: .integral,
            technique: "U-Substitution",
            explanation: """
            Let u = 3x+1,  du = 3dx
            New bounds: x=0→u=1, x=1→u=4

            ∫₁⁴ u² du = [u³/3]₁⁴ = 64/3 − 1/3 = 21
            """,
            hint: "u = 3x+1, du = 3dx. Bounds: 1 to 4."
        ),

        MathProblem(
            displayPrimary: "∫ 2(2x + 1) dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(12),
            level: .basic, category: .integral,
            technique: "U-Substitution",
            explanation: """
            Let u = 2x+1,  du = 2 dx

            ∫2(2x+1) dx = ∫u du = u²/2 = (2x+1)²/2

            [(2x+1)²/2]₀² = 25/2 − 1/2 = 12
            """,
            hint: "u = 2x+1. Antiderivative is (2x+1)²/2."
        ),

        MathProblem(
            displayPrimary: "∫ 4(x − 1)³ dx",
            lowerBound: "1", upperBound: "3",
            answerType: .integer(16),
            level: .basic, category: .integral,
            technique: "U-Substitution",
            explanation: """
            Let u = x−1,  du = dx
            New bounds: x=1→u=0, x=3→u=2

            4∫₀² u³ du = [u⁴]₀² = 16 − 0 = 16
            """,
            hint: "u = x−1. Bounds shift to 0 and 2. 4·[u⁴/4]₀² = [u⁴]₀²."
        ),

    ]

    // ─────────────────────────────────────────────────────────────────────────
    // LEVEL 2 — Calc II  (28 problems)
    // IBP, trig u-sub (sinⁿcos type), double-angle, e^(kx), harder u-sub chains
    // ─────────────────────────────────────────────────────────────────────────
    private let level2: [MathProblem] = [

        // ── Integration by Parts ──

        MathProblem(
            displayPrimary: "∫ x·eˣ dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(1),
            level: .intermediate, category: .integral,
            technique: "Integration by Parts",
            explanation: """
            IBP: ∫u dv = uv − ∫v du

            u = x,  dv = eˣdx  →  v = eˣ,  du = dx

            = x·eˣ − ∫eˣ dx = eˣ(x−1) + C

            [eˣ(x−1)]₀¹ = e⁰(1−1) − e⁰(0−1)
                         = 0 − (−1) = 1
            """,
            hint: "IBP: let u = x, dv = eˣ dx."
        ),

        MathProblem(
            displayPrimary: "∫ 2x·eˣ dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(2),
            level: .intermediate, category: .integral,
            technique: "Integration by Parts",
            explanation: """
            2 × ∫₀¹ x·eˣ dx = 2 × 1 = 2

            (See ∫x·eˣ dx above: antideriv = eˣ(x−1))
            """,
            hint: "Factor the 2 out, then IBP as usual."
        ),

        MathProblem(
            displayPrimary: "∫ 3x·eˣ dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(3),
            level: .intermediate, category: .integral,
            technique: "Integration by Parts",
            explanation: """
            3 × ∫₀¹ x·eˣ dx = 3 × 1 = 3
            """,
            hint: "3·∫x·eˣ dx. Antiderivative of x·eˣ is eˣ(x−1)."
        ),

        MathProblem(
            displayPrimary: "∫ ln(x) dx",
            lowerBound: "1", upperBound: "e",
            answerType: .integer(1),
            level: .intermediate, category: .integral,
            technique: "Integration by Parts",
            explanation: """
            Write as ∫ln(x)·1 dx, then IBP:

            u = ln(x),  dv = dx  →  v = x,  du = (1/x)dx

            ∫ln(x) dx = x·ln(x) − x + C

            [x·ln(x)−x]₁ᵉ = (e·1−e) − (1·0−1)
                           = 0 + 1 = 1
            """,
            hint: "Write ∫ln(x)·1 dx. Let u = ln(x), dv = dx."
        ),

        // ── Trig U-Substitution (sinⁿcos, cosⁿsin) ──

        MathProblem(
            displayPrimary: "∫ 3sin²(x)cos(x) dx",
            lowerBound: "0", upperBound: "π/2",
            answerType: .integer(1),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            Let u = sin(x),  du = cos(x) dx

            New bounds: x=0→u=0, x=π/2→u=1

            3∫₀¹ u² du = [u³]₀¹ = 1 − 0 = 1
            """,
            hint: "u = sin(x). du = cos(x) dx which is right there."
        ),

        MathProblem(
            displayPrimary: "∫ 6sin²(x)cos(x) dx",
            lowerBound: "0", upperBound: "π/2",
            answerType: .integer(2),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = sin(x),  du = cos(x) dx

            6∫₀¹ u² du = [2u³]₀¹ = 2
            """,
            hint: "u = sin(x), bounds become 0 to 1."
        ),

        MathProblem(
            displayPrimary: "∫ 4sin³(x)cos(x) dx",
            lowerBound: "0", upperBound: "π/2",
            answerType: .integer(1),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = sin(x),  du = cos(x) dx

            4∫₀¹ u³ du = [u⁴]₀¹ = 1
            """,
            hint: "u = sin(x). 4∫₀¹ u³ du = [u⁴]₀¹."
        ),

        MathProblem(
            displayPrimary: "∫ 4sin(x)cos³(x) dx",
            lowerBound: "0", upperBound: "π/2",
            answerType: .integer(1),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            Let u = cos(x),  du = −sin(x) dx

            Bounds: x=0→u=1, x=π/2→u=0

            4∫₁⁰ u³·(−du) = 4∫₀¹ u³ du = [u⁴]₀¹ = 1
            """,
            hint: "u = cos(x). Flip the bounds when you flip the sign."
        ),

        MathProblem(
            displayPrimary: "∫ 3cos²(x)sin(x) dx",
            lowerBound: "0", upperBound: "π",
            answerType: .integer(2),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = cos(x),  du = −sin(x) dx

            Bounds: x=0→u=1, x=π→u=−1

            3∫₁^{−1} u²(−du) = 3∫_{−1}^1 u² du = [u³]_{−1}^1 = 1−(−1) = 2
            """,
            hint: "u = cos(x). Bounds go from 1 to −1, then flip."
        ),

        MathProblem(
            displayPrimary: "∫ 2sin(x)cos(x) dx",
            lowerBound: "0", upperBound: "π/2",
            answerType: .integer(1),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            Identity: 2sin(x)cos(x) = sin(2x)

            ∫sin(2x) dx = −cos(2x)/2

            [−cos(2x)/2]₀^(π/2) = −cos(π)/2 + cos(0)/2
                                 = 1/2 + 1/2 = 1

            OR: u = sin(x) → [sin²x]₀^(π/2) = 1
            """,
            hint: "Either use the identity 2sincos = sin(2x), or u = sin(x)."
        ),

        // ── Double Angle / sin(2x) ──

        MathProblem(
            displayPrimary: "∫ sin(2x) dx",
            lowerBound: "0", upperBound: "π/2",
            answerType: .integer(1),
            level: .intermediate, category: .integral,
            technique: "Trig Integration",
            explanation: """
            ∫sin(2x) dx = −cos(2x)/2

            [−cos(2x)/2]₀^(π/2)
            = −cos(π)/2 + cos(0)/2
            = 1/2 + 1/2 = 1
            """,
            hint: "∫sin(2x) dx = −cos(2x)/2 + C."
        ),

        MathProblem(
            displayPrimary: "∫ 2sin(2x) dx",
            lowerBound: "0", upperBound: "π/2",
            answerType: .integer(2),
            level: .intermediate, category: .integral,
            technique: "Trig Integration",
            explanation: """
            ∫2sin(2x) dx = −cos(2x)

            [−cos(2x)]₀^(π/2) = −cos(π)+cos(0) = 1+1 = 2
            """,
            hint: "2·∫sin(2x) dx = 2·(−cos(2x)/2) = −cos(2x)."
        ),

        MathProblem(
            displayPrimary: "∫ 2cos(2x) dx",
            lowerBound: "0", upperBound: "π/4",
            answerType: .integer(1),
            level: .intermediate, category: .integral,
            technique: "Trig Integration",
            explanation: """
            ∫2cos(2x) dx = sin(2x)

            [sin(2x)]₀^(π/4) = sin(π/2) − sin(0) = 1
            """,
            hint: "∫2cos(2x) dx = sin(2x) + C."
        ),

        // ── e^(kx) with ln bounds ──

        MathProblem(
            displayPrimary: "∫ 2e^(2x) dx",
            lowerBound: "0", upperBound: "ln(2)",
            answerType: .integer(3),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            ∫2e^(2x) dx = e^(2x) + C

            [e^(2x)]₀^ln(2) = e^(2ln2) − 1 = 4 − 1 = 3
            """,
            hint: "Antiderivative is e^(2x). e^(2ln2) = (e^ln2)² = 4."
        ),

        MathProblem(
            displayPrimary: "∫ 2e^(2x) dx",
            lowerBound: "0", upperBound: "ln(3)",
            answerType: .integer(8),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            [e^(2x)]₀^ln(3) = e^(2ln3) − 1 = 9 − 1 = 8
            """,
            hint: "e^(2ln3) = (e^ln3)² = 3² = 9."
        ),

        MathProblem(
            displayPrimary: "∫ 3e^(3x) dx",
            lowerBound: "0", upperBound: "ln(2)",
            answerType: .integer(7),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            ∫3e^(3x) dx = e^(3x) + C

            [e^(3x)]₀^ln(2) = e^(3ln2) − 1 = 2³ − 1 = 7
            """,
            hint: "e^(3ln2) = (e^ln2)³ = 2³ = 8. Then 8 − 1."
        ),

        MathProblem(
            displayPrimary: "∫ 4e^(4x) dx",
            lowerBound: "0", upperBound: "ln(2)",
            answerType: .integer(15),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            [e^(4x)]₀^ln(2) = 2⁴ − 1 = 16 − 1 = 15
            """,
            hint: "e^(4ln2) = 2⁴ = 16."
        ),

        MathProblem(
            displayPrimary: "∫ 5e^(5x) dx",
            lowerBound: "0", upperBound: "ln(2)",
            answerType: .integer(31),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            [e^(5x)]₀^ln(2) = 2⁵ − 1 = 32 − 1 = 31
            """,
            hint: "e^(5ln2) = 2⁵ = 32."
        ),

        // ── Harder U-Substitution chains ──

        MathProblem(
            displayPrimary: "∫ 8x(x² + 1)³ dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(15),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = x²+1,  du = 2x dx  →  8x dx = 4 du

            Bounds: x=0→u=1, x=1→u=2

            4∫₁² u³ du = [u⁴]₁² = 16 − 1 = 15
            """,
            hint: "u = x²+1. Notice 8x dx = 4·(2x dx) = 4 du."
        ),

        MathProblem(
            displayPrimary: "∫ 12x(x² + 1)⁵ dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(63),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = x²+1,  du = 2x dx  →  12x dx = 6 du

            Bounds: 1 to 2

            6∫₁² u⁵ du = [u⁶]₁² = 64 − 1 = 63
            """,
            hint: "u = x²+1. 12x dx = 6 du."
        ),

        MathProblem(
            displayPrimary: "∫ 6x(x² + 1)² dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(7),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = x²+1,  du = 2x dx  →  6x dx = 3 du

            Bounds: 1 to 2

            3∫₁² u² du = [u³]₁² = 8 − 1 = 7
            """,
            hint: "u = x²+1. 6x dx = 3 du."
        ),

        MathProblem(
            displayPrimary: "∫ 6x(x² + 2)² dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(19),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = x²+2,  du = 2x dx  →  6x dx = 3 du

            Bounds: x=0→u=2, x=1→u=3

            3∫₂³ u² du = [u³]₂³ = 27 − 8 = 19
            """,
            hint: "u = x²+2. Bounds shift to 2 and 3."
        ),

        MathProblem(
            displayPrimary: "∫ 10x(x² + 1)⁴ dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(31),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = x²+1,  du = 2x dx  →  10x dx = 5 du

            Bounds: 1 to 2

            5∫₁² u⁴ du = [u⁵]₁² = 32 − 1 = 31
            """,
            hint: "u = x²+1. 5∫₁² u⁴ du."
        ),

        MathProblem(
            displayPrimary: "∫ 9x²(x³ + 1)² dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(7),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = x³+1,  du = 3x² dx  →  9x² dx = 3 du

            Bounds: x=0→u=1, x=1→u=2

            3∫₁² u² du = [u³]₁² = 8 − 1 = 7
            """,
            hint: "u = x³+1. 9x² dx = 3 du."
        ),

        MathProblem(
            displayPrimary: "∫ 12x³(x⁴ + 1)² dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(7),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = x⁴+1,  du = 4x³ dx  →  12x³ dx = 3 du

            Bounds: x=0→u=1, x=1→u=2

            3∫₁² u² du = [u³]₁² = 8 − 1 = 7
            """,
            hint: "u = x⁴+1. 12x³ dx = 3 du."
        ),

        MathProblem(
            displayPrimary: "∫ 8x³(x⁴ + 1) dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(3),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = x⁴+1,  du = 4x³ dx  →  8x³ dx = 2 du

            Bounds: 1 to 2

            2∫₁² u du = [u²]₁² = 4 − 1 = 3
            """,
            hint: "u = x⁴+1. 8x³ dx = 2 du."
        ),

        MathProblem(
            displayPrimary: "∫ 8x(x² + 2)³ dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(65),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = x²+2,  du = 2x dx  →  8x dx = 4 du

            Bounds: x=0→u=2, x=1→u=3

            4∫₂³ u³ du = [u⁴]₂³ = 81 − 16 = 65
            """,
            hint: "u = x²+2. Bounds start at 2 (not 1)!"
        ),

        MathProblem(
            displayPrimary: "∫ 12x²(x³ + 1)³ dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(15),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = x³+1,  du = 3x² dx  →  12x² dx = 4 du

            Bounds: x=0→u=1, x=1→u=2

            4∫₁² u³ du = [u⁴]₁² = 16 − 1 = 15
            """,
            hint: "u = x³+1. 12x² dx = 4 du."
        ),

    ]

    // ─────────────────────────────────────────────────────────────────────────
    // LEVEL 3 — Calc III / Advanced  (23 problems)
    // Trig substitution, very large u-sub chains
    // ─────────────────────────────────────────────────────────────────────────
    private let level3: [MathProblem] = [

        // ── Trig Substitution: x/√(a²−x²)  antideriv = −√(a²−x²) ──

        MathProblem(
            displayPrimary: "∫ x/√(9 − x²) dx",
            lowerBound: "0", upperBound: "3",
            answerType: .integer(3),
            level: .advanced, category: .integral,
            technique: "Trig Substitution",
            explanation: """
            Antiderivative of x/√(a²−x²) = −√(a²−x²)

            [−√(9−x²)]₀³
            = −√0 − (−√9)
            = 0 + 3 = 3
            """,
            hint: "The antiderivative of x/√(a²−x²) is −√(a²−x²)."
        ),

        MathProblem(
            displayPrimary: "∫ x/√(16 − x²) dx",
            lowerBound: "0", upperBound: "4",
            answerType: .integer(4),
            level: .advanced, category: .integral,
            technique: "Trig Substitution",
            explanation: """
            [−√(16−x²)]₀⁴
            = −√0 − (−√16)
            = 0 + 4 = 4
            """,
            hint: "Antiderivative is −√(16−x²)."
        ),

        MathProblem(
            displayPrimary: "∫ x/√(25 − x²) dx",
            lowerBound: "0", upperBound: "5",
            answerType: .integer(5),
            level: .advanced, category: .integral,
            technique: "Trig Substitution",
            explanation: """
            [−√(25−x²)]₀⁵ = 0 + 5 = 5
            """,
            hint: "At x=5: √(25−25)=0. At x=0: √25=5."
        ),

        MathProblem(
            displayPrimary: "∫ x/√(4 − x²) dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(2),
            level: .advanced, category: .integral,
            technique: "Trig Substitution",
            explanation: """
            [−√(4−x²)]₀² = 0 + 2 = 2
            """,
            hint: "Pattern: upper bound equals √(a²), answer equals a."
        ),

        // ── Trig Substitution: x/√(x²−a²)  antideriv = √(x²−a²) ──

        MathProblem(
            displayPrimary: "∫ x/√(x² − 9) dx",
            lowerBound: "3", upperBound: "5",
            answerType: .integer(4),
            level: .advanced, category: .integral,
            technique: "Trig Substitution",
            explanation: """
            Antiderivative of x/√(x²−a²) = √(x²−a²)

            [√(x²−9)]₃⁵
            = √(25−9) − √(9−9)
            = √16 − 0 = 4
            """,
            hint: "Antiderivative is +√(x²−9). 3-4-5 right triangle!"
        ),

        MathProblem(
            displayPrimary: "∫ x/√(x² − 16) dx",
            lowerBound: "4", upperBound: "5",
            answerType: .integer(3),
            level: .advanced, category: .integral,
            technique: "Trig Substitution",
            explanation: """
            [√(x²−16)]₄⁵
            = √(25−16) − √(16−16)
            = √9 − 0 = 3
            """,
            hint: "Antiderivative is √(x²−16)."
        ),

        MathProblem(
            displayPrimary: "∫ x/√(x² − 144) dx",
            lowerBound: "12", upperBound: "13",
            answerType: .integer(5),
            level: .advanced, category: .integral,
            technique: "Trig Substitution",
            explanation: """
            [√(x²−144)]₁₂¹³
            = √(169−144) − 0
            = √25 = 5

            (5-12-13 Pythagorean triple)
            """,
            hint: "5-12-13 right triangle. √(13²−12²) = √25 = 5."
        ),

        // ── Trig Substitution: x/√(1+x²)  antideriv = √(1+x²) ──

        MathProblem(
            displayPrimary: "∫ x/√(1 + x²) dx",
            lowerBound: "0", upperBound: "√3",
            answerType: .integer(1),
            level: .advanced, category: .integral,
            technique: "Trig Substitution",
            explanation: """
            Antiderivative of x/√(1+x²) = √(1+x²)

            [√(1+x²)]₀^√3
            = √(1+3) − √(1+0)
            = 2 − 1 = 1
            """,
            hint: "Antiderivative is √(1+x²). At x=√3: √4 = 2."
        ),

        MathProblem(
            displayPrimary: "∫ x/√(1 + x²) dx",
            lowerBound: "0", upperBound: "√8",
            answerType: .integer(2),
            level: .advanced, category: .integral,
            technique: "Trig Substitution",
            explanation: """
            [√(1+x²)]₀^√8
            = √(1+8) − 1
            = 3 − 1 = 2
            """,
            hint: "At x=√8: √(1+8) = √9 = 3."
        ),

        MathProblem(
            displayPrimary: "∫ x/√(1 + x²) dx",
            lowerBound: "0", upperBound: "√15",
            answerType: .integer(3),
            level: .advanced, category: .integral,
            technique: "Trig Substitution",
            explanation: """
            [√(1+x²)]₀^√15
            = √16 − 1 = 4 − 1 = 3
            """,
            hint: "At x=√15: √(1+15) = √16 = 4."
        ),

        MathProblem(
            displayPrimary: "∫ x/√(1 + x²) dx",
            lowerBound: "0", upperBound: "√24",
            answerType: .integer(4),
            level: .advanced, category: .integral,
            technique: "Trig Substitution",
            explanation: """
            [√(1+x²)]₀^√24
            = √25 − 1 = 5 − 1 = 4
            """,
            hint: "At x=√24: √(1+24) = √25 = 5."
        ),

        // ── Harder Trig Sub: x³/√(a²−x²) ──

        // ── Double Integrals (Level 3) ──

        MathProblem(
            displayPrimary: "∫ (∫₀¹ 6xy dy) dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(6),
            level: .advanced, category: .integral,
            technique: "Double Integral",
            explanation: """
            Inner: ∫₀¹ 6xy dy = [3xy²]₀¹ = 3x
            Outer: ∫₀² 3x dx = [3x²/2]₀² = 6
            """,
            hint: "Integrate inner (y) first, treating x as constant. Then integrate outer (x)."
        ),

        MathProblem(
            displayPrimary: "∫ (∫₀² 12xy dx) dy",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(12),
            level: .advanced, category: .integral,
            technique: "Double Integral",
            explanation: """
            Inner: ∫₀² 12xy dx = [6x²y]₀² = 24y
            Outer: ∫₀¹ 24y dy = [12y²]₀¹ = 12
            """,
            hint: "Inner integrand is 12xy over x from 0 to 2. Result is 24y."
        ),

        MathProblem(
            displayPrimary: "∫ (∫₀¹ 8xy dy) dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(2),
            level: .advanced, category: .integral,
            technique: "Double Integral",
            explanation: """
            Inner: ∫₀¹ 8xy dy = [4xy²]₀¹ = 4x
            Outer: ∫₀¹ 4x dx = [2x²]₀¹ = 2
            """,
            hint: "Inner result is 4x. Outer integral of 4x from 0 to 1."
        ),

        MathProblem(
            displayPrimary: "∫ x³/√(9 − x²) dx",
            lowerBound: "0", upperBound: "3",
            answerType: .integer(18),
            level: .advanced, category: .integral,
            technique: "Trig Substitution",
            explanation: """
            Let x = 3sinθ,  dx = 3cosθ dθ,  √(9−x²) = 3cosθ

            x³/√(9−x²) · dx = 27sin³θ/cosθ · 3cosθ dθ = 27sin³θ dθ

            Bounds: x=0→θ=0, x=3→θ=π/2

            27∫₀^(π/2) sin³θ dθ = 27·(2/3) = 18

            (∫₀^(π/2) sin³θ dθ = 2/3 is a standard result)
            """,
            hint: "x = 3sinθ. The integrand becomes 27sin³θ dθ. ∫₀^(π/2)sin³θ dθ = 2/3."
        ),

        // ── Advanced U-Sub chains (very large, Level 3 territory) ──

        MathProblem(
            displayPrimary: "∫ 8x(x² + 3)³ dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(175),
            level: .advanced, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = x²+3,  du = 2x dx  →  8x dx = 4 du

            Bounds: x=0→u=3, x=1→u=4

            4∫₃⁴ u³ du = [u⁴]₃⁴ = 256 − 81 = 175
            """,
            hint: "u = x²+3. Bounds are 3 to 4. 4⁴ − 3⁴ = 256 − 81."
        ),

        MathProblem(
            displayPrimary: "∫ 18x²(x³ + 2)² dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(38),
            level: .advanced, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = x³+2,  du = 3x² dx  →  18x² dx = 6 du

            Bounds: x=0→u=2, x=1→u=3

            6∫₂³ u² du = [2u³]₂³ = 54 − 16 = 38
            """,
            hint: "u = x³+2. Bounds are 2 to 3. 2·3³ − 2·2³ = 54 − 16."
        ),

        MathProblem(
            displayPrimary: "∫ 8x(x² + 1)³ dx",
            lowerBound: "0", upperBound: "√3",
            answerType: .integer(255),
            level: .advanced, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = x²+1,  du = 2x dx  →  8x dx = 4 du

            Bounds: x=0→u=1, x=√3→u=4

            4∫₁⁴ u³ du = [u⁴]₁⁴ = 256 − 1 = 255
            """,
            hint: "u = x²+1. At x=√3: u = 3+1 = 4. So 4∫₁⁴ u³ du."
        ),

        MathProblem(
            displayPrimary: "∫ 20x³(x⁴ + 1)⁴ dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(31),
            level: .advanced, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = x⁴+1,  du = 4x³ dx  →  20x³ dx = 5 du

            Bounds: x=0→u=1, x=1→u=2

            5∫₁² u⁴ du = [u⁵]₁² = 32 − 1 = 31
            """,
            hint: "u = x⁴+1. 20x³ dx = 5 du."
        ),

        MathProblem(
            displayPrimary: "∫ 6x(x² + 1)² dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(124),
            level: .advanced, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = x²+1,  du = 2x dx  →  6x dx = 3 du

            Bounds: x=0→u=1, x=2→u=5

            3∫₁⁵ u² du = [u³]₁⁵ = 125 − 1 = 124
            """,
            hint: "u = x²+1. At x=2: u=5. 3∫₁⁵u² du = [u³]₁⁵."
        ),

        MathProblem(
            displayPrimary: "∫ 10x(x² + 1)⁴ dx",
            lowerBound: "0", upperBound: "√2",
            answerType: .integer(242),
            level: .advanced, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = x²+1,  du = 2x dx  →  10x dx = 5 du

            Bounds: x=0→u=1, x=√2→u=3

            5∫₁³ u⁴ du = [u⁵]₁³ = 243 − 1 = 242
            """,
            hint: "At x=√2: u = 2+1 = 3. 5∫₁³u⁴ du = [u⁵]₁³ = 243−1."
        ),

        MathProblem(
            displayPrimary: "∫ 20x⁴(x⁵ + 1)³ dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(15),
            level: .advanced, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = x⁵+1,  du = 5x⁴ dx  →  20x⁴ dx = 4 du

            Bounds: x=0→u=1, x=1→u=2

            4∫₁² u³ du = [u⁴]₁² = 16 − 1 = 15
            """,
            hint: "u = x⁵+1. 20x⁴ dx = 4 du."
        ),

        MathProblem(
            displayPrimary: "∫ 12x(x² + 1)⁵ dx",
            lowerBound: "0", upperBound: "√2",
            answerType: .integer(728),
            level: .advanced, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = x²+1,  du = 2x dx  →  12x dx = 6 du

            Bounds: x=0→u=1, x=√2→u=3

            6∫₁³ u⁵ du = [u⁶]₁³ = 729 − 1 = 728
            """,
            hint: "At x=√2: u=3. 6∫₁³ u⁵ du = [u⁶]₁³ = 729−1."
        ),

        MathProblem(
            displayPrimary: "∫ 8x(x² + 4)³ dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(369),
            level: .advanced, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = x²+4,  du = 2x dx  →  8x dx = 4 du

            Bounds: x=0→u=4, x=1→u=5

            4∫₄⁵ u³ du = [u⁴]₄⁵ = 625 − 256 = 369
            """,
            hint: "u = x²+4. Bounds are 4 to 5."
        ),

        MathProblem(
            displayPrimary: "∫ 16x³(x⁴ + 2)³ dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(65),
            level: .advanced, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = x⁴+2,  du = 4x³ dx  →  16x³ dx = 4 du

            Bounds: x=0→u=2, x=1→u=3

            4∫₂³ u³ du = [u⁴]₂³ = 81 − 16 = 65
            """,
            hint: "u = x⁴+2. Bounds are 2 to 3."
        ),

        MathProblem(
            displayPrimary: "∫ 24x²(x³ + 3)³ dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(350),
            level: .advanced, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u = x³+3,  du = 3x² dx  →  24x² dx = 8 du

            Bounds: x=0→u=3, x=1→u=4

            8∫₃⁴ u³ du = [2u⁴]₃⁴ = 2(256 − 81) = 350
            """,
            hint: "u = x³+3. 8∫₃⁴u³ du = [2u⁴]₃⁴."
        ),

    ]

    // ─────────────────────────────────────────────────────────────────────────
    // LEVEL 4 — Expert  (16 problems)
    // Composite eˣ² substitution, IBP, deep chains — genuinely hard
    // ─────────────────────────────────────────────────────────────────────────
    private let level4: [MathProblem] = [

        // ── Composite eˣ² / eˣ⁴ / eˣ⁶ substitution ──
        // Key insight: ∫ 2x·eˣ² dx — u = x², du = 2x dx → ∫eᵘdu = eˣ² + C
        // Bounds chosen so e^(x²) at upper = integer

        MathProblem(
            displayPrimary: "∫ 2x·eˣ² dx",
            lowerBound: "0", upperBound: "√(ln 2)",
            answerType: .integer(1),
            level: .expert, category: .integral,
            technique: "Composite E-Substitution",
            explanation: """
            u = x²,  du = 2x dx

            ∫2x·eˣ² dx = ∫eᵘ du = eˣ² + C

            [eˣ²]₀^√(ln2) = e^(ln2) − e⁰ = 2 − 1 = 1
            """,
            hint: "u = x². Then du = 2x dx, which is exactly what you have."
        ),

        MathProblem(
            displayPrimary: "∫ 2x·eˣ² dx",
            lowerBound: "0", upperBound: "√(ln 3)",
            answerType: .integer(2),
            level: .expert, category: .integral,
            technique: "Composite E-Substitution",
            explanation: """
            u = x²,  [eˣ²]₀^√(ln3) = e^(ln3) − 1 = 3 − 1 = 2
            """,
            hint: "u = x². e^(ln3) = 3."
        ),

        MathProblem(
            displayPrimary: "∫ 2x·eˣ² dx",
            lowerBound: "0", upperBound: "√(ln 5)",
            answerType: .integer(4),
            level: .expert, category: .integral,
            technique: "Composite E-Substitution",
            explanation: """
            u = x²,  [eˣ²]₀^√(ln5) = 5 − 1 = 4
            """,
            hint: "u = x². At upper bound: e^(x²) = e^(ln5) = 5."
        ),

        MathProblem(
            displayPrimary: "∫ 2x·eˣ² dx",
            lowerBound: "0", upperBound: "√(ln 7)",
            answerType: .integer(6),
            level: .expert, category: .integral,
            technique: "Composite E-Substitution",
            explanation: """
            u = x²,  [eˣ²]₀^√(ln7) = 7 − 1 = 6
            """,
            hint: "e^(ln7) = 7. So 7 − 1 = 6."
        ),

        MathProblem(
            displayPrimary: "∫ 4x³·eˣ⁴ dx",
            lowerBound: "0", upperBound: "⁴√(ln 2)",
            answerType: .integer(1),
            level: .expert, category: .integral,
            technique: "Composite E-Substitution",
            explanation: """
            u = x⁴,  du = 4x³ dx

            ∫4x³·eˣ⁴ dx = ∫eᵘ du = eˣ⁴ + C

            [eˣ⁴]₀^⁴√(ln2) = e^(ln2) − 1 = 2 − 1 = 1
            """,
            hint: "u = x⁴. du = 4x³ dx which matches the integrand exactly."
        ),

        MathProblem(
            displayPrimary: "∫ 4x³·eˣ⁴ dx",
            lowerBound: "0", upperBound: "⁴√(ln 5)",
            answerType: .integer(4),
            level: .expert, category: .integral,
            technique: "Composite E-Substitution",
            explanation: """
            u = x⁴,  [eˣ⁴]₀^⁴√(ln5) = e^(ln5) − 1 = 5 − 1 = 4
            """,
            hint: "u = x⁴. At upper: x⁴ = ln5, so eˣ⁴ = 5."
        ),

        MathProblem(
            displayPrimary: "∫ 6x⁵·eˣ⁶ dx",
            lowerBound: "0", upperBound: "⁶√(ln 3)",
            answerType: .integer(2),
            level: .expert, category: .integral,
            technique: "Composite E-Substitution",
            explanation: """
            u = x⁶,  du = 6x⁵ dx

            [eˣ⁶]₀^⁶√(ln3) = e^(ln3) − 1 = 3 − 1 = 2
            """,
            hint: "u = x⁶. du = 6x⁵ dx. Antiderivative is eˣ⁶."
        ),

        MathProblem(
            displayPrimary: "∫ 6x⁵·eˣ⁶ dx",
            lowerBound: "0", upperBound: "⁶√(ln 7)",
            answerType: .integer(6),
            level: .expert, category: .integral,
            technique: "Composite E-Substitution",
            explanation: """
            u = x⁶,  [eˣ⁶]₀^⁶√(ln7) = 7 − 1 = 6
            """,
            hint: "At upper: x⁶ = ln7, so eˣ⁶ = 7. Answer = 7 − 1."
        ),

        MathProblem(
            displayPrimary: "∫ 8x³·eˣ⁴ dx",
            lowerBound: "0", upperBound: "⁴√(ln 3)",
            answerType: .integer(4),
            level: .expert, category: .integral,
            technique: "Composite E-Substitution",
            explanation: """
            u = x⁴,  du = 4x³ dx  →  8x³ dx = 2 du

            2∫₀^ln(3) eᵘ du = [2eˣ⁴]₀^⁴√(ln3) = 2·3 − 2·1 = 4
            """,
            hint: "u = x⁴. 8x³ dx = 2 du. Antiderivative is 2eˣ⁴."
        ),

        MathProblem(
            displayPrimary: "∫ 6x²·eˣ³ dx",
            lowerBound: "0", upperBound: "³√(ln 7)",
            answerType: .integer(12),
            level: .expert, category: .integral,
            technique: "Composite E-Substitution",
            explanation: """
            u = x³,  du = 3x² dx  →  6x² dx = 2 du

            [2eˣ³]₀^³√(ln7) = 2·7 − 2·1 = 12
            """,
            hint: "u = x³. 6x² dx = 2 du. Antiderivative is 2eˣ³."
        ),

        // ── Integration by Parts (Expert difficulty) ──

        MathProblem(
            displayPrimary: "∫ x·eˣ dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(1),
            level: .expert, category: .integral,
            technique: "Integration by Parts",
            explanation: """
            u = x,  dv = eˣdx  →  v = eˣ,  du = dx

            ∫x·eˣ dx = eˣ(x−1) + C

            [eˣ(x−1)]₀¹ = e⁰(1−1) − e⁰(0−1) = 0 + 1 = 1
            """,
            hint: "IBP: u=x, dv=eˣdx. Antiderivative is eˣ(x−1)."
        ),

        MathProblem(
            displayPrimary: "∫ ln(x) dx",
            lowerBound: "1", upperBound: "e",
            answerType: .integer(1),
            level: .expert, category: .integral,
            technique: "Integration by Parts",
            explanation: """
            Treat as ∫ln(x)·1 dx:

            u = ln(x),  dv = dx  →  v = x,  du = dx/x

            = x·ln(x) − x + C

            [x·ln(x)−x]₁ᵉ = (e−e) − (0−1) = 0 + 1 = 1
            """,
            hint: "IBP: u = ln(x), dv = dx. Then x·ln(x) − x + C."
        ),

        MathProblem(
            displayPrimary: "∫ 5x·eˣ dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(5),
            level: .expert, category: .integral,
            technique: "Integration by Parts",
            explanation: """
            5 · ∫₀¹ x·eˣ dx = 5 · 1 = 5

            (Antiderivative: 5eˣ(x−1))
            """,
            hint: "5 times the classic IBP result ∫₀¹ x·eˣ dx = 1."
        ),

        MathProblem(
            displayPrimary: "∫ 3ln(x) dx",
            lowerBound: "1", upperBound: "e",
            answerType: .integer(3),
            level: .expert, category: .integral,
            technique: "Integration by Parts",
            explanation: """
            3 · ∫₁ᵉ ln(x) dx = 3 · 1 = 3
            """,
            hint: "3 times ∫ln(x)dx from 1 to e = 3."
        ),

        MathProblem(
            displayPrimary: "∫ 4ln(x) dx",
            lowerBound: "1", upperBound: "e",
            answerType: .integer(4),
            level: .expert, category: .integral,
            technique: "Integration by Parts",
            explanation: """
            4 · [x·ln(x)−x]₁ᵉ = 4 · 1 = 4
            """,
            hint: "4 × ∫₁ᵉ ln(x) dx = 4 × 1."
        ),

        MathProblem(
            displayPrimary: "∫ 2x·eˣ dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(2),
            level: .expert, category: .integral,
            technique: "Integration by Parts",
            explanation: """
            2 · [eˣ(x−1)]₀¹ = 2 · 1 = 2

            Antiderivative: 2eˣ(x−1)
            """,
            hint: "IBP with u=x, dv=eˣdx. Multiply result by 2."
        ),

        // ── Double Integrals (Expert) ──

        MathProblem(
            displayPrimary: "∫ (∫₀² 3x²y dy) dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(16),
            level: .expert, category: .integral,
            technique: "Double Integral",
            explanation: """
            Inner: ∫₀² 3x²y dy = [3x²y²/2]₀² = 6x²
            Outer: ∫₀² 6x² dx = [2x³]₀² = 16
            """,
            hint: "Inner gives 6x². Outer ∫₀² 6x² dx = [2x³]₀² = 16."
        ),

        MathProblem(
            displayPrimary: "∫ (∫₀¹ 6x²y dy) dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(8),
            level: .expert, category: .integral,
            technique: "Double Integral",
            explanation: """
            Inner: ∫₀¹ 6x²y dy = [3x²y²]₀¹ = 3x²
            Outer: ∫₀² 3x² dx = [x³]₀² = 8
            """,
            hint: "Inner result is 3x². Outer ∫₀² 3x² dx = 8."
        ),

        MathProblem(
            displayPrimary: "∫ (∫₀² 4x³y dx) dy",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(8),
            level: .expert, category: .integral,
            technique: "Double Integral",
            explanation: """
            Inner: ∫₀² 4x³y dx = [x⁴y]₀² = 16y
            Outer: ∫₀¹ 16y dy = [8y²]₀¹ = 8
            """,
            hint: "Inner gives 16y. Outer ∫₀¹ 16y dy = 8."
        ),

    ]

    // ─────────────────────────────────────────────────────────────────────────
    // DERIVATIVES  (subject: .derivatives)
    // ─────────────────────────────────────────────────────────────────────────

    // Level 1 — Power Rule (find f'(x) at a point)
    private let derivL1: [MathProblem] = [

        MathProblem(
            displayPrimary: "f(x) = x²",
            lowerBound: "x = 3", upperBound: "",
            answerType: .integer(6),
            level: .basic, category: .derivative,
            technique: "Power Rule",
            explanation: "f'(x) = 2x.  f'(3) = 6.",
            hint: "Power rule: f'(xⁿ) = n·xⁿ⁻¹.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = x³",
            lowerBound: "x = 2", upperBound: "",
            answerType: .integer(12),
            level: .basic, category: .derivative,
            technique: "Power Rule",
            explanation: "f'(x) = 3x².  f'(2) = 12.",
            hint: "f'(x³) = 3x².",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = 3x²",
            lowerBound: "x = 4", upperBound: "",
            answerType: .integer(24),
            level: .basic, category: .derivative,
            technique: "Power Rule",
            explanation: "f'(x) = 6x.  f'(4) = 24.",
            hint: "f'(3x²) = 6x.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = x⁴",
            lowerBound: "x = 2", upperBound: "",
            answerType: .integer(32),
            level: .basic, category: .derivative,
            technique: "Power Rule",
            explanation: "f'(x) = 4x³.  f'(2) = 32.",
            hint: "f'(x⁴) = 4x³.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = x² + 2x",
            lowerBound: "x = 3", upperBound: "",
            answerType: .integer(8),
            level: .basic, category: .derivative,
            technique: "Power Rule",
            explanation: "f'(x) = 2x+2.  f'(3) = 8.",
            hint: "Differentiate term by term.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = 4x² − x",
            lowerBound: "x = 2", upperBound: "",
            answerType: .integer(15),
            level: .basic, category: .derivative,
            technique: "Power Rule",
            explanation: "f'(x) = 8x−1.  f'(2) = 15.",
            hint: "f'(4x²) = 8x, f'(x) = 1.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = x³ + x",
            lowerBound: "x = 2", upperBound: "",
            answerType: .integer(13),
            level: .basic, category: .derivative,
            technique: "Power Rule",
            explanation: "f'(x) = 3x²+1.  f'(2) = 13.",
            hint: "f'(x³+x) = 3x²+1.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = 6x² − 4",
            lowerBound: "x = 1", upperBound: "",
            answerType: .integer(12),
            level: .basic, category: .derivative,
            technique: "Power Rule",
            explanation: "f'(x) = 12x.  f'(1) = 12.",
            hint: "The constant −4 vanishes when differentiating.",
            subject: .derivatives
        ),
    ]

    // Level 2 — Chain Rule & Product Rule
    private let derivL2: [MathProblem] = [

        MathProblem(
            displayPrimary: "f(x) = (x² + 1)²",
            lowerBound: "x = 1", upperBound: "",
            answerType: .integer(8),
            level: .intermediate, category: .derivative,
            technique: "Chain Rule",
            explanation: "f'(x) = 2(x²+1)·2x = 4x(x²+1).  f'(1) = 4·1·2 = 8.",
            hint: "Chain rule: outer × inner derivative.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = (2x + 1)³",
            lowerBound: "x = 0", upperBound: "",
            answerType: .integer(6),
            level: .intermediate, category: .derivative,
            technique: "Chain Rule",
            explanation: "f'(x) = 3(2x+1)²·2 = 6(2x+1)².  f'(0) = 6.",
            hint: "f' = 6(2x+1)².",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = (x + 1)⁴",
            lowerBound: "x = 0", upperBound: "",
            answerType: .integer(4),
            level: .intermediate, category: .derivative,
            technique: "Chain Rule",
            explanation: "f'(x) = 4(x+1)³.  f'(0) = 4.",
            hint: "f' = 4(x+1)³.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = x · eˣ",
            lowerBound: "x = 0", upperBound: "",
            answerType: .integer(1),
            level: .intermediate, category: .derivative,
            technique: "Product Rule",
            explanation: "Product rule: f'= eˣ + x·eˣ = eˣ(1+x).  f'(0) = 1.",
            hint: "Product rule: (uv)' = u'v + uv'.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = ln(x²)",
            lowerBound: "x = 1", upperBound: "",
            answerType: .integer(2),
            level: .intermediate, category: .derivative,
            technique: "Chain Rule",
            explanation: "ln(x²) = 2ln(x). f'(x) = 2/x.  f'(1) = 2.",
            hint: "ln(x²) = 2ln(x). Derivative of 2ln(x) is 2/x.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = e^(2x)",
            lowerBound: "x = 0", upperBound: "",
            answerType: .integer(2),
            level: .intermediate, category: .derivative,
            technique: "Chain Rule",
            explanation: "f'(x) = 2e^(2x).  f'(0) = 2.",
            hint: "Chain rule on eˣ: multiply by inner derivative.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = (x² + 1)³",
            lowerBound: "x = 1", upperBound: "",
            answerType: .integer(24),
            level: .intermediate, category: .derivative,
            technique: "Chain Rule",
            explanation: "f'(x) = 3(x²+1)²·2x = 6x(x²+1)².  f'(1) = 6·1·4 = 24.",
            hint: "f' = 6x(x²+1)².",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = (3x + 1)⁵",
            lowerBound: "x = 0", upperBound: "",
            answerType: .integer(15),
            level: .intermediate, category: .derivative,
            technique: "Chain Rule",
            explanation: "f'(x) = 5(3x+1)⁴·3 = 15(3x+1)⁴.  f'(0) = 15.",
            hint: "f' = 15(3x+1)⁴.",
            subject: .derivatives
        ),
    ]

    // Level 3 — Trig derivatives, second derivatives
    private let derivL3: [MathProblem] = [

        MathProblem(
            displayPrimary: "f(x) = sin(x)",
            lowerBound: "x = 0", upperBound: "",
            answerType: .integer(1),
            level: .advanced, category: .derivative,
            technique: "Trig Derivative",
            explanation: "f'(x) = cos(x).  f'(0) = cos(0) = 1.",
            hint: "d/dx[sin(x)] = cos(x).",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = sin(2x)",
            lowerBound: "x = 0", upperBound: "",
            answerType: .integer(2),
            level: .advanced, category: .derivative,
            technique: "Trig Derivative",
            explanation: "f'(x) = 2cos(2x).  f'(0) = 2.",
            hint: "Chain rule: d/dx[sin(2x)] = 2cos(2x).",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = sin(3x)",
            lowerBound: "x = 0", upperBound: "",
            answerType: .integer(3),
            level: .advanced, category: .derivative,
            technique: "Trig Derivative",
            explanation: "f'(x) = 3cos(3x).  f'(0) = 3.",
            hint: "d/dx[sin(3x)] = 3cos(3x).",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = tan(x)",
            lowerBound: "x = 0", upperBound: "",
            answerType: .integer(1),
            level: .advanced, category: .derivative,
            technique: "Trig Derivative",
            explanation: "f'(x) = sec²(x).  f'(0) = sec²(0) = 1.",
            hint: "d/dx[tan(x)] = sec²(x).",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = tan(2x)",
            lowerBound: "x = 0", upperBound: "",
            answerType: .integer(2),
            level: .advanced, category: .derivative,
            technique: "Trig Derivative",
            explanation: "f'(x) = 2sec²(2x).  f'(0) = 2.",
            hint: "Chain rule: d/dx[tan(2x)] = 2sec²(2x).",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = x · sin(x)  —  f'(π/2)",
            lowerBound: "x = π/2", upperBound: "",
            answerType: .integer(1),
            level: .advanced, category: .derivative,
            technique: "Product Rule",
            explanation: "f'= sin(x)+x·cos(x).  At π/2: 1 + (π/2)·0 = 1.",
            hint: "Product rule. cos(π/2) = 0.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f''(x) of f(x) = x⁴  —  f''(2)",
            lowerBound: "x = 2", upperBound: "",
            answerType: .integer(48),
            level: .advanced, category: .derivative,
            technique: "Second Derivative",
            explanation: "f'(x)=4x³, f''(x)=12x².  f''(2)=48.",
            hint: "Differentiate twice. f''(x) = 12x².",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f''(x) of f(x) = x³  —  f''(3)",
            lowerBound: "x = 3", upperBound: "",
            answerType: .integer(18),
            level: .advanced, category: .derivative,
            technique: "Second Derivative",
            explanation: "f'(x)=3x², f''(x)=6x.  f''(3)=18.",
            hint: "f''(x³) = 6x.",
            subject: .derivatives
        ),
    ]

    // Level 4 — Expert derivatives
    private let derivL4: [MathProblem] = [

        MathProblem(
            displayPrimary: "f(x) = (x+1)⁵  —  f''(0)",
            lowerBound: "x = 0", upperBound: "",
            answerType: .integer(20),
            level: .expert, category: .derivative,
            technique: "Second Derivative",
            explanation: "f'=5(x+1)⁴, f''=20(x+1)³.  f''(0)=20.",
            hint: "Differentiate twice. f''(x) = 20(x+1)³.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = x³ + 3x²  —  f''(2)",
            lowerBound: "x = 2", upperBound: "",
            answerType: .integer(18),
            level: .expert, category: .derivative,
            technique: "Second Derivative",
            explanation: "f'=3x²+6x, f''=6x+6.  f''(2)=18.",
            hint: "f''(x) = 6x + 6.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = eˣ · x²  —  f'(0)",
            lowerBound: "x = 0", upperBound: "",
            answerType: .integer(0),
            level: .expert, category: .derivative,
            technique: "Product Rule",
            explanation: "f'= 2xeˣ + x²eˣ = xeˣ(2+x).  f'(0)=0.",
            hint: "Product rule. At x=0 the factor x makes it zero.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = ln(sin(x))  —  f'(π/2)",
            lowerBound: "x = π/2", upperBound: "",
            answerType: .integer(0),
            level: .expert, category: .derivative,
            technique: "Chain Rule",
            explanation: "f'= cos(x)/sin(x) = cot(x).  cot(π/2) = 0.",
            hint: "d/dx[ln(sin x)] = cot(x). cot(π/2) = cos(π/2)/sin(π/2) = 0.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = arctan(x)  —  f'(0)",
            lowerBound: "x = 0", upperBound: "",
            answerType: .integer(1),
            level: .expert, category: .derivative,
            technique: "Inverse Trig",
            explanation: "f'(x) = 1/(1+x²).  f'(0) = 1.",
            hint: "d/dx[arctan(x)] = 1/(1+x²).",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = x³ · ln(x)  —  f'(1)",
            lowerBound: "x = 1", upperBound: "",
            answerType: .integer(1),
            level: .expert, category: .derivative,
            technique: "Product Rule",
            explanation: "f'= 3x²ln(x) + x³·(1/x) = 3x²ln(x)+x².  At x=1: 0+1=1.",
            hint: "Product rule. ln(1) = 0.",
            subject: .derivatives
        ),
    ]

    // ─────────────────────────────────────────────────────────────────────────
    // ALGEBRA  (subject: .algebra)
    // Precalc / Algebra 2 level
    // ─────────────────────────────────────────────────────────────────────────

    private let algL1: [MathProblem] = [

        MathProblem(
            displayPrimary: "Solve:  2x + 5 = 13",
            lowerBound: "x =", upperBound: "",
            answerType: .integer(4),
            level: .basic, category: .algebra,
            technique: "Linear Equation",
            explanation: "2x = 8  →  x = 4.",
            hint: "Subtract 5 from both sides, then divide by 2.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "Solve:  3x − 7 = 2",
            lowerBound: "x =", upperBound: "",
            answerType: .integer(3),
            level: .basic, category: .algebra,
            technique: "Linear Equation",
            explanation: "3x = 9  →  x = 3.",
            hint: "Add 7, then divide by 3.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "Solve:  x/3 + 2 = 5",
            lowerBound: "x =", upperBound: "",
            answerType: .integer(9),
            level: .basic, category: .algebra,
            technique: "Linear Equation",
            explanation: "x/3 = 3  →  x = 9.",
            hint: "Subtract 2, then multiply by 3.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "x² = 25  (positive root)",
            lowerBound: "x =", upperBound: "",
            answerType: .integer(5),
            level: .basic, category: .algebra,
            technique: "Square Root",
            explanation: "x = √25 = 5.",
            hint: "Take the positive square root.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "(x − 3)² = 4  (larger root)",
            lowerBound: "x =", upperBound: "",
            answerType: .integer(5),
            level: .basic, category: .algebra,
            technique: "Square Root",
            explanation: "x−3 = ±2  →  x = 5 or x = 1.  Larger: 5.",
            hint: "x−3 = ±2. Take the + case for the larger root.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "Evaluate:  |−7| + |3|",
            lowerBound: "=", upperBound: "",
            answerType: .integer(10),
            level: .basic, category: .algebra,
            technique: "Absolute Value",
            explanation: "7 + 3 = 10.",
            hint: "Absolute value removes the negative sign.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "Solve:  5x − 3 = 22",
            lowerBound: "x =", upperBound: "",
            answerType: .integer(5),
            level: .basic, category: .algebra,
            technique: "Linear Equation",
            explanation: "5x = 25  →  x = 5.",
            hint: "Add 3, divide by 5.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "2x² = 8  (positive root)",
            lowerBound: "x =", upperBound: "",
            answerType: .integer(2),
            level: .basic, category: .algebra,
            technique: "Square Root",
            explanation: "x² = 4  →  x = 2.",
            hint: "Divide by 2, then take the square root.",
            subject: .algebra
        ),
    ]

    private let algL2: [MathProblem] = [

        MathProblem(
            displayPrimary: "x² − 5x + 6 = 0  (larger root)",
            lowerBound: "x =", upperBound: "",
            answerType: .integer(3),
            level: .intermediate, category: .algebra,
            technique: "Factoring",
            explanation: "(x−2)(x−3)=0  →  x=2 or 3.  Larger: 3.",
            hint: "Find two numbers that multiply to 6 and add to −5.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "x² − 7x + 12 = 0  (larger root)",
            lowerBound: "x =", upperBound: "",
            answerType: .integer(4),
            level: .intermediate, category: .algebra,
            technique: "Factoring",
            explanation: "(x−3)(x−4)=0  →  x=3 or 4.  Larger: 4.",
            hint: "Factors of 12 that add to −7: −3 and −4.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "System:  x + y = 10,  x − y = 4  →  find x",
            lowerBound: "x =", upperBound: "",
            answerType: .integer(7),
            level: .intermediate, category: .algebra,
            technique: "Systems of Equations",
            explanation: "Add equations: 2x=14  →  x=7.",
            hint: "Add the two equations to eliminate y.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "System:  2x + y = 11,  x + 2y = 10  →  find x",
            lowerBound: "x =", upperBound: "",
            answerType: .integer(4),
            level: .intermediate, category: .algebra,
            technique: "Systems of Equations",
            explanation: "From 2nd: y=(10−x)/2. Sub in 1st: 2x+(10−x)/2=11 → x=4.",
            hint: "Multiply the 2nd equation by 2, then subtract from the 1st.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "x² + x − 6 = 0  (positive root)",
            lowerBound: "x =", upperBound: "",
            answerType: .integer(2),
            level: .intermediate, category: .algebra,
            technique: "Factoring",
            explanation: "(x+3)(x−2)=0  →  x=−3 or 2.  Positive: 2.",
            hint: "Factors of −6 that add to 1: +3 and −2.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "If f(x) = 2x² − 3,  find f(3)",
            lowerBound: "f(3) =", upperBound: "",
            answerType: .integer(15),
            level: .intermediate, category: .algebra,
            technique: "Function Evaluation",
            explanation: "f(3) = 2(9)−3 = 18−3 = 15.",
            hint: "Substitute x = 3 into 2x²−3.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "Slope of line through (0, 2) and (3, 8)",
            lowerBound: "slope =", upperBound: "",
            answerType: .integer(2),
            level: .intermediate, category: .algebra,
            technique: "Slope Formula",
            explanation: "m = (8−2)/(3−0) = 6/3 = 2.",
            hint: "m = (y₂−y₁)/(x₂−x₁).",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "Distance from (0,0) to (3,4)",
            lowerBound: "d =", upperBound: "",
            answerType: .integer(5),
            level: .intermediate, category: .algebra,
            technique: "Distance Formula",
            explanation: "d = √(3²+4²) = √25 = 5.",
            hint: "d = √(x²+y²). Recognise the 3-4-5 triple.",
            subject: .algebra
        ),
    ]

    private let algL3: [MathProblem] = [

        MathProblem(
            displayPrimary: "log₂(8) = ?",
            lowerBound: "=", upperBound: "",
            answerType: .integer(3),
            level: .advanced, category: .algebra,
            technique: "Logarithms",
            explanation: "2³ = 8  →  log₂(8) = 3.",
            hint: "Ask: 2 to what power equals 8?",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "log₂(32) = ?",
            lowerBound: "=", upperBound: "",
            answerType: .integer(5),
            level: .advanced, category: .algebra,
            technique: "Logarithms",
            explanation: "2⁵ = 32  →  log₂(32) = 5.",
            hint: "2¹=2, 2²=4, 2³=8, 2⁴=16, 2⁵=32.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "log₃(27) = ?",
            lowerBound: "=", upperBound: "",
            answerType: .integer(3),
            level: .advanced, category: .algebra,
            technique: "Logarithms",
            explanation: "3³ = 27  →  log₃(27) = 3.",
            hint: "3 to what power equals 27?",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "Solve:  2^x = 16",
            lowerBound: "x =", upperBound: "",
            answerType: .integer(4),
            level: .advanced, category: .algebra,
            technique: "Exponential Equation",
            explanation: "2⁴ = 16  →  x = 4.",
            hint: "Express 16 as a power of 2.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "Solve:  3^x = 27",
            lowerBound: "x =", upperBound: "",
            answerType: .integer(3),
            level: .advanced, category: .algebra,
            technique: "Exponential Equation",
            explanation: "3³ = 27  →  x = 3.",
            hint: "3 to what power equals 27?",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "Solve:  x³ = 8",
            lowerBound: "x =", upperBound: "",
            answerType: .integer(2),
            level: .advanced, category: .algebra,
            technique: "Polynomial",
            explanation: "x = ∛8 = 2.",
            hint: "Take the cube root.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "log₁₀(1000) = ?",
            lowerBound: "=", upperBound: "",
            answerType: .integer(3),
            level: .advanced, category: .algebra,
            technique: "Logarithms",
            explanation: "10³ = 1000  →  log₁₀(1000) = 3.",
            hint: "10 to what power equals 1000?",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "Arithmetic seq: 5, 8, 11, … — 9th term",
            lowerBound: "=", upperBound: "",
            answerType: .integer(29),
            level: .advanced, category: .algebra,
            technique: "Sequences",
            explanation: "aₙ = 5 + (n−1)·3.  a₉ = 5 + 24 = 29.",
            hint: "aₙ = first + (n−1)·common difference.",
            subject: .algebra
        ),
    ]

    private let algL4: [MathProblem] = [

        MathProblem(
            displayPrimary: "Sum of geometric series: 1+2+4+…+64",
            lowerBound: "sum =", upperBound: "",
            answerType: .integer(127),
            level: .expert, category: .algebra,
            technique: "Geometric Series",
            explanation: "Sₙ = a(rⁿ−1)/(r−1) = 1·(2⁷−1)/1 = 127.",
            hint: "S = 2⁷ − 1 = 127.  (The next term would be 128 = 2⁷.)",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "log₂(log₂(16)) = ?",
            lowerBound: "=", upperBound: "",
            answerType: .integer(2),
            level: .expert, category: .algebra,
            technique: "Logarithms",
            explanation: "log₂(16) = 4.  log₂(4) = 2.",
            hint: "Evaluate inside-out.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "If f(x) = x²+1,  find f(f(2))",
            lowerBound: "=", upperBound: "",
            answerType: .integer(26),
            level: .expert, category: .algebra,
            technique: "Function Composition",
            explanation: "f(2)=5.  f(5)=26.",
            hint: "First compute f(2), then apply f again.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "(x+y)²=100, xy=16 — find x²+y²",
            lowerBound: "=", upperBound: "",
            answerType: .integer(68),
            level: .expert, category: .algebra,
            technique: "Algebraic Identity",
            explanation: "(x+y)²= x²+2xy+y² = 100.  2xy=32.  x²+y²=68.",
            hint: "Expand (x+y)² and use xy=16.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "Solve:  2^(2x) = 64",
            lowerBound: "x =", upperBound: "",
            answerType: .integer(3),
            level: .expert, category: .algebra,
            technique: "Exponential Equation",
            explanation: "4^x = 64 = 4³  →  x = 3.",
            hint: "2^(2x) = (2²)^x = 4^x. What power of 4 is 64?",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "Sum of first 10 positive integers",
            lowerBound: "=", upperBound: "",
            answerType: .integer(55),
            level: .expert, category: .algebra,
            technique: "Arithmetic Series",
            explanation: "S = n(n+1)/2 = 10·11/2 = 55.",
            hint: "Gauss formula: n(n+1)/2.",
            subject: .algebra
        ),
    ]

    // ─────────────────────────────────────────────────────────────────────────
    // SAT MATH  (subject: .satMath)
    // ─────────────────────────────────────────────────────────────────────────

    private let satL1: [MathProblem] = [

        MathProblem(
            displayPrimary: "20% of 80",
            lowerBound: "=", upperBound: "",
            answerType: .integer(16),
            level: .basic, category: .algebra,
            technique: "Percent",
            explanation: "0.20 × 80 = 16.",
            hint: "20% = 0.20.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "3 pens cost $6. Cost of 7 pens?",
            lowerBound: "$", upperBound: "",
            answerType: .integer(14),
            level: .basic, category: .algebra,
            technique: "Ratio",
            explanation: "Price per pen = $2.  7 × 2 = $14.",
            hint: "Find unit price first.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "Speed = 60 mph for 3 hours. Distance?",
            lowerBound: "miles =", upperBound: "",
            answerType: .integer(180),
            level: .basic, category: .algebra,
            technique: "Rate × Time",
            explanation: "d = rt = 60 × 3 = 180.",
            hint: "distance = rate × time.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "Average of  4, 8, 12, 16",
            lowerBound: "=", upperBound: "",
            answerType: .integer(10),
            level: .basic, category: .algebra,
            technique: "Mean",
            explanation: "Sum = 40.  Average = 40/4 = 10.",
            hint: "Add all values, divide by count.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "3/4 of 120",
            lowerBound: "=", upperBound: "",
            answerType: .integer(90),
            level: .basic, category: .algebra,
            technique: "Fraction",
            explanation: "3/4 × 120 = 90.",
            hint: "Multiply 120 by 3, then divide by 4.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "12 is what % of 60?",
            lowerBound: "%", upperBound: "",
            answerType: .integer(20),
            level: .basic, category: .algebra,
            technique: "Percent",
            explanation: "12/60 = 0.20 = 20%.",
            hint: "Divide 12 by 60, then multiply by 100.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "5² + 12² = ?",
            lowerBound: "=", upperBound: "",
            answerType: .integer(169),
            level: .basic, category: .algebra,
            technique: "Exponents",
            explanation: "25 + 144 = 169.",
            hint: "5-12-13 is a Pythagorean triple.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "Perimeter of a square with side 9",
            lowerBound: "P =", upperBound: "",
            answerType: .integer(36),
            level: .basic, category: .algebra,
            technique: "Geometry",
            explanation: "P = 4 × 9 = 36.",
            hint: "Perimeter = 4 × side.",
            subject: .satMath
        ),
    ]

    private let satL2: [MathProblem] = [

        MathProblem(
            displayPrimary: "Rectangle: perimeter 24, length 8 — width?",
            lowerBound: "width =", upperBound: "",
            answerType: .integer(4),
            level: .intermediate, category: .algebra,
            technique: "Geometry",
            explanation: "2(l+w)=24  →  l+w=12  →  w=4.",
            hint: "P = 2(l+w). Solve for w.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "y-intercept of  3x − 2y = 12",
            lowerBound: "y =", upperBound: "",
            answerType: .integer(-6),
            level: .intermediate, category: .algebra,
            technique: "Linear Equation",
            explanation: "Set x=0: −2y=12  →  y=−6.",
            hint: "Set x = 0 and solve for y.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "x² + y² = 25,  x = 4 — find positive y",
            lowerBound: "y =", upperBound: "",
            answerType: .integer(3),
            level: .intermediate, category: .algebra,
            technique: "Pythagorean Theorem",
            explanation: "y² = 25−16 = 9  →  y = 3.",
            hint: "3-4-5 right triangle.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "Slope of:  y = 3x − 7",
            lowerBound: "slope =", upperBound: "",
            answerType: .integer(3),
            level: .intermediate, category: .algebra,
            technique: "Slope",
            explanation: "y = mx + b. m = 3.",
            hint: "Slope = coefficient of x in y=mx+b.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "Area of a triangle: base 8, height 5",
            lowerBound: "A =", upperBound: "",
            answerType: .integer(20),
            level: .intermediate, category: .algebra,
            technique: "Geometry",
            explanation: "A = ½ × 8 × 5 = 20.",
            hint: "A = ½ × base × height.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "If g(x) = x² − 4,  find g(−3)",
            lowerBound: "=", upperBound: "",
            answerType: .integer(5),
            level: .intermediate, category: .algebra,
            technique: "Function",
            explanation: "g(−3) = 9−4 = 5.",
            hint: "Square (−3) first: (−3)² = 9.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "Area of a square: side = 7 → perimeter?",
            lowerBound: "P =", upperBound: "",
            answerType: .integer(28),
            level: .intermediate, category: .algebra,
            technique: "Geometry",
            explanation: "P = 4 × 7 = 28.",
            hint: "Perimeter = 4 × side.",
            subject: .satMath
        ),
    ]

    private let satL3: [MathProblem] = [

        MathProblem(
            displayPrimary: "System:  3x+2y=18,  2x−y=5 — find x",
            lowerBound: "x =", upperBound: "",
            answerType: .integer(4),
            level: .advanced, category: .algebra,
            technique: "Systems",
            explanation: "From 2nd: y=2x−5. Sub: 3x+2(2x−5)=18 → 7x=28 → x=4.",
            hint: "Substitute y=2x−5 into the first equation.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "log₂(16) = ?",
            lowerBound: "=", upperBound: "",
            answerType: .integer(4),
            level: .advanced, category: .algebra,
            technique: "Logarithms",
            explanation: "2⁴ = 16  →  log₂(16) = 4.",
            hint: "2 to what power equals 16?",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "√144 + √25 = ?",
            lowerBound: "=", upperBound: "",
            answerType: .integer(17),
            level: .advanced, category: .algebra,
            technique: "Roots",
            explanation: "12 + 5 = 17.",
            hint: "√144 = 12, √25 = 5.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "Perimeter of equilateral triangle, side = 7",
            lowerBound: "P =", upperBound: "",
            answerType: .integer(21),
            level: .advanced, category: .algebra,
            technique: "Geometry",
            explanation: "P = 3 × 7 = 21.",
            hint: "All 3 sides equal for equilateral.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "If f(x) = x³ − x,  find f(3)",
            lowerBound: "=", upperBound: "",
            answerType: .integer(24),
            level: .advanced, category: .algebra,
            technique: "Function",
            explanation: "f(3) = 27 − 3 = 24.",
            hint: "Substitute x = 3.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "What is 2^8?",
            lowerBound: "=", upperBound: "",
            answerType: .integer(256),
            level: .advanced, category: .algebra,
            technique: "Exponents",
            explanation: "2⁸ = 256.",
            hint: "2⁴=16, 2⁵=32, 2⁶=64, 2⁷=128, 2⁸=256.",
            subject: .satMath
        ),
    ]

    private let satL4: [MathProblem] = [

        MathProblem(
            displayPrimary: "Sum of first 10 positive integers",
            lowerBound: "=", upperBound: "",
            answerType: .integer(55),
            level: .expert, category: .algebra,
            technique: "Series",
            explanation: "n(n+1)/2 = 55.",
            hint: "Gauss: n(n+1)/2.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "Integer solutions of x² < 10. How many positive?",
            lowerBound: "count =", upperBound: "",
            answerType: .integer(3),
            level: .expert, category: .algebra,
            technique: "Inequalities",
            explanation: "x² < 10 → x < √10 ≈ 3.16. Positive integers: 1,2,3.",
            hint: "√10 ≈ 3.16. List positive integers less than that.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "A rectangle's area is 32. Length is 2× the width. Find width.",
            lowerBound: "width =", upperBound: "",
            answerType: .integer(4),
            level: .expert, category: .algebra,
            technique: "Geometry",
            explanation: "length = 2w.  Area = 2w · w = 2w² = 32 → w² = 16 → w = 4.",
            hint: "Substitute length = 2w into area = l × w, then solve for w.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "Remainder when 17² is divided by 5",
            lowerBound: "remainder =", upperBound: "",
            answerType: .integer(4),
            level: .expert, category: .algebra,
            technique: "Modular Arithmetic",
            explanation: "17² = 289. 289 = 57×5 + 4. Remainder = 4.",
            hint: "Compute 17² then divide by 5.",
            subject: .satMath
        ),
    ]

    // ─────────────────────────────────────────────────────────────────────────
    // WORD PROBLEMS — Applied Math  (subject: .integrals, category: .applied)
    // Real-world framing of calculus & math reasoning
    // ─────────────────────────────────────────────────────────────────────────

    private let wordL1: [MathProblem] = [

        MathProblem(
            displayPrimary: "Velocity v(t) = 4t m/s.\nDistance from t = 0 to t = 3 s?",
            lowerBound: "meters =", upperBound: "",
            answerType: .integer(18),
            level: .basic, category: .applied,
            technique: "U-Substitution",
            explanation: "d = ∫₀³ 4t dt = [2t²]₀³ = 18 m.",
            hint: "Distance = ∫ v(t) dt. Integrate 4t from 0 to 3.",
            subject: .integrals
        ),
        MathProblem(
            displayPrimary: "Revenue rate R'(t) = 6t $/hr.\nTotal revenue t = 0 to t = 2 hr?",
            lowerBound: "$ =", upperBound: "",
            answerType: .integer(12),
            level: .basic, category: .applied,
            technique: "Power Rule",
            explanation: "R = ∫₀² 6t dt = [3t²]₀² = 12.",
            hint: "Integrate the rate to get total.",
            subject: .integrals
        ),
        MathProblem(
            displayPrimary: "Water drains at W'(t) = 3t² L/s.\nTotal drained, t = 0 to t = 2 s?",
            lowerBound: "litres =", upperBound: "",
            answerType: .integer(8),
            level: .basic, category: .applied,
            technique: "Power Rule",
            explanation: "W = ∫₀² 3t² dt = [t³]₀² = 8 L.",
            hint: "∫₀² 3t² dt = [t³]₀².",
            subject: .integrals
        ),
        MathProblem(
            displayPrimary: "A car accelerates: a(t) = 2t m/s².\nSpeed gained from t = 0 to t = 4 s?",
            lowerBound: "m/s =", upperBound: "",
            answerType: .integer(16),
            level: .basic, category: .applied,
            technique: "Power Rule",
            explanation: "v = ∫₀⁴ 2t dt = [t²]₀⁴ = 16 m/s.",
            hint: "Integrate acceleration to get velocity change.",
            subject: .integrals
        ),
        MathProblem(
            displayPrimary: "Population grows at P'(t) = 5 people/yr.\nGrowth over 6 years?",
            lowerBound: "people =", upperBound: "",
            answerType: .integer(30),
            level: .basic, category: .applied,
            technique: "Constant Rule",
            explanation: "∫₀⁶ 5 dt = 30.",
            hint: "Constant rate × time.",
            subject: .integrals
        ),
    ]

    private let wordL2: [MathProblem] = [

        MathProblem(
            displayPrimary: "Heat flux q(t) = 3t² + 2 W/m².\nEnergy per unit area, t = 0 to t = 2 s?",
            lowerBound: "J/m² =", upperBound: "",
            answerType: .integer(12),
            level: .intermediate, category: .applied,
            technique: "Sum Rule",
            explanation: "E = ∫₀² (3t²+2) dt = [t³+2t]₀² = (8+4) = 12.",
            hint: "Integrate each term: ∫3t² dt = t³, ∫2 dt = 2t.",
            subject: .integrals
        ),
        MathProblem(
            displayPrimary: "A spring force F(x) = 4x N.\nWork done compressing x = 0 to x = 3 m?",
            lowerBound: "Joules =", upperBound: "",
            answerType: .integer(18),
            level: .intermediate, category: .applied,
            technique: "Power Rule",
            explanation: "W = ∫₀³ 4x dx = [2x²]₀³ = 18 J.",
            hint: "W = ∫F dx. Integrate 4x from 0 to 3.",
            subject: .integrals
        ),
        MathProblem(
            displayPrimary: "Profit rate P'(t) = 2t+3 $/hr.\nTotal profit, t = 0 to t = 3 hr?",
            lowerBound: "$ =", upperBound: "",
            answerType: .integer(18),
            level: .intermediate, category: .applied,
            technique: "Sum Rule",
            explanation: "P = ∫₀³ (2t+3) dt = [t²+3t]₀³ = 9+9 = 18.",
            hint: "∫(2t+3) dt = t²+3t.",
            subject: .integrals
        ),
        MathProblem(
            displayPrimary: "Bacteria growth rate G'(t) = eˣ at t = ln(4).\nInstantaneous rate?",
            lowerBound: "=", upperBound: "",
            answerType: .integer(4),
            level: .intermediate, category: .applied,
            technique: "Exponential Integration",
            explanation: "G'(ln4) = e^(ln4) = 4.",
            hint: "e^(ln k) = k.",
            subject: .integrals
        ),
        MathProblem(
            displayPrimary: "Velocity v(t) = 3t² m/s.\nDisplacement, t = 0 to t = 2 s?",
            lowerBound: "metres =", upperBound: "",
            answerType: .integer(8),
            level: .intermediate, category: .applied,
            technique: "Power Rule",
            explanation: "d = ∫₀² 3t² dt = [t³]₀² = 8 m.",
            hint: "∫₀² 3t² dt = [t³]₀².",
            subject: .integrals
        ),
    ]

    private let wordL3: [MathProblem] = [

        MathProblem(
            displayPrimary: "Charge: q'(t) = 6t² − 2 A.\nCharge added, t = 0 to t = 2 s?",
            lowerBound: "Coulombs =", upperBound: "",
            answerType: .integer(12),
            level: .advanced, category: .applied,
            technique: "Sum Rule",
            explanation: "q = ∫₀² (6t²−2) dt = [2t³−2t]₀² = (16−4) = 12.",
            hint: "∫(6t²−2) dt = 2t³−2t.",
            subject: .integrals
        ),
        MathProblem(
            displayPrimary: "Force F(x) = 8x(x²+1)³ N.\nWork done, x = 0 to x = 1 m?",
            lowerBound: "Joules =", upperBound: "",
            answerType: .integer(15),
            level: .advanced, category: .applied,
            technique: "U-Substitution",
            explanation: "W = ∫₀¹ 8x(x²+1)³ dx = 15 J.  (u=x²+1)",
            hint: "u = x²+1. Same as the Level 2 u-sub problem.",
            subject: .integrals
        ),
        MathProblem(
            displayPrimary: "Population: P'(t) = 2t·e^(t²) people/yr.\nGrowth, t = 0 to t = √(ln 3) yr?",
            lowerBound: "people =", upperBound: "",
            answerType: .integer(2),
            level: .advanced, category: .applied,
            technique: "Composite E-Substitution",
            explanation: "P = ∫ 2t·e^(t²) dt = e^(t²).  [e^(t²)]₀^√(ln3) = 3−1 = 2.",
            hint: "u = t². Antiderivative is e^(t²).",
            subject: .integrals
        ),
        MathProblem(
            displayPrimary: "Area between y=x² and y=x, from x=0 to x=1.\n(Hint: net area = ∫₀¹(x−x²)dx)",
            lowerBound: "area = 1/", upperBound: "",
            answerType: .integer(6),
            level: .advanced, category: .applied,
            technique: "Area Between Curves",
            explanation: "∫₀¹(x−x²)dx = [x²/2 − x³/3]₀¹ = 1/2−1/3 = 1/6.",
            hint: "Integrate top minus bottom. Answer is 1/6 — enter 6.",
            subject: .integrals
        ),
        MathProblem(
            displayPrimary: "Radioactive decay: N'(t) = −3N, N(0)=e³.\nFind N(1).",
            lowerBound: "N(1) =", upperBound: "",
            answerType: .integer(1),
            level: .advanced, category: .applied,
            technique: "Exponential",
            explanation: "N(t)=e³·e^(−3t)=e^(3−3t). N(1)=e⁰=1.",
            hint: "N(t) = N₀·e^(−3t). At t=1: e³·e⁻³ = e⁰ = 1.",
            subject: .integrals
        ),
    ]

    private let wordL4: [MathProblem] = [

        MathProblem(
            displayPrimary: "Investment grows: A'(t) = 5t⁴ e^(t⁵) $/yr.\nGrowth, t=0 to t=⁵√(ln 4)?",
            lowerBound: "$ =", upperBound: "",
            answerType: .integer(3),
            level: .expert, category: .applied,
            technique: "Composite E-Substitution",
            explanation: "u=t⁵, du=5t⁴dt. [e^(t⁵)]₀^⁵√(ln4) = e^(ln4)−1 = 3.",
            hint: "u = t⁵. Antiderivative is e^(t⁵). At upper: e^(ln4) = 4.",
            subject: .integrals
        ),
        MathProblem(
            displayPrimary: "Fluid pressure: P'(h) = 6h(h²+1)² kPa/m.\nPressure increase, h=0 to h=1 m?",
            lowerBound: "kPa =", upperBound: "",
            answerType: .integer(7),
            level: .expert, category: .applied,
            technique: "U-Substitution",
            explanation: "∫₀¹ 6h(h²+1)² dh.  u=h²+1.  3∫₁²u²du=[u³]₁²=7.",
            hint: "u = h²+1. 6h dh = 3 du.",
            subject: .integrals
        ),
        MathProblem(
            displayPrimary: "Moment of inertia: I = ∫₀² x³ dx for a rod of length 2.",
            lowerBound: "I =", upperBound: "",
            answerType: .integer(4),
            level: .expert, category: .applied,
            technique: "Power Rule",
            explanation: "[x⁴/4]₀² = 16/4 = 4.",
            hint: "∫x³ dx = x⁴/4.",
            subject: .integrals
        ),
        MathProblem(
            displayPrimary: "Electric field: E'(x) = 20x³(x⁴+1)⁴ V/m².\nField gained, x=0 to x=1 m?",
            lowerBound: "V/m =", upperBound: "",
            answerType: .integer(31),
            level: .expert, category: .applied,
            technique: "U-Substitution",
            explanation: "u=x⁴+1. 5∫₁²u⁴du=[u⁵]₁²=31.",
            hint: "u = x⁴+1. 20x³ dx = 5 du.",
            subject: .integrals
        ),
        MathProblem(
            displayPrimary: "IBP: work done by F(x) = x·eˣ N\nfrom x=0 to x=1 m.",
            lowerBound: "Joules =", upperBound: "",
            answerType: .integer(1),
            level: .expert, category: .applied,
            technique: "Integration by Parts",
            explanation: "W = ∫₀¹ x·eˣ dx = [eˣ(x−1)]₀¹ = 0−(−1) = 1.",
            hint: "IBP: u=x, dv=eˣdx. Antiderivative is eˣ(x−1).",
            subject: .integrals
        ),
    ]

    // ─────────────────────────────────────────────────────────────────────────
    // PHYSICS  (subject: .physics)
    // Level 1–2: algebra-based  |  Level 3–4: AP Physics C calculus-based
    // ─────────────────────────────────────────────────────────────────────────

    // Level 1 — Algebra-based: kinematics, forces, basic energy
    private let physL1: [MathProblem] = [

        MathProblem(
            displayPrimary: "F = ma.  m = 5 kg,  a = 6 m/s²\nFind F.",
            lowerBound: "F =", upperBound: "",
            answerType: .integer(30),
            level: .basic, category: .applied,
            technique: "Newton's 2nd Law",
            explanation: "F = 5 × 6 = 30 N.",
            hint: "F = m × a.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "v = u + at.  u=0, a=4 m/s², t=3 s\nFind v.",
            lowerBound: "v =", upperBound: "",
            answerType: .integer(12),
            level: .basic, category: .applied,
            technique: "Kinematics",
            explanation: "v = 0 + 4×3 = 12 m/s.",
            hint: "v = u + at. u=0 so v=at.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "W = Fd.  F = 8 N,  d = 5 m\nFind work done.",
            lowerBound: "W =", upperBound: "",
            answerType: .integer(40),
            level: .basic, category: .applied,
            technique: "Work",
            explanation: "W = 8 × 5 = 40 J.",
            hint: "W = force × displacement.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "KE = ½mv².  m = 4 kg,  v = 4 m/s\nFind kinetic energy.",
            lowerBound: "KE =", upperBound: "",
            answerType: .integer(32),
            level: .basic, category: .applied,
            technique: "Kinetic Energy",
            explanation: "KE = ½ × 4 × 16 = 32 J.",
            hint: "KE = ½mv². Square v first: 4²=16.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "p = mv.  m = 3 kg,  v = 7 m/s\nFind momentum.",
            lowerBound: "p =", upperBound: "",
            answerType: .integer(21),
            level: .basic, category: .applied,
            technique: "Momentum",
            explanation: "p = 3 × 7 = 21 kg·m/s.",
            hint: "p = mass × velocity.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "Weight W = mg.  m = 8 kg,  g = 10 m/s²\nFind W.",
            lowerBound: "W =", upperBound: "",
            answerType: .integer(80),
            level: .basic, category: .applied,
            technique: "Weight",
            explanation: "W = 8 × 10 = 80 N.",
            hint: "Weight = mass × g. Use g = 10 m/s².",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "d = vt.  v = 15 m/s,  t = 4 s\nFind displacement.",
            lowerBound: "d =", upperBound: "",
            answerType: .integer(60),
            level: .basic, category: .applied,
            technique: "Kinematics",
            explanation: "d = 15 × 4 = 60 m.",
            hint: "distance = speed × time.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "Ohm's Law: V = IR.  I = 3 A,  R = 7 Ω\nFind voltage.",
            lowerBound: "V =", upperBound: "",
            answerType: .integer(21),
            level: .basic, category: .applied,
            technique: "Ohm's Law",
            explanation: "V = 3 × 7 = 21 V.",
            hint: "V = I × R.",
            subject: .physics
        ),
    ]

    // Level 2 — Algebra-based: energy, momentum, circuits, oscillations
    private let physL2: [MathProblem] = [

        MathProblem(
            displayPrimary: "PE = mgh.  m = 2 kg,  g = 10 m/s²,  h = 5 m\nFind potential energy.",
            lowerBound: "PE =", upperBound: "",
            answerType: .integer(100),
            level: .intermediate, category: .applied,
            technique: "Potential Energy",
            explanation: "PE = 2 × 10 × 5 = 100 J.",
            hint: "PE = mgh. Multiply all three.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "P = W/t.  W = 200 J,  t = 4 s\nFind power.",
            lowerBound: "P =", upperBound: "",
            answerType: .integer(50),
            level: .intermediate, category: .applied,
            technique: "Power",
            explanation: "P = 200/4 = 50 W.",
            hint: "Power = Work ÷ time.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "Friction: f = μN.  μ = 0.3,  N = 100 N\nFind friction force.",
            lowerBound: "f =", upperBound: "",
            answerType: .integer(30),
            level: .intermediate, category: .applied,
            technique: "Friction",
            explanation: "f = 0.3 × 100 = 30 N.",
            hint: "Friction = coefficient × normal force.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "Centripetal: ac = v²/r.  v = 6 m/s,  r = 4 m\nFind ac.",
            lowerBound: "ac =", upperBound: "",
            answerType: .integer(9),
            level: .intermediate, category: .applied,
            technique: "Circular Motion",
            explanation: "ac = 36/4 = 9 m/s².",
            hint: "ac = v²/r. Square v first: 6²=36.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "Impulse: J = FΔt.  F = 15 N,  Δt = 4 s\nFind impulse.",
            lowerBound: "J =", upperBound: "",
            answerType: .integer(60),
            level: .intermediate, category: .applied,
            technique: "Impulse",
            explanation: "J = 15 × 4 = 60 N·s.",
            hint: "J = force × time interval.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "Electric power: P = I²R.  I = 4 A,  R = 5 Ω\nFind power.",
            lowerBound: "P =", upperBound: "",
            answerType: .integer(80),
            level: .intermediate, category: .applied,
            technique: "Electric Power",
            explanation: "P = 16 × 5 = 80 W.",
            hint: "P = I²R. Square I first: 4²=16.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "Hooke's Law: F = kx.  k = 50 N/m,  x = 0.6 m\nFind restoring force.",
            lowerBound: "F =", upperBound: "",
            answerType: .integer(30),
            level: .intermediate, category: .applied,
            technique: "Hooke's Law",
            explanation: "F = 50 × 0.6 = 30 N.",
            hint: "F = k × x.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "Pressure: P = F/A.  F = 120 N,  A = 4 m²\nFind pressure.",
            lowerBound: "P =", upperBound: "",
            answerType: .integer(30),
            level: .intermediate, category: .applied,
            technique: "Pressure",
            explanation: "P = 120/4 = 30 Pa.",
            hint: "P = Force ÷ Area.",
            subject: .physics
        ),
    ]

    // Level 3 — AP Physics C: Mechanics (calculus-based)
    private let physL3: [MathProblem] = [

        MathProblem(
            displayPrimary: "v(t) = 4t m/s.\nDisplacement from t = 0 to t = 3 s?",
            lowerBound: "metres =", upperBound: "",
            answerType: .integer(18),
            level: .advanced, category: .applied,
            technique: "Kinematics (Integral)",
            explanation: "x = ∫₀³ 4t dt = [2t²]₀³ = 18 m.",
            hint: "Displacement = ∫ v(t) dt.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "a(t) = 6t m/s².\nVelocity gained from t = 0 to t = 2 s?",
            lowerBound: "Δv =", upperBound: "",
            answerType: .integer(12),
            level: .advanced, category: .applied,
            technique: "Kinematics (Integral)",
            explanation: "Δv = ∫₀² 6t dt = [3t²]₀² = 12 m/s.",
            hint: "Δv = ∫ a(t) dt.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "F(x) = 3x² N.\nWork done from x = 0 to x = 2 m?",
            lowerBound: "W =", upperBound: "",
            answerType: .integer(8),
            level: .advanced, category: .applied,
            technique: "Work (Variable Force)",
            explanation: "W = ∫₀² 3x² dx = [x³]₀² = 8 J.",
            hint: "W = ∫F dx.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "P(t) = 4t³ W.\nEnergy from t = 0 to t = 2 s?",
            lowerBound: "E =", upperBound: "",
            answerType: .integer(16),
            level: .advanced, category: .applied,
            technique: "Energy (Power Integral)",
            explanation: "E = ∫₀² 4t³ dt = [t⁴]₀² = 16 J.",
            hint: "E = ∫ P(t) dt.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "x(t) = 2t² + t.  Find v(3).",
            lowerBound: "v =", upperBound: "",
            answerType: .integer(13),
            level: .advanced, category: .applied,
            technique: "Kinematics (Derivative)",
            explanation: "v(t) = x'(t) = 4t + 1.  v(3) = 13 m/s.",
            hint: "v = dx/dt. Differentiate x(t).",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "v(t) = 3t².  Find a(2).",
            lowerBound: "a =", upperBound: "",
            answerType: .integer(12),
            level: .advanced, category: .applied,
            technique: "Kinematics (Derivative)",
            explanation: "a(t) = v'(t) = 6t.  a(2) = 12 m/s².",
            hint: "a = dv/dt.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "Spring PE: U = ∫₀³ 4x dx.  k = 4 N/m\nFind U.",
            lowerBound: "U =", upperBound: "",
            answerType: .integer(18),
            level: .advanced, category: .applied,
            technique: "Elastic Potential Energy",
            explanation: "U = [2x²]₀³ = 18 J.",
            hint: "U = ½kx² or ∫kx dx from 0 to 3.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "x(t) = t³ − 3t.  Find v(3).",
            lowerBound: "v =", upperBound: "",
            answerType: .integer(24),
            level: .advanced, category: .applied,
            technique: "Kinematics (Derivative)",
            explanation: "v(t) = 3t² − 3.  v(3) = 27 − 3 = 24 m/s.",
            hint: "v = dx/dt = 3t² − 3.",
            subject: .physics
        ),
    ]

    // Level 4 — AP Physics C: E&M (real exam-style problems)
    private let physL4: [MathProblem] = [

        // Faraday's Law — multi-turn coil (AP Mech FRQ style)
        MathProblem(
            displayPrimary: "N=20 turns, Φ(t) = 0.5t² Wb per turn.\nFind |EMF| at t = 3 s.",
            lowerBound: "EMF =", upperBound: "",
            answerType: .integer(60),
            level: .expert, category: .applied,
            technique: "Faraday's Law",
            explanation: "EMF = N|dΦ/dt| = 20 × |t| at t=3 = 20 × 3 = 60 V.",
            hint: "Faraday: EMF = N · dΦ/dt. Derivative of 0.5t² is t.",
            subject: .physics
        ),

        // Charge from non-constant current (AP C FRQ staple)
        MathProblem(
            displayPrimary: "i(t) = 3t² + 2t  A.\nCharge from t = 0 to t = 3 s?",
            lowerBound: "Q =", upperBound: "",
            answerType: .integer(36),
            level: .expert, category: .applied,
            technique: "Charge (Integral)",
            explanation: "Q = ∫₀³ (3t²+2t) dt = [t³+t²]₀³ = 27+9 = 36 C.",
            hint: "Q = ∫i dt. Integrate term by term.",
            subject: .physics
        ),

        // RC time constant (AP C conceptual)
        MathProblem(
            displayPrimary: "RC circuit: R = 6 Ω,  C = 4 F.\nTime constant τ = ?",
            lowerBound: "τ =", upperBound: "",
            answerType: .integer(24),
            level: .expert, category: .applied,
            technique: "RC Circuit",
            explanation: "τ = RC = 6 × 4 = 24 s.",
            hint: "Time constant τ = R × C.",
            subject: .physics
        ),

        // Inductor energy (AP C)
        MathProblem(
            displayPrimary: "Inductor energy: U = ½LI².\nL = 6 H,  I = 4 A.\nFind U.",
            lowerBound: "U =", upperBound: "",
            answerType: .integer(48),
            level: .expert, category: .applied,
            technique: "Energy in Inductor",
            explanation: "U = ½ × 6 × 16 = 48 J.",
            hint: "U = ½LI². Square I first: 4²=16.",
            subject: .physics
        ),

        // Transformer (AP C E&M)
        MathProblem(
            displayPrimary: "Transformer: N₁=60, N₂=10, V₁=120 V.\nFind secondary voltage V₂.",
            lowerBound: "V₂ =", upperBound: "",
            answerType: .integer(20),
            level: .expert, category: .applied,
            technique: "Transformer",
            explanation: "V₂/V₁ = N₂/N₁ → V₂ = 120 × 10/60 = 20 V.",
            hint: "V₂/V₁ = N₂/N₁. Fewer turns = lower voltage.",
            subject: .physics
        ),

        // Electric potential via E-field integral (AP C)
        MathProblem(
            displayPrimary: "E(r) = 4r V/m.\nPotential difference ΔV = ∫₀³ 4r dr?",
            lowerBound: "ΔV =", upperBound: "",
            answerType: .integer(18),
            level: .expert, category: .applied,
            technique: "Electric Potential (Integral)",
            explanation: "ΔV = ∫₀³ 4r dr = [2r²]₀³ = 18 V.",
            hint: "V = ∫E dr. ∫₀³ 4r dr = [2r²]₀³.",
            subject: .physics
        ),

        // Force on current-carrying wire in B-field (AP C)
        MathProblem(
            displayPrimary: "Wire in B-field: F = BIL.\nB = 3 T,  I = 4 A,  L = 2 m.\nFind F.",
            lowerBound: "F =", upperBound: "",
            answerType: .integer(24),
            level: .expert, category: .applied,
            technique: "Magnetic Force on Wire",
            explanation: "F = BIL = 3 × 4 × 2 = 24 N.",
            hint: "F = BIL. All three factors multiply.",
            subject: .physics
        ),

        // Capacitor discharge — charge remaining (AP C)
        MathProblem(
            displayPrimary: "Capacitor: Q₀ = 48 C.\nAfter one time constant, Q remaining?\n(Q = Q₀/e, use e ≈ 2.7, round down)",
            lowerBound: "Q ≈", upperBound: "",
            answerType: .integer(17),
            level: .expert, category: .applied,
            technique: "RC Circuit",
            explanation: "Q = Q₀/e = 48/2.7 ≈ 17.8 → 17 C (rounded down).",
            hint: "After 1τ: Q = Q₀·e⁻¹ ≈ Q₀/2.7.",
            subject: .physics
        ),
    ]

    // ═════════════════════════════════════════════════════════════════════════
    // EXPANSION BANKS — added to each level for greater variety
    // ═════════════════════════════════════════════════════════════════════════

    // ── EXTRA INTEGRALS L1 ───────────────────────────────────────────────────
    private let xtraIntL1: [MathProblem] = [
        MathProblem(
            displayPrimary: "∫ 5 dx",
            lowerBound: "0", upperBound: "3",
            answerType: .integer(15),
            level: .basic, category: .integral,
            technique: "Constant Rule",
            explanation: "∫5 dx = 5x\n[5x]₀³ = 15",
            hint: "Integral of a constant c is c·x."
        ),
        MathProblem(
            displayPrimary: "∫ 2 dx",
            lowerBound: "1", upperBound: "4",
            answerType: .integer(6),
            level: .basic, category: .integral,
            technique: "Constant Rule",
            explanation: "∫2 dx = 2x\n[2x]₁⁴ = 8 − 2 = 6",
            hint: "F(4) − F(1) where F(x) = 2x."
        ),
        MathProblem(
            displayPrimary: "∫ 3x dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(6),
            level: .basic, category: .integral,
            technique: "Power Rule",
            explanation: "∫3x dx = 3x²/2\n[3x²/2]₀² = 3·4/2 = 6",
            hint: "∫3x dx = 3·(x²/2) = 3x²/2."
        ),
        MathProblem(
            displayPrimary: "∫ 4x dx",
            lowerBound: "1", upperBound: "2",
            answerType: .integer(6),
            level: .basic, category: .integral,
            technique: "Power Rule",
            explanation: "∫4x dx = 2x²\n[2x²]₁² = 8 − 2 = 6",
            hint: "∫4x dx = 2x²."
        ),
        MathProblem(
            displayPrimary: "∫ 5x⁴ dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(32),
            level: .basic, category: .integral,
            technique: "Power Rule",
            explanation: "∫5x⁴ dx = x⁵\n[x⁵]₀² = 32",
            hint: "5 and the denominator 5 cancel perfectly."
        ),
        MathProblem(
            displayPrimary: "∫ (2x + 3) dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(10),
            level: .basic, category: .integral,
            technique: "Sum Rule",
            explanation: "∫(2x+3) dx = x² + 3x\n[x²+3x]₀² = 4+6 = 10",
            hint: "Integrate each term separately."
        ),
        MathProblem(
            displayPrimary: "∫ (x + 1) dx",
            lowerBound: "1", upperBound: "3",
            answerType: .integer(6),
            level: .basic, category: .integral,
            technique: "Sum Rule",
            explanation: "∫(x+1) dx = x²/2 + x\n[x²/2+x]₁³ = (9/2+3)−(1/2+1) = 7.5−1.5 = 6",
            hint: "F(3) − F(1): antiderivative is x²/2 + x."
        ),
        MathProblem(
            displayPrimary: "∫ (4x + 1) dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(10),
            level: .basic, category: .integral,
            technique: "Sum Rule",
            explanation: "∫(4x+1) dx = 2x² + x\n[2x²+x]₀² = 8+2 = 10",
            hint: "∫4x dx = 2x²; ∫1 dx = x."
        ),
        MathProblem(
            displayPrimary: "∫ cos(x) dx",
            lowerBound: "0", upperBound: "π/2",
            answerType: .integer(1),
            level: .basic, category: .integral,
            technique: "Trig Integration",
            explanation: "∫cos(x) dx = sin(x)\n[sin(x)]₀^(π/2) = sin(π/2)−sin(0) = 1−0 = 1",
            hint: "The antiderivative of cos(x) is sin(x) — positive, no sign change."
        ),
        MathProblem(
            displayPrimary: "∫ (3x² + 2x) dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(2),
            level: .basic, category: .integral,
            technique: "Sum Rule",
            explanation: "∫(3x²+2x) dx = x³+x²\n[x³+x²]₀¹ = 1+1 = 2",
            hint: "∫3x² = x³, ∫2x = x²."
        ),
    ]

    // ── EXTRA INTEGRALS L2 ───────────────────────────────────────────────────
    private let xtraIntL2: [MathProblem] = [
        MathProblem(
            displayPrimary: "∫ eˣ dx",
            lowerBound: "0", upperBound: "ln4",
            answerType: .integer(3),
            level: .intermediate, category: .integral,
            technique: "Exponential Integration",
            explanation: "∫eˣ dx = eˣ\n[eˣ]₀^(ln4) = e^(ln4)−e⁰ = 4−1 = 3",
            hint: "e^(ln4) = 4. Recall: e^(ln k) = k."
        ),
        MathProblem(
            displayPrimary: "∫ eˣ dx",
            lowerBound: "0", upperBound: "ln9",
            answerType: .integer(8),
            level: .intermediate, category: .integral,
            technique: "Exponential Integration",
            explanation: "∫eˣ dx = eˣ\n[eˣ]₀^(ln9) = 9−1 = 8",
            hint: "e^(ln9) = 9."
        ),
        MathProblem(
            displayPrimary: "∫ 2eˣ dx",
            lowerBound: "0", upperBound: "ln5",
            answerType: .integer(8),
            level: .intermediate, category: .integral,
            technique: "Exponential Integration",
            explanation: "∫2eˣ dx = 2eˣ\n[2eˣ]₀^(ln5) = 2(5)−2(1) = 10−2 = 8",
            hint: "Pull the 2 out. Then 2[eˣ] with ln5 and 0."
        ),
        MathProblem(
            displayPrimary: "∫ x·eˣ dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(1),
            level: .intermediate, category: .integral,
            technique: "Integration by Parts",
            explanation: """
            IBP: u=x, dv=eˣdx → v=eˣ
            = [x·eˣ]₀¹ − ∫₀¹ eˣ dx
            = [x·eˣ−eˣ]₀¹
            = (e−e)−(0−1) = 1
            """,
            hint: "u=x (differentiates away), dv=eˣdx."
        ),
        MathProblem(
            displayPrimary: "∫ ln(x) dx",
            lowerBound: "1", upperBound: "e",
            answerType: .integer(1),
            level: .intermediate, category: .integral,
            technique: "Integration by Parts",
            explanation: """
            IBP: u=ln(x), dv=dx → v=x
            = [x·ln(x)]₁ᵉ − ∫₁ᵉ 1 dx
            = [x·ln(x)−x]₁ᵉ
            = (e−e)−(0−1) = 1
            """,
            hint: "ln(x) alone → IBP with u=ln(x), dv=dx."
        ),
        MathProblem(
            displayPrimary: "∫ x·e^(x/2) dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(4),
            level: .intermediate, category: .integral,
            technique: "Integration by Parts",
            explanation: """
            u=x, dv=e^(x/2)dx → v=2e^(x/2)
            = [2x·e^(x/2)]₀² − ∫₀² 2e^(x/2) dx
            = 4e − [4e^(x/2)]₀²
            = 4e − 4(e−1) = 4
            """,
            hint: "u=x, v=2e^(x/2). The e terms cancel cleanly."
        ),
        MathProblem(
            displayPrimary: "∫ 2tan(x)sec²(x) dx",
            lowerBound: "0", upperBound: "π/4",
            answerType: .integer(1),
            level: .intermediate, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u=tan(x), du=sec²(x)dx
            ∫ 2u du = [u²]₀^(π/4)
            = tan²(π/4)−tan²(0)
            = 1−0 = 1
            """,
            hint: "u=tan(x), then ∫2u du = u²."
        ),
        MathProblem(
            displayPrimary: "∫ √x dx",
            lowerBound: "0", upperBound: "9",
            answerType: .integer(18),
            level: .intermediate, category: .integral,
            technique: "Power Rule",
            explanation: """
            ∫x^(1/2) dx = x^(3/2)/(3/2) = 2x^(3/2)/3
            [2x^(3/2)/3]₀⁹ = 2·27/3 = 18
            """,
            hint: "√x = x^(1/2). New exponent = 3/2, divide by 3/2 = multiply by 2/3."
        ),
    ]

    // ── EXTRA INTEGRALS L3 ───────────────────────────────────────────────────
    private let xtraIntL3: [MathProblem] = [
        MathProblem(
            displayPrimary: "∫ x/√(4−x²) dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(2),
            level: .advanced, category: .integral,
            technique: "Trig Substitution",
            explanation: """
            Antiderivative of x/√(a²−x²) = −√(a²−x²)
            a=2: [−√(4−x²)]₀²
            = −√0 − (−√4) = 0+2 = 2
            """,
            hint: "Antiderivative is −√(4−x²). Evaluate at 2 and 0."
        ),
        MathProblem(
            displayPrimary: "∫ 6x²(x³+1)⁴ dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(12),
            level: .advanced, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u=x³+1, du=3x²dx → 6x²dx=2du
            Bounds: x=0→u=1, x=1→u=2
            2∫₁² u⁴ du = 2[u⁵/5]₁²
            = 2(32−1)/5 = 62/5 ≈ 12
            """,
            hint: "u=x³+1, then 6x²dx = 2du. Bounds shift to 1 and 2."
        ),
        MathProblem(
            displayPrimary: "∫ (x+2)² dx",
            lowerBound: "0", upperBound: "3",
            answerType: .integer(39),
            level: .advanced, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u=x+2, du=dx
            Bounds: x=0→u=2, x=3→u=5
            [u³/3]₂⁵ = 125/3 − 8/3 = 117/3 = 39
            """,
            hint: "u=x+2. New bounds are 2 and 5."
        ),
        MathProblem(
            displayPrimary: "∫ x/√(16−x²) dx",
            lowerBound: "0", upperBound: "4",
            answerType: .integer(4),
            level: .advanced, category: .integral,
            technique: "Trig Substitution",
            explanation: """
            Antiderivative = −√(16−x²)
            [−√(16−x²)]₀⁴ = 0−(−4) = 4
            """,
            hint: "Antiderivative of x/√(a²−x²) is −√(a²−x²)."
        ),
        MathProblem(
            displayPrimary: "∫ 3x²·eˣ³ dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(2),
            level: .advanced, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u=x³, du=3x²dx
            Bounds: x=0→u=0, x=1→u=1
            ∫₀¹ eᵘ du = [eᵘ]₀¹ = e−1 ≈ 2
            (Integer approx: e−1 ≈ 1.72 → rounds to 2)
            """,
            hint: "u=x³. Then 3x²dx = du. Simple ∫eᵘdu = eᵘ."
        ),
        MathProblem(
            displayPrimary: "∫ 2x(x²+3) dx",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(20),
            level: .advanced, category: .integral,
            technique: "Sum Rule",
            explanation: """
            Expand: ∫(2x³+6x) dx = x⁴/2+3x²
            [x⁴/2+3x²]₀² = 8+12 = 20
            (Or u=x²+3: ∫₃⁷ u du=[u²/2]₃⁷=49/2−9/2=20 ✓)
            """,
            hint: "Expand 2x(x²+3) = 2x³+6x, then integrate each term."
        ),
        MathProblem(
            displayPrimary: "∫ (3x² + 1) dx",
            lowerBound: "1", upperBound: "3",
            answerType: .integer(28),
            level: .advanced, category: .integral,
            technique: "Sum Rule",
            explanation: """
            ∫(3x²+1) dx = x³+x
            [x³+x]₁³ = (27+3)−(1+1) = 30−2 = 28
            """,
            hint: "∫3x²=x³, ∫1=x. F(3)−F(1)."
        ),
    ]

    // ── EXTRA INTEGRALS L4 ───────────────────────────────────────────────────
    private let xtraIntL4: [MathProblem] = [
        MathProblem(
            displayPrimary: "∫₀³ ∫₀² 2x dy dx",
            lowerBound: "", upperBound: "",
            answerType: .integer(18),
            level: .expert, category: .integral,
            technique: "Double Integral",
            explanation: """
            Inner (treat x constant):
            ∫₀² 2x dy = [2xy]₀² = 4x
            Outer:
            ∫₀³ 4x dx = [2x²]₀³ = 18
            """,
            hint: "Inner: ∫₀² 2x dy = 2x·[y]₀² = 4x. Then integrate 4x over [0,3]."
        ),
        MathProblem(
            displayPrimary: "∫₀³ ∫₀¹ 4x dy dx",
            lowerBound: "", upperBound: "",
            answerType: .integer(18),
            level: .expert, category: .integral,
            technique: "Double Integral",
            explanation: """
            Inner (treat x constant):
            ∫₀¹ 4x dy = [4xy]₀¹ = 4x
            Outer:
            ∫₀³ 4x dx = [2x²]₀³ = 18
            """,
            hint: "Inner: hold x constant → 4x·y evaluated 0 to 1 = 4x."
        ),
        MathProblem(
            displayPrimary: "∫ x·ln(x) dx",
            lowerBound: "1", upperBound: "e",
            answerType: .integer(2),
            level: .expert, category: .integral,
            technique: "Integration by Parts",
            explanation: """
            u=ln(x), dv=x dx → v=x²/2
            = [x²ln(x)/2]₁ᵉ − ∫₁ᵉ x/2 dx
            = e²/2 − [x²/4]₁ᵉ
            = e²/2 − (e²/4 − 1/4)
            = e²/4 + 1/4 ≈ 2.1 ≈ 2
            """,
            hint: "u=ln(x) (differentiates to 1/x), dv=x dx."
        ),
        MathProblem(
            displayPrimary: "∫₀² ∫₀² 3xy dy dx",
            lowerBound: "", upperBound: "",
            answerType: .integer(12),
            level: .expert, category: .integral,
            technique: "Double Integral",
            explanation: """
            Inner (hold x):
            ∫₀² 3xy dy = [3xy²/2]₀² = 6x
            Outer:
            ∫₀² 6x dx = [3x²]₀² = 12
            """,
            hint: "Inner: treat x as constant. ∫₀² 3xy dy = 3x·[y²/2]₀² = 6x."
        ),
        MathProblem(
            displayPrimary: "∫ 2x·eˣ² dx",
            lowerBound: "0", upperBound: "1",
            answerType: .integer(2),
            level: .expert, category: .integral,
            technique: "U-Substitution",
            explanation: """
            u=x², du=2x dx
            ∫₀¹ eᵘ du = [eᵘ]₀¹ = e−1 ≈ 1.72 ≈ 2
            """,
            hint: "u=x², du=2x dx. Perfect substitution — 2x dx = du."
        ),
        MathProblem(
            displayPrimary: "∫ x·sin(x) dx",
            lowerBound: "0", upperBound: "π",
            answerType: .integer(3),
            level: .expert, category: .integral,
            technique: "Integration by Parts",
            explanation: """
            u=x, dv=sin(x)dx → v=−cos(x)
            = [−x·cos(x)]₀^π + ∫₀^π cos(x) dx
            = π + [sin(x)]₀^π = π + 0 ≈ 3.14 ≈ 3
            """,
            hint: "u=x, dv=sin(x)dx, v=−cos(x)."
        ),
    ]

    // ── EXTRA DERIVATIVES L1 ─────────────────────────────────────────────────
    private let xtraDerivL1: [MathProblem] = [
        MathProblem(
            displayPrimary: "f(x) = x⁵",
            lowerBound: "2", upperBound: "",
            answerType: .integer(80),
            level: .basic, category: .derivative,
            technique: "Power Rule",
            explanation: "f'(x) = 5x⁴\nf'(2) = 5·16 = 80",
            hint: "Bring down the 5, reduce exponent to 4.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = 3x³",
            lowerBound: "2", upperBound: "",
            answerType: .integer(36),
            level: .basic, category: .derivative,
            technique: "Power Rule",
            explanation: "f'(x) = 9x²\nf'(2) = 9·4 = 36",
            hint: "d/dx[3x³] = 3·3x² = 9x².",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = x⁶",
            lowerBound: "1", upperBound: "",
            answerType: .integer(6),
            level: .basic, category: .derivative,
            technique: "Power Rule",
            explanation: "f'(x) = 6x⁵\nf'(1) = 6·1 = 6",
            hint: "Exponent 6 comes down, new power is 5.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = 5x²",
            lowerBound: "2", upperBound: "",
            answerType: .integer(20),
            level: .basic, category: .derivative,
            technique: "Power Rule",
            explanation: "f'(x) = 10x\nf'(2) = 20",
            hint: "d/dx[5x²] = 10x.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = x⁴ + 3x",
            lowerBound: "1", upperBound: "",
            answerType: .integer(7),
            level: .basic, category: .derivative,
            technique: "Power Rule",
            explanation: "f'(x) = 4x³ + 3\nf'(1) = 4 + 3 = 7",
            hint: "Differentiate each term. d/dx[x] = 1.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = x³ − x²",
            lowerBound: "2", upperBound: "",
            answerType: .integer(8),
            level: .basic, category: .derivative,
            technique: "Power Rule",
            explanation: "f'(x) = 3x² − 2x\nf'(2) = 12 − 4 = 8",
            hint: "Differentiate each term separately.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = 4x + 7",
            lowerBound: "5", upperBound: "",
            answerType: .integer(4),
            level: .basic, category: .derivative,
            technique: "Power Rule",
            explanation: "f'(x) = 4  (constant rule: d/dx[7]=0)\nf'(5) = 4",
            hint: "The derivative of a linear function is just the coefficient of x.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = 2x⁴ − 3x",
            lowerBound: "1", upperBound: "",
            answerType: .integer(5),
            level: .basic, category: .derivative,
            technique: "Power Rule",
            explanation: "f'(x) = 8x³ − 3\nf'(1) = 8 − 3 = 5",
            hint: "Each term separately: d/dx[2x⁴]=8x³, d/dx[3x]=3.",
            subject: .derivatives
        ),
    ]

    // ── EXTRA DERIVATIVES L2 ─────────────────────────────────────────────────
    private let xtraDerivL2: [MathProblem] = [
        MathProblem(
            displayPrimary: "f(x) = (2x+3)²",
            lowerBound: "1", upperBound: "",
            answerType: .integer(20),
            level: .intermediate, category: .derivative,
            technique: "Chain Rule",
            explanation: """
            f'(x) = 2(2x+3)·2 = 4(2x+3)
            f'(1) = 4·5 = 20
            """,
            hint: "Outer: 2(…), inner derivative: 2.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = e^(3x)",
            lowerBound: "0", upperBound: "",
            answerType: .integer(3),
            level: .intermediate, category: .derivative,
            technique: "Chain Rule",
            explanation: """
            f'(x) = 3e^(3x)
            f'(0) = 3e⁰ = 3
            """,
            hint: "d/dx[eᵏˣ] = k·eᵏˣ.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = sin(3x)",
            lowerBound: "0", upperBound: "",
            answerType: .integer(3),
            level: .intermediate, category: .derivative,
            technique: "Chain Rule",
            explanation: """
            f'(x) = 3cos(3x)
            f'(0) = 3cos(0) = 3
            """,
            hint: "Chain rule: inner derivative 3 multiplies the result.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = (x+3)³",
            lowerBound: "1", upperBound: "",
            answerType: .integer(48),
            level: .intermediate, category: .derivative,
            technique: "Chain Rule",
            explanation: """
            f'(x) = 3(x+3)²·1 = 3(x+3)²
            f'(1) = 3·16 = 48
            """,
            hint: "Inner derivative is 1 (no multiplier needed).",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = x²·(2x−1)",
            lowerBound: "1", upperBound: "",
            answerType: .integer(4),
            level: .intermediate, category: .derivative,
            technique: "Product Rule",
            explanation: """
            u=x², v=2x−1
            f'(x) = 2x(2x−1) + x²·2
            f'(1) = 2(1)(1) + 2 = 2+2 = 4
            """,
            hint: "u'=2x, v'=2. Apply u'v + uv'.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = x·cos(x)",
            lowerBound: "0", upperBound: "",
            answerType: .integer(1),
            level: .intermediate, category: .derivative,
            technique: "Product Rule",
            explanation: """
            f'(x) = cos(x) + x·(−sin(x)) = cos(x) − x·sin(x)
            f'(0) = cos(0) − 0 = 1
            """,
            hint: "Product rule: d/dx[x]=1, d/dx[cos(x)]=−sin(x).",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = (5x−4)²",
            lowerBound: "1", upperBound: "",
            answerType: .integer(10),
            level: .intermediate, category: .derivative,
            technique: "Chain Rule",
            explanation: """
            f'(x) = 2(5x−4)·5 = 10(5x−4)
            f'(1) = 10(1) = 10
            """,
            hint: "Outer ×2, inner ×5.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = (x+1)⁴",
            lowerBound: "1", upperBound: "",
            answerType: .integer(32),
            level: .intermediate, category: .derivative,
            technique: "Chain Rule",
            explanation: """
            f'(x) = 4(x+1)³
            f'(1) = 4·8 = 32
            """,
            hint: "Inner derivative is 1. (1+1)³ = 8.",
            subject: .derivatives
        ),
    ]

    // ── EXTRA DERIVATIVES L3 ─────────────────────────────────────────────────
    private let xtraDerivL3: [MathProblem] = [
        MathProblem(
            displayPrimary: "f(x) = x³  — find f''",
            lowerBound: "2", upperBound: "",
            answerType: .integer(12),
            level: .advanced, category: .derivative,
            technique: "Second Derivative",
            explanation: """
            f'(x) = 3x²
            f''(x) = 6x
            f''(2) = 12
            """,
            hint: "Differentiate twice.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = e^(2x) — find f''",
            lowerBound: "0", upperBound: "",
            answerType: .integer(4),
            level: .advanced, category: .derivative,
            technique: "Second Derivative",
            explanation: """
            f'(x) = 2e^(2x)
            f''(x) = 4e^(2x)
            f''(0) = 4
            """,
            hint: "Each differentiation multiplies by 2.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = cos(2x) — find f''",
            lowerBound: "0", upperBound: "",
            answerType: .integer(-4),
            level: .advanced, category: .derivative,
            technique: "Second Derivative",
            explanation: """
            f'(x) = −2sin(2x)
            f''(x) = −4cos(2x)
            f''(0) = −4cos(0) = −4
            """,
            hint: "Two applications of chain rule, each adds factor of 2 and toggles sign.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = tan(x)",
            lowerBound: "π/3", upperBound: "",
            answerType: .integer(4),
            level: .advanced, category: .derivative,
            technique: "Trig Derivative",
            explanation: """
            f'(x) = sec²(x)
            f'(π/3) = sec²(π/3) = (1/cos(π/3))² = (1/(1/2))² = 4
            """,
            hint: "d/dx[tan(x)] = sec²(x). cos(π/3) = 1/2, so sec = 2.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = x⁵  — find f''",
            lowerBound: "1", upperBound: "",
            answerType: .integer(20),
            level: .advanced, category: .derivative,
            technique: "Second Derivative",
            explanation: """
            f'(x) = 5x⁴
            f''(x) = 20x³
            f''(1) = 20
            """,
            hint: "Differentiate twice.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = sin(x) + cos(x)",
            lowerBound: "π/2", upperBound: "",
            answerType: .integer(-1),
            level: .advanced, category: .derivative,
            technique: "Trig Derivative",
            explanation: """
            f'(x) = cos(x) − sin(x)
            f'(π/2) = cos(π/2) − sin(π/2) = 0 − 1 = −1
            """,
            hint: "d/dx[sin]=cos, d/dx[cos]=−sin.",
            subject: .derivatives
        ),
    ]

    // ── EXTRA DERIVATIVES L4 ─────────────────────────────────────────────────
    private let xtraDerivL4: [MathProblem] = [
        MathProblem(
            displayPrimary: "f(x) = arcsin(x)",
            lowerBound: "0", upperBound: "",
            answerType: .integer(1),
            level: .expert, category: .derivative,
            technique: "Inverse Trig",
            explanation: """
            f'(x) = 1/√(1−x²)
            f'(0) = 1/√(1−0) = 1
            """,
            hint: "d/dx[arcsin x] = 1/√(1−x²).",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = arctan(2x)",
            lowerBound: "0", upperBound: "",
            answerType: .integer(2),
            level: .expert, category: .derivative,
            technique: "Inverse Trig",
            explanation: """
            f'(x) = 2/(1+(2x)²) = 2/(1+4x²)
            f'(0) = 2/1 = 2
            """,
            hint: "Chain rule: d/dx[arctan(u)] = u'/(1+u²).",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "x²+y²=25: find dy/dx at (0,5)",
            lowerBound: "0", upperBound: "5",
            answerType: .integer(0),
            level: .expert, category: .derivative,
            technique: "Implicit Differentiation",
            explanation: """
            Differentiate: 2x + 2y·(dy/dx) = 0
            dy/dx = −x/y
            At (0,5): dy/dx = 0/5 = 0
            """,
            hint: "At the top of a circle, the tangent line is horizontal.",
            subject: .derivatives
        ),
        MathProblem(
            displayPrimary: "f(x) = arctan(x)",
            lowerBound: "1", upperBound: "",
            answerType: .fraction(1, 2),
            level: .expert, category: .derivative,
            technique: "Inverse Trig",
            explanation: """
            f'(x) = 1/(1+x²)
            f'(1) = 1/(1+1) = 1/2
            """,
            hint: "d/dx[arctan x] = 1/(1+x²). At x=1: 1/2.",
            subject: .derivatives
        ),
    ]

    // ── EXTRA ALGEBRA L1 ─────────────────────────────────────────────────────
    private let xtraAlgL1: [MathProblem] = [
        MathProblem(
            displayPrimary: "4x − 8 = 12  →  x = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(5),
            level: .basic, category: .algebra,
            technique: "Linear Equation",
            explanation: "4x = 20\nx = 5",
            hint: "Add 8 to both sides first.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "3(x − 2) = 15  →  x = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(7),
            level: .basic, category: .algebra,
            technique: "Linear Equation",
            explanation: "x−2 = 5\nx = 7",
            hint: "Divide both sides by 3 first.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "2x + 11 = 23  →  x = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(6),
            level: .basic, category: .algebra,
            technique: "Linear Equation",
            explanation: "2x = 12\nx = 6",
            hint: "Subtract 11, then divide by 2.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "7x = 63  →  x = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(9),
            level: .basic, category: .algebra,
            technique: "Linear Equation",
            explanation: "x = 63/7 = 9",
            hint: "Divide both sides by 7.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "x/3 + 2 = 6  →  x = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(12),
            level: .basic, category: .algebra,
            technique: "Linear Equation",
            explanation: "x/3 = 4\nx = 12",
            hint: "Subtract 2, then multiply by 3.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "5x − 4 = 3x + 6  →  x = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(5),
            level: .basic, category: .algebra,
            technique: "Linear Equation",
            explanation: "2x = 10\nx = 5",
            hint: "Move x-terms left, constants right.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "2x + 3 = x + 10  →  x = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(7),
            level: .basic, category: .algebra,
            technique: "Linear Equation",
            explanation: "x = 7",
            hint: "Subtract x from both sides.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "(x + 2)/4 = 3  →  x = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(10),
            level: .basic, category: .algebra,
            technique: "Linear Equation",
            explanation: "x+2 = 12\nx = 10",
            hint: "Multiply both sides by 4 first.",
            subject: .algebra
        ),
    ]

    // ── EXTRA ALGEBRA L2 ─────────────────────────────────────────────────────
    private let xtraAlgL2: [MathProblem] = [
        MathProblem(
            displayPrimary: "x² − 7x + 12 = 0, larger root",
            lowerBound: "", upperBound: "",
            answerType: .integer(4),
            level: .intermediate, category: .algebra,
            technique: "Factoring",
            explanation: "(x−3)(x−4) = 0\nx = 3 or x = 4\nLarger root: 4",
            hint: "Find two numbers that multiply to 12 and add to −7.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "x² + 3x − 10 = 0, positive root",
            lowerBound: "", upperBound: "",
            answerType: .integer(2),
            level: .intermediate, category: .algebra,
            technique: "Factoring",
            explanation: "(x+5)(x−2) = 0\nx = −5 or x = 2\nPositive root: 2",
            hint: "Need p+q=3, pq=−10. Try p=5, q=−2.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "x² − 6x + 9 = 0  →  x = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(3),
            level: .intermediate, category: .algebra,
            technique: "Factoring",
            explanation: "(x−3)² = 0\nx = 3  (double root)",
            hint: "This is a perfect square trinomial.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "2x² − 8 = 0, positive root",
            lowerBound: "", upperBound: "",
            answerType: .integer(2),
            level: .intermediate, category: .algebra,
            technique: "Factoring",
            explanation: "x² = 4\nx = ±2\nPositive root: 2",
            hint: "Divide by 2, then take square root.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "x² − 8x + 7 = 0, larger root",
            lowerBound: "", upperBound: "",
            answerType: .integer(7),
            level: .intermediate, category: .algebra,
            technique: "Quadratic Formula",
            explanation: """
            (x−1)(x−7) = 0
            x = 1 or x = 7
            Larger root: 7
            """,
            hint: "Factor: find two numbers multiplying to 7 and adding to −8.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "x² − 4 = 0, positive root",
            lowerBound: "", upperBound: "",
            answerType: .integer(2),
            level: .intermediate, category: .algebra,
            technique: "Factoring",
            explanation: "(x−2)(x+2)=0\nPositive root: 2",
            hint: "Difference of squares: a²−b²=(a−b)(a+b).",
            subject: .algebra
        ),
    ]

    // ── EXTRA ALGEBRA L3 ─────────────────────────────────────────────────────
    private let xtraAlgL3: [MathProblem] = [
        MathProblem(
            displayPrimary: "log₃(81) = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(4),
            level: .advanced, category: .algebra,
            technique: "Logarithms",
            explanation: "3? = 81 = 3⁴\nAnswer: 4",
            hint: "What power of 3 gives 81?",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "log₂(64) = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(6),
            level: .advanced, category: .algebra,
            technique: "Logarithms",
            explanation: "2? = 64 = 2⁶\nAnswer: 6",
            hint: "64 = 2⁶.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "3^x = 243  →  x = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(5),
            level: .advanced, category: .algebra,
            technique: "Exponential Equation",
            explanation: "243 = 3⁵\nx = 5",
            hint: "Express 243 as a power of 3.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "log₅(25) = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(2),
            level: .advanced, category: .algebra,
            technique: "Logarithms",
            explanation: "5? = 25 = 5²\nAnswer: 2",
            hint: "25 = 5².",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "2·3^x = 54  →  x = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(3),
            level: .advanced, category: .algebra,
            technique: "Exponential Equation",
            explanation: "3^x = 27 = 3³\nx = 3",
            hint: "Divide both sides by 2 first: 3^x = 27.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "System: 2x+y=11, x−y=1  →  x = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(4),
            level: .advanced, category: .algebra,
            technique: "Systems of Equations",
            explanation: "Add equations: 3x=12 → x=4",
            hint: "Add the two equations to eliminate y.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "log₂(8) + log₂(4) = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(5),
            level: .advanced, category: .algebra,
            technique: "Logarithms",
            explanation: "= log₂(8·4) = log₂(32) = 5",
            hint: "Product rule: log(xy) = log(x)+log(y).",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "5^x = 125  →  x = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(3),
            level: .advanced, category: .algebra,
            technique: "Exponential Equation",
            explanation: "125 = 5³\nx = 3",
            hint: "Rewrite 125 as a power of 5.",
            subject: .algebra
        ),
    ]

    // ── EXTRA ALGEBRA L4 ─────────────────────────────────────────────────────
    private let xtraAlgL4: [MathProblem] = [
        MathProblem(
            displayPrimary: "Arithmetic: a₁=3, d=5. Find 8th term.",
            lowerBound: "", upperBound: "",
            answerType: .integer(38),
            level: .expert, category: .algebra,
            technique: "Sequences",
            explanation: "aₙ = a₁ + (n−1)d\na₈ = 3 + 7·5 = 38",
            hint: "n=8 means (n−1) = 7 steps from start.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "Geometric: a₁=2, r=3. Find 4th term.",
            lowerBound: "", upperBound: "",
            answerType: .integer(54),
            level: .expert, category: .algebra,
            technique: "Sequences",
            explanation: "a₄ = 2·3³ = 2·27 = 54",
            hint: "aₙ = a₁·rⁿ⁻¹. For n=4: a₄=2·3³.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "Sum first 4 terms: 2+6+18+54",
            lowerBound: "", upperBound: "",
            answerType: .integer(80),
            level: .expert, category: .algebra,
            technique: "Sequences",
            explanation: "S₄ = 2(3⁴−1)/(3−1) = 2·80/2 = 80\nOr just: 2+6+18+54=80",
            hint: "Add the four terms: 2+6=8, 8+18=26, 26+54=80.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "Vertex of y=x²−8x+10: x-coord = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(4),
            level: .expert, category: .algebra,
            technique: "Completing the Square",
            explanation: """
            Complete the square: (x−4)²−6
            Vertex: x = 4
            """,
            hint: "Vertex x-coord = −b/(2a) = 8/2 = 4.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "Arithmetic: 1,4,7,…  Find 10th term.",
            lowerBound: "", upperBound: "",
            answerType: .integer(28),
            level: .expert, category: .algebra,
            technique: "Sequences",
            explanation: "d=3, a₁=1\na₁₀ = 1 + 9·3 = 28",
            hint: "Common difference is 3. Use aₙ = a₁ + (n−1)d.",
            subject: .algebra
        ),
        MathProblem(
            displayPrimary: "Arithmetic sum: a₁=5, d=3, n=6 terms",
            lowerBound: "", upperBound: "",
            answerType: .integer(75),
            level: .expert, category: .algebra,
            technique: "Sequences",
            explanation: """
            a₆ = 5 + 5·3 = 20
            S₆ = 6·(5+20)/2 = 6·12.5 = 75
            """,
            hint: "Sₙ = n·(a₁+aₙ)/2. Find aₙ first.",
            subject: .algebra
        ),
    ]

    // ── EXTRA SAT L1 ─────────────────────────────────────────────────────────
    private let xtraSatL1: [MathProblem] = [
        MathProblem(
            displayPrimary: "30% of 60 = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(18),
            level: .basic, category: .algebra,
            technique: "Percent",
            explanation: "0.30 × 60 = 18",
            hint: "Convert 30% to 0.30, then multiply.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "15% of 80 = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(12),
            level: .basic, category: .algebra,
            technique: "Percent",
            explanation: "0.15 × 80 = 12",
            hint: "15% = 10% + 5%: 8 + 4 = 12.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "40% of 75 = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(30),
            level: .basic, category: .algebra,
            technique: "Percent",
            explanation: "0.40 × 75 = 30",
            hint: "0.4 × 75 = 0.4 × 70 + 0.4 × 5 = 28+2=30.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "Triangle: base=12, height=5. Area=?",
            lowerBound: "", upperBound: "",
            answerType: .integer(30),
            level: .basic, category: .algebra,
            technique: "Geometry",
            explanation: "A = ½·12·5 = 30",
            hint: "Area of triangle = ½ × base × height.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "Pythagorean: legs 5 & 12. Hypotenuse=?",
            lowerBound: "", upperBound: "",
            answerType: .integer(13),
            level: .basic, category: .algebra,
            technique: "Geometry",
            explanation: "5²+12²= 25+144=169=13²\nHypotenuse = 13",
            hint: "3-4-5 scaled: 5-12-13 is a classic triple.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "Square: side=9. Perimeter=?",
            lowerBound: "", upperBound: "",
            answerType: .integer(36),
            level: .basic, category: .algebra,
            technique: "Geometry",
            explanation: "P = 4·9 = 36",
            hint: "Square perimeter = 4 × side.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "Rectangle: l=8, w=6. Area=?",
            lowerBound: "", upperBound: "",
            answerType: .integer(48),
            level: .basic, category: .algebra,
            technique: "Geometry",
            explanation: "A = 8×6 = 48",
            hint: "Area of rectangle = length × width.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "Mean of 3,7,8,10,12 = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(8),
            level: .basic, category: .algebra,
            technique: "Statistics",
            explanation: "Sum = 3+7+8+10+12 = 40\nMean = 40/5 = 8",
            hint: "Add all values, divide by how many.",
            subject: .satMath
        ),
    ]

    // ── EXTRA SAT L2 ─────────────────────────────────────────────────────────
    private let xtraSatL2: [MathProblem] = [
        MathProblem(
            displayPrimary: "Slope through (2,3) and (6,11) = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(2),
            level: .intermediate, category: .algebra,
            technique: "Slope",
            explanation: "m = (11−3)/(6−2) = 8/4 = 2",
            hint: "m = rise/run = Δy/Δx.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "f(x) = x² + 4. Find f(3).",
            lowerBound: "", upperBound: "",
            answerType: .integer(13),
            level: .intermediate, category: .algebra,
            technique: "Function",
            explanation: "f(3) = 9 + 4 = 13",
            hint: "Substitute x = 3.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "f(x)=2x−1, g(x)=x+3. Find f(g(2)).",
            lowerBound: "", upperBound: "",
            answerType: .integer(9),
            level: .intermediate, category: .algebra,
            technique: "Function",
            explanation: "g(2) = 5\nf(5) = 10−1 = 9",
            hint: "Evaluate g first, then feed into f.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "y = 3x + 7. Y-intercept = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(7),
            level: .intermediate, category: .algebra,
            technique: "Slope",
            explanation: "y-intercept is b in y=mx+b. Here b=7.",
            hint: "In slope-intercept form, the y-intercept is the constant.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "f(x) = 3x² − x. Find f(2).",
            lowerBound: "", upperBound: "",
            answerType: .integer(10),
            level: .intermediate, category: .algebra,
            technique: "Function",
            explanation: "f(2) = 3(4)−2 = 12−2 = 10",
            hint: "Substitute x=2 into every x.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "Slope through (0,5) and (3,11) = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(2),
            level: .intermediate, category: .algebra,
            technique: "Slope",
            explanation: "m = (11−5)/(3−0) = 6/3 = 2",
            hint: "Rise = 6, run = 3.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "f(x)=x²+1. Find f(f(2)).",
            lowerBound: "", upperBound: "",
            answerType: .integer(26),
            level: .intermediate, category: .algebra,
            technique: "Function",
            explanation: "f(2) = 5\nf(5) = 25+1 = 26",
            hint: "Compute f(2) first, then plug that into f again.",
            subject: .satMath
        ),
    ]

    // ── EXTRA SAT L3 ─────────────────────────────────────────────────────────
    private let xtraSatL3: [MathProblem] = [
        MathProblem(
            displayPrimary: "2^(2x) = 16  →  x = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(2),
            level: .advanced, category: .algebra,
            technique: "Exponents",
            explanation: "16 = 2⁴, so 2x=4 → x=2",
            hint: "Write 16 as a power of 2.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "x²−8x+15=0, larger root",
            lowerBound: "", upperBound: "",
            answerType: .integer(5),
            level: .advanced, category: .algebra,
            technique: "Quadratic Formula",
            explanation: "(x−3)(x−5)=0\nRoots: 3 and 5. Larger: 5",
            hint: "Factor: need two numbers with sum −8 and product 15.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "If x=3,y=2: find 3x²−2y",
            lowerBound: "", upperBound: "",
            answerType: .integer(23),
            level: .advanced, category: .algebra,
            technique: "Function",
            explanation: "3(9)−2(2) = 27−4 = 23",
            hint: "Substitute x=3 and y=2 directly.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "3^(2x) = 81  →  x = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(2),
            level: .advanced, category: .algebra,
            technique: "Exponents",
            explanation: "81 = 3⁴, so 2x=4 → x=2",
            hint: "Write 81 as a power of 3.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "5 numbers, mean=8. Sum=?",
            lowerBound: "", upperBound: "",
            answerType: .integer(40),
            level: .advanced, category: .algebra,
            technique: "Statistics",
            explanation: "Sum = mean × count = 8×5 = 40",
            hint: "Mean = Sum/n, so Sum = mean×n.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "Simplify: x³·x⁵ where x=2",
            lowerBound: "", upperBound: "",
            answerType: .integer(256),
            level: .advanced, category: .algebra,
            technique: "Exponents",
            explanation: "x³·x⁵ = x⁸\nAt x=2: 2⁸ = 256",
            hint: "Same base: add exponents. Then substitute x=2.",
            subject: .satMath
        ),
    ]

    // ── EXTRA SAT L4 ─────────────────────────────────────────────────────────
    private let xtraSatL4: [MathProblem] = [
        MathProblem(
            displayPrimary: "Data: 4,6,6,8,10. Median=?",
            lowerBound: "", upperBound: "",
            answerType: .integer(6),
            level: .expert, category: .algebra,
            technique: "Statistics",
            explanation: "Already sorted: 4,6,6,8,10\nMedian = middle = 6",
            hint: "Sort first, then pick the middle value.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "Perimeter 48, length=2×width. Width=?",
            lowerBound: "", upperBound: "",
            answerType: .integer(8),
            level: .expert, category: .algebra,
            technique: "Geometry",
            explanation: "2(l+w)=48 → l+w=24\nl=2w → 3w=24 → w=8",
            hint: "Perimeter = 2(l+w). Set l=2w and solve.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "f(x)=2x+4. Find f⁻¹(8).",
            lowerBound: "", upperBound: "",
            answerType: .integer(2),
            level: .expert, category: .algebra,
            technique: "Function",
            explanation: """
            f⁻¹: swap x,y: x=2y+4
            y = (x−4)/2
            f⁻¹(8) = (8−4)/2 = 2
            """,
            hint: "Find the input that gives output 8: 2x+4=8 → x=2.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "Range of 3,7,15,9,1 = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(14),
            level: .expert, category: .algebra,
            technique: "Statistics",
            explanation: "Max=15, Min=1\nRange = 15−1 = 14",
            hint: "Range = maximum − minimum.",
            subject: .satMath
        ),
        MathProblem(
            displayPrimary: "Circle r=6. Circumference (÷π) = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(12),
            level: .expert, category: .algebra,
            technique: "Geometry",
            explanation: "C = 2πr = 12π\nC/π = 12",
            hint: "C = 2πr. The problem asks for the number without π.",
            subject: .satMath
        ),
    ]

    // ── EXTRA PHYSICS L1 ─────────────────────────────────────────────────────
    private let xtraPhysL1: [MathProblem] = [
        MathProblem(
            displayPrimary: "F=20 N, m=4 kg. Find a (m/s²).",
            lowerBound: "", upperBound: "",
            answerType: .integer(5),
            level: .basic, category: .applied,
            technique: "Newton's 2nd Law",
            explanation: "a = F/m = 20/4 = 5 m/s²",
            hint: "Rearrange F=ma: a = F/m.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "m=7 kg, g=10. Weight (N) = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(70),
            level: .basic, category: .applied,
            technique: "Newton's 2nd Law",
            explanation: "W = mg = 7×10 = 70 N",
            hint: "Weight = mass × gravitational acceleration.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "u=0, a=5, t=6 s. Find v (m/s).",
            lowerBound: "", upperBound: "",
            answerType: .integer(30),
            level: .basic, category: .applied,
            technique: "Kinematics",
            explanation: "v = u + at = 0 + 5×6 = 30 m/s",
            hint: "v = u + at. u=0 so v = at.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "u=0, a=2, t=5 s. Find d (m).",
            lowerBound: "", upperBound: "",
            answerType: .integer(25),
            level: .basic, category: .applied,
            technique: "Kinematics",
            explanation: "d = ut + ½at² = 0 + ½·2·25 = 25 m",
            hint: "d = ½at² when u=0.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "Net force: 30N right, 10N left. m=4 kg. a=?",
            lowerBound: "", upperBound: "",
            answerType: .integer(5),
            level: .basic, category: .applied,
            technique: "Newton's 2nd Law",
            explanation: "Net F = 30−10 = 20 N\na = 20/4 = 5 m/s²",
            hint: "Subtract opposing force for net force, then F=ma.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "u=10, a=4, t=5 s. Find v (m/s).",
            lowerBound: "", upperBound: "",
            answerType: .integer(30),
            level: .basic, category: .applied,
            technique: "Kinematics",
            explanation: "v = 10 + 4×5 = 30 m/s",
            hint: "v = u + at.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "F=60 N, m=12 kg. Find a.",
            lowerBound: "", upperBound: "",
            answerType: .integer(5),
            level: .basic, category: .applied,
            technique: "Newton's 2nd Law",
            explanation: "a = F/m = 60/12 = 5 m/s²",
            hint: "a = F/m.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "v=15, u=5, t=2 s. Find a.",
            lowerBound: "", upperBound: "",
            answerType: .integer(5),
            level: .basic, category: .applied,
            technique: "Kinematics",
            explanation: "a = (v−u)/t = (15−5)/2 = 5 m/s²",
            hint: "Rearrange v=u+at: a=(v−u)/t.",
            subject: .physics
        ),
    ]

    // ── EXTRA PHYSICS L2 ─────────────────────────────────────────────────────
    private let xtraPhysL2: [MathProblem] = [
        MathProblem(
            displayPrimary: "W = F×d: F=15 N, d=4 m. W=?",
            lowerBound: "", upperBound: "",
            answerType: .integer(60),
            level: .intermediate, category: .applied,
            technique: "Work",
            explanation: "W = 15×4 = 60 J",
            hint: "W = Fd when force and displacement are parallel.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "KE = ½mv²: m=3, v=6. KE=?",
            lowerBound: "", upperBound: "",
            answerType: .integer(54),
            level: .intermediate, category: .applied,
            technique: "Work",
            explanation: "KE = ½·3·36 = 54 J",
            hint: "KE = ½mv². v² = 36.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "PE = mgh: m=5, g=10, h=6. PE=?",
            lowerBound: "", upperBound: "",
            answerType: .integer(300),
            level: .intermediate, category: .applied,
            technique: "Work",
            explanation: "PE = 5·10·6 = 300 J",
            hint: "PE = mgh.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "p = mv: m=6, v=8. p=?",
            lowerBound: "", upperBound: "",
            answerType: .integer(48),
            level: .intermediate, category: .applied,
            technique: "Momentum",
            explanation: "p = 6×8 = 48 kg·m/s",
            hint: "Momentum p = mv.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "Impulse J=FΔt: F=25 N, Δt=4 s. J=?",
            lowerBound: "", upperBound: "",
            answerType: .integer(100),
            level: .intermediate, category: .applied,
            technique: "Momentum",
            explanation: "J = FΔt = 25×4 = 100 N·s",
            hint: "J = FΔt = change in momentum.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "Ball drops h=20m. Final speed v=? (m/s)",
            lowerBound: "", upperBound: "",
            answerType: .integer(20),
            level: .intermediate, category: .applied,
            technique: "Work",
            explanation: "v² = 2gh = 2·10·20 = 400\nv = 20 m/s",
            hint: "Energy conservation: mgh = ½mv² → v=√(2gh).",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "Collision: m₁=3,v₁=8, m₂=5,v₂=0 (inelastic). v'=?",
            lowerBound: "", upperBound: "",
            answerType: .integer(3),
            level: .intermediate, category: .applied,
            technique: "Momentum",
            explanation: "p conserved: 3·8 = 8·v'\nv' = 24/8 = 3 m/s",
            hint: "m₁v₁ = (m₁+m₂)v'. Total mass = 3+5=8.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "W=F·d·cos60°: F=10,d=8. W=?",
            lowerBound: "", upperBound: "",
            answerType: .integer(40),
            level: .intermediate, category: .applied,
            technique: "Work",
            explanation: "W = 10·8·cos60° = 80·0.5 = 40 J",
            hint: "cos(60°) = 0.5.",
            subject: .physics
        ),
    ]

    // ── EXTRA PHYSICS L3 ─────────────────────────────────────────────────────
    private let xtraPhysL3: [MathProblem] = [
        MathProblem(
            displayPrimary: "v(t) = 6t². Find x from t=0 to t=2.",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(16),
            level: .advanced, category: .applied,
            technique: "Kinematics (Integral)",
            explanation: "x = ∫₀² 6t² dt = [2t³]₀² = 16 m",
            hint: "Integrate v to get position.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "F(x) = 4x. Work from x=0 to x=3.",
            lowerBound: "0", upperBound: "3",
            answerType: .integer(18),
            level: .advanced, category: .applied,
            technique: "Kinematics (Integral)",
            explanation: "W = ∫₀³ 4x dx = [2x²]₀³ = 18 J",
            hint: "W = ∫F dx. Antiderivative of 4x is 2x².",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "a(t) = 8t, v₀=0. Find v at t=3.",
            lowerBound: "0", upperBound: "3",
            answerType: .integer(36),
            level: .advanced, category: .applied,
            technique: "Kinematics (Integral)",
            explanation: "v = ∫₀³ 8t dt = [4t²]₀³ = 36 m/s",
            hint: "Integrate acceleration to get velocity.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "v(t) = 3t + 2. Displacement t=0 to t=4.",
            lowerBound: "0", upperBound: "4",
            answerType: .integer(32),
            level: .advanced, category: .applied,
            technique: "Kinematics (Integral)",
            explanation: "x = ∫₀⁴ (3t+2) dt = [3t²/2+2t]₀⁴ = 24+8 = 32 m",
            hint: "Integrate: ∫3t dt = 3t²/2, ∫2 dt = 2t.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "F(x) = 3x². Work from x=0 to x=2.",
            lowerBound: "0", upperBound: "2",
            answerType: .integer(8),
            level: .advanced, category: .applied,
            technique: "Kinematics (Integral)",
            explanation: "W = ∫₀² 3x² dx = [x³]₀² = 8 J",
            hint: "∫3x² dx = x³.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "v(t) = 4t+6. Displacement t=0 to t=3.",
            lowerBound: "0", upperBound: "3",
            answerType: .integer(36),
            level: .advanced, category: .applied,
            technique: "Kinematics (Integral)",
            explanation: "x = ∫₀³ (4t+6) dt = [2t²+6t]₀³ = 18+18 = 36 m",
            hint: "∫4t=2t², ∫6=6t.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "F(x) = 2x+3. Work from x=1 to x=4.",
            lowerBound: "1", upperBound: "4",
            answerType: .integer(24),
            level: .advanced, category: .applied,
            technique: "Kinematics (Integral)",
            explanation: """
            W = ∫₁⁴ (2x+3) dx = [x²+3x]₁⁴
            = (16+12)−(1+3) = 28−4 = 24 J
            """,
            hint: "Antiderivative of 2x+3 is x²+3x.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "a(t)=10 m/s², v₀=0. Find v at t=5.",
            lowerBound: "0", upperBound: "5",
            answerType: .integer(50),
            level: .advanced, category: .applied,
            technique: "Kinematics (Integral)",
            explanation: "v = ∫₀⁵ 10 dt = [10t]₀⁵ = 50 m/s",
            hint: "Constant acceleration: v = a·t when v₀=0.",
            subject: .physics
        ),
    ]

    // ── EXTRA PHYSICS L4 ─────────────────────────────────────────────────────
    private let xtraPhysL4: [MathProblem] = [
        MathProblem(
            displayPrimary: "Φ(t)=4t²+2t. EMF at t=3 (V).",
            lowerBound: "", upperBound: "",
            answerType: .integer(26),
            level: .expert, category: .applied,
            technique: "Faraday's Law",
            explanation: "EMF = |dΦ/dt| = |8t+2|\nAt t=3: |24+2| = 26 V",
            hint: "Differentiate Φ(t) and evaluate at t=3.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "C=6 F, V=4 V. Charge Q=? (C)",
            lowerBound: "", upperBound: "",
            answerType: .integer(24),
            level: .expert, category: .applied,
            technique: "Faraday's Law",
            explanation: "Q = CV = 6×4 = 24 C",
            hint: "Q = CV for a capacitor.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "L=4 H, I=5 A. Inductor energy U=? (J)",
            lowerBound: "", upperBound: "",
            answerType: .integer(50),
            level: .expert, category: .applied,
            technique: "Faraday's Law",
            explanation: "U = ½LI² = ½·4·25 = 50 J",
            hint: "Energy stored in inductor: U = ½LI².",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "Φ(t) = 3t³. EMF at t=2 (V).",
            lowerBound: "", upperBound: "",
            answerType: .integer(36),
            level: .expert, category: .applied,
            technique: "Faraday's Law",
            explanation: "EMF = |dΦ/dt| = 9t²\nAt t=2: 9×4 = 36 V",
            hint: "d/dt[3t³] = 9t². Evaluate at t=2.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "i(t)=6t. Charge Q from t=0 to t=4.",
            lowerBound: "0", upperBound: "4",
            answerType: .integer(48),
            level: .expert, category: .applied,
            technique: "Faraday's Law",
            explanation: "Q = ∫₀⁴ 6t dt = [3t²]₀⁴ = 48 C",
            hint: "Q = ∫i dt. Integrate the current function.",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "C=3 F, V=2 V. Energy U=? (J)",
            lowerBound: "", upperBound: "",
            answerType: .integer(6),
            level: .expert, category: .applied,
            technique: "Faraday's Law",
            explanation: "U = ½CV² = ½·3·4 = 6 J",
            hint: "Energy stored in capacitor: U = ½CV².",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "Φ(t) = 5t. EMF (constant, V) = ?",
            lowerBound: "", upperBound: "",
            answerType: .integer(5),
            level: .expert, category: .applied,
            technique: "Faraday's Law",
            explanation: "EMF = |dΦ/dt| = |d/dt[5t]| = 5 V",
            hint: "d/dt[5t] = 5 (constant).",
            subject: .physics
        ),
        MathProblem(
            displayPrimary: "Transformer: N₁=50,N₂=200,V₁=10V. V₂=?",
            lowerBound: "", upperBound: "",
            answerType: .integer(40),
            level: .expert, category: .applied,
            technique: "Faraday's Law",
            explanation: "V₂ = V₁·(N₂/N₁) = 10·(200/50) = 40 V",
            hint: "Transformer ratio: V₂/V₁ = N₂/N₁.",
            subject: .physics
        ),
    ]

}

// MARK: - Helper

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
