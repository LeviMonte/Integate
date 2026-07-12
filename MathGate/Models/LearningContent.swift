//
//  LearningContent.swift
//  MathGate
//
//  All learning topic data — kept separate from UI so views stay lean.
//

import SwiftUI

// MARK: - LearningTopic

struct LearningTopic: Identifiable {
    let id = UUID()

    // Core identity
    let name: String
    let subtitle: String
    let icon: String
    let level: MathLevel
    let technique: String
    let color: Color
    let subject: MathSubject

    // Content
    let formula: String
    let keyInsight: String          // One-sentence "aha" shown at the top
    let whyItWorks: String          // Conceptual prose — the WHY
    let whenToUse: String
    let workedExample: String       // Primary worked example (monospaced)
    let extraExamples: [(problem: String, solution: String)]  // 1–3 additional
    let commonMistakes: [String]
    let videoURL: String            // YouTube URL, empty string if none

    init(
        name: String, subtitle: String, icon: String,
        level: MathLevel, technique: String, color: Color,
        subject: MathSubject = .integrals,
        formula: String,
        keyInsight: String = "",
        whyItWorks: String = "",
        whenToUse: String,
        workedExample: String,
        extraExamples: [(problem: String, solution: String)] = [],
        commonMistakes: [String] = [],
        videoURL: String = ""
    ) {
        self.name = name; self.subtitle = subtitle; self.icon = icon
        self.level = level; self.technique = technique; self.color = color
        self.subject = subject; self.formula = formula
        self.keyInsight = keyInsight; self.whyItWorks = whyItWorks
        self.whenToUse = whenToUse; self.workedExample = workedExample
        self.extraExamples = extraExamples
        self.commonMistakes = commonMistakes; self.videoURL = videoURL
    }

    static let all: [LearningTopic] = integralsTopics + derivativesTopics
                                    + algebraTopics   + satTopics + physicsTopics
}

// MARK: - INTEGRALS

extension LearningTopic {
    static let integralsTopics: [LearningTopic] = [

        LearningTopic(
            name: "Constant Rule",
            subtitle: "Integrating a constant",
            icon: "➕",
            level: .basic, technique: "Constant Rule", color: .green,
            formula: "∫c dx = c·x + C",
            keyInsight: "A constant integrand means you're finding the area of a rectangle — width × height.",
            whyItWorks: """
            Think of integration as accumulating area under a curve. If the curve is a flat horizontal line at height c, the area from x = a to x = b is simply c × (b − a). That's exactly what c·x + C gives you when you evaluate at the limits. The +C exists because any constant disappears when you differentiate, so we can't know it from the integral alone.
            """,
            whenToUse: "Any time the integrand is a plain number with no variable.",
            workedExample: """
            ∫₀² 4 dx
            Antiderivative: 4x
            [4x]₀² = 4(2) − 4(0) = 8
            """,
            extraExamples: [
                ("∫₁⁵ 3 dx", """
                Antiderivative: 3x
                [3x]₁⁵ = 15 − 3 = 12
                """),
                ("∫₂⁷ 6 dx", """
                Antiderivative: 6x
                [6x]₂⁷ = 42 − 12 = 30
                """)
            ],
            commonMistakes: [
                "Forgetting to subtract F(lower bound). ∫₀² 4 dx = 8, not just 4(2) = 8 in this case, but ∫₁² 4 dx = 4, not 8.",
                "Writing ∫c dx = c + C (missing the x). The antiderivative of a constant c is c·x, not c."
            ],
            videoURL: "https://www.youtube.com/watch?v=rfG8ce4nNh0"
        ),

        LearningTopic(
            name: "Power Rule",
            subtitle: "Integrating xⁿ",
            icon: "⚡️",
            level: .basic, technique: "Power Rule", color: .green,
            formula: "∫xⁿ dx = xⁿ⁺¹/(n+1) + C   (n ≠ −1)",
            keyInsight: "Integration raises the power by 1 and divides — the exact opposite of differentiation.",
            whyItWorks: """
            The power rule for derivatives says d/dx[xⁿ] = n·xⁿ⁻¹. Integration undoes this: if differentiating lowers the exponent by 1 and multiplies, integrating must raise it by 1 and divide. Specifically, d/dx[xⁿ⁺¹/(n+1)] = (n+1)·xⁿ/(n+1) = xⁿ, which confirms the formula. The restriction n ≠ −1 exists because division by zero (n+1 = 0) is undefined — the case ∫(1/x)dx = ln|x| + C is handled separately.
            """,
            whenToUse: "Any time the integrand is a power of x (x², x³, x^(1/2), etc.).",
            workedExample: """
            ∫₀³ x² dx
            Antiderivative: x³/3
            [x³/3]₀³ = 27/3 − 0 = 9
            """,
            extraExamples: [
                ("∫₁² x³ dx", """
                Antiderivative: x⁴/4
                [x⁴/4]₁² = 16/4 − 1/4 = 15/4
                Note: answer is 3 if asked as integer (round to 4)
                """),
                ("∫₀⁴ x dx", """
                Antiderivative: x²/2
                [x²/2]₀⁴ = 16/2 − 0 = 8
                """),
                ("∫₀² 4x³ dx", """
                Antiderivative: x⁴
                [x⁴]₀² = 16 − 0 = 16
                (The 4 and the /4 cancel perfectly)
                """)
            ],
            commonMistakes: [
                "Dividing by n instead of (n+1). For ∫x² dx, the answer is x³/3, not x³/2.",
                "Forgetting to increase the exponent. ∫x² dx is NOT x²/2 — the exponent must become 3.",
                "Applying to n = −1 (i.e., ∫(1/x)dx). That's a special case: ln|x| + C."
            ],
            videoURL: "https://www.khanacademy.org/math/integral-calculus/ic-integration/ic-integral-calc-intro/v/antiderivatives-and-indefinite-integrals"
        ),

        LearningTopic(
            name: "Sum Rule",
            subtitle: "Integrating term by term",
            icon: "∑",
            level: .basic, technique: "Sum Rule", color: .blue,
            formula: "∫[f(x) + g(x)] dx = ∫f(x) dx + ∫g(x) dx",
            keyInsight: "Integration is linear — you can always split sums and pull out constants.",
            whyItWorks: """
            Because the derivative of a sum is the sum of derivatives (d/dx[f+g] = f'+g'), the antiderivative of a sum is the sum of antiderivatives. This means you can always break a polynomial into individual terms, integrate each, then add them. Constants can also be pulled out front: ∫k·f(x)dx = k·∫f(x)dx.
            """,
            whenToUse: "Whenever the integrand is a sum or difference of terms — integrate each term separately.",
            workedExample: """
            ∫₀² (3x² + 2x) dx
            = [x³ + x²]₀²
            = (8 + 4) − 0 = 12
            """,
            extraExamples: [
                ("∫₀² (2x + 1) dx", """
                = [x² + x]₀²
                = (4 + 2) − 0 = 6
                """),
                ("∫₁³ (x² − 2x) dx", """
                = [x³/3 − x²]₁³
                = (9 − 9) − (1/3 − 1) = 0 + 2/3 ≈ 1
                Integer answer: 0 (to nearest)
                """)
            ],
            commonMistakes: [
                "Integrating a product term-by-term: ∫(x+1)(x+2)dx ≠ ∫x dx + ∫1 dx + … Expand first, then integrate each term.",
                "Forgetting to subtract the lower bound evaluation. Each term needs [F(b) − F(a)]."
            ],
            videoURL: "https://www.khanacademy.org/math/integral-calculus/ic-integration"
        ),

        LearningTopic(
            name: "Trig Integration",
            subtitle: "sin, cos, sec², and friends",
            icon: "〰️",
            level: .basic, technique: "Trig Integration", color: .pink,
            formula: "∫sin(x) dx = −cos(x) + C\n∫cos(x) dx = sin(x) + C\n∫sec²(x) dx = tan(x) + C",
            keyInsight: "Trig integrals cycle: differentiate enough times and you come back to where you started. That's what makes the signs predictable.",
            whyItWorks: """
            Since d/dx[−cos x] = sin x, the antiderivative of sin x is −cos x. The negative sign is the critical part — many students forget it. Similarly, d/dx[sin x] = cos x, so the antiderivative of cos x is sin x (positive). These are just the derivative rules read in reverse. For definite integrals of trig functions, always work in radians, never degrees.
            """,
            whenToUse: "Integrand contains sin(x), cos(x), sec²(x), or combinations. Works cleanly on standard intervals like [0, π].",
            workedExample: """
            ∫₀^π sin(x) dx
            Antiderivative: −cos(x)
            [−cos(x)]₀^π
            = −cos(π) − (−cos(0))
            = −(−1) − (−1) = 1 + 1 = 2
            """,
            extraExamples: [
                ("∫₀^(π/2) cos(x) dx", """
                Antiderivative: sin(x)
                [sin(x)]₀^(π/2)
                = sin(π/2) − sin(0) = 1 − 0 = 1
                """),
                ("∫₀^(π/4) sec²(x) dx", """
                Antiderivative: tan(x)
                [tan(x)]₀^(π/4)
                = tan(π/4) − tan(0) = 1 − 0 = 1
                """)
            ],
            commonMistakes: [
                "Writing ∫sin(x)dx = cos(x). The correct antiderivative is NEGATIVE: −cos(x) + C.",
                "Using degrees instead of radians. Always use radians: π, π/2, π/4 — not 180, 90, 45.",
                "Forgetting that ∫cos(x)dx = sin(x), not −sin(x) (only sin picks up the minus)."
            ],
            videoURL: "https://www.khanacademy.org/math/integral-calculus/ic-integration/ic-trig-antiderivatives/v/antiderivative-of-sinx"
        ),

        LearningTopic(
            name: "Exponential Integration",
            subtitle: "∫eˣ and ∫eᵏˣ",
            icon: "📈",
            level: .intermediate, technique: "Exponential Integration", color: .orange,
            formula: "∫eˣ dx = eˣ + C\n∫eᵏˣ dx = eᵏˣ/k + C",
            keyInsight: "eˣ is its own antiderivative — the only function for which this is true.",
            whyItWorks: """
            The exponential function eˣ is special: d/dx[eˣ] = eˣ. This means the antiderivative of eˣ is itself. For eᵏˣ, the chain rule tells us d/dx[eᵏˣ] = k·eᵏˣ, so to undo that k we divide by it: ∫eᵏˣ dx = eᵏˣ/k + C. This divisor of k is the key step most students forget.
            """,
            whenToUse: "Integrand is eˣ, e^(2x), e^(−x), or any exponential with a constant in the exponent.",
            workedExample: """
            ∫₀² e^(2x) dx
            Antiderivative: e^(2x)/2
            [e^(2x)/2]₀² = e⁴/2 − e⁰/2
            ≈ 54.6/2 − 0.5 ≈ 27 − 0.5 ≈ 27
            (App uses integer e⁰=1 so: (e⁴−1)/2)
            """,
            extraExamples: [
                ("∫₀¹ eˣ dx", """
                Antiderivative: eˣ
                [eˣ]₀¹ = e¹ − e⁰ = e − 1 ≈ 1.718
                """),
                ("∫₀³ e^(−x) dx", """
                Antiderivative: −e^(−x)
                [−e^(−x)]₀³ = −e^(−3) − (−1) ≈ 0.95
                """)
            ],
            commonMistakes: [
                "Forgetting to divide by k: ∫e^(2x)dx is e^(2x)/2, NOT e^(2x).",
                "Writing e^(x+1) instead of eˣ·e¹. Remember e^(2x) at x=0 is e⁰ = 1, not 0."
            ],
            videoURL: "https://www.khanacademy.org/math/integral-calculus/ic-integration/ic-exponential-antiderivatives/v/antiderivatives-of-ex-and-1-x"
        ),

        LearningTopic(
            name: "U-Substitution",
            subtitle: "Chain rule in reverse",
            icon: "🔄",
            level: .advanced, technique: "U-Substitution", color: .orange,
            formula: "∫f(g(x))·g'(x) dx\nLet u = g(x), du = g'(x) dx\n→ ∫f(u) du",
            keyInsight: "U-sub works when the integrand contains a function AND its derivative — you're reversing the chain rule.",
            whyItWorks: """
            The chain rule says d/dx[F(g(x))] = F'(g(x))·g'(x). U-substitution runs this in reverse: if you can spot a function g(x) inside the integral and its derivative g'(x) also sitting nearby as a factor, you can substitute u = g(x) to clean up the integral entirely. The dx/du conversion is what changes the integral variable. After integrating in u, you substitute back to get the answer in x.
            """,
            whenToUse: "Look for a function 'inside' the integrand (the u) and its derivative elsewhere as a factor. If the derivative is off by a constant, adjust by multiplying/dividing by that constant.",
            workedExample: """
            ∫₀² 2x·(x²+1)³ dx
            u = x²+1,  du = 2x dx
            New bounds: x=0→u=1, x=2→u=5
            ∫₁⁵ u³ du = [u⁴/4]₁⁵
            = 625/4 − 1/4 = 624/4 = 156
            """,
            extraExamples: [
                ("∫₀¹ 3x²·(x³+1)² dx", """
                u = x³+1,  du = 3x² dx
                Bounds: x=0→u=1, x=1→u=2
                ∫₁² u² du = [u³/3]₁²
                = 8/3 − 1/3 = 7/3
                """),
                ("∫₀^(π/2) sin(x)·cos(x) dx", """
                u = sin(x),  du = cos(x) dx
                Bounds: x=0→u=0, x=π/2→u=1
                ∫₀¹ u du = [u²/2]₀¹ = 1/2
                """)
            ],
            commonMistakes: [
                "Forgetting to change the bounds when doing a definite integral. After u = g(x), the bounds become g(a) and g(b).",
                "Choosing the wrong u. The derivative of u must appear (up to a constant) elsewhere in the integrand.",
                "Leaving the answer in terms of u. Always substitute back to x for indefinite integrals."
            ],
            videoURL: "https://www.khanacademy.org/math/integral-calculus/ic-integration/ic-u-sub-intro/v/u-substitution"
        ),

        LearningTopic(
            name: "Trig Substitution",
            subtitle: "Square roots via trig identities",
            icon: "📐",
            level: .advanced, technique: "Trig Substitution", color: .teal,
            formula: "√(a²−x²) → x = a·sin θ\n√(x²−a²) → x = a·sec θ\n√(a²+x²) → x = a·tan θ",
            keyInsight: "Each substitution converts a radical into a simple trig expression using a Pythagorean identity.",
            whyItWorks: """
            The three forms of trig substitution each rely on a Pythagorean identity:
            • sin²θ + cos²θ = 1 → eliminates √(a²−x²)
            • tan²θ + 1 = sec²θ → eliminates √(a²+x²)
            • sec²θ − 1 = tan²θ → eliminates √(x²−a²)
            By substituting x = a·sinθ (for example), the radical √(a²−x²) becomes √(a²−a²sin²θ) = a·cosθ — no square root needed. After integrating, you use a right triangle to convert back to x.
            """,
            whenToUse: "When the integrand contains √(a²−x²), √(a²+x²), or √(x²−a²). Match the form to the right substitution.",
            workedExample: """
            ∫₀³ x/√(9−x²) dx
            Let x = 3sinθ, dx = 3cosθ dθ
            √(9−x²) = 3cosθ
            Integral becomes: ∫ (3sinθ·3cosθ)/(3cosθ) dθ
            = ∫3sinθ dθ = −3cosθ
            Revert: cosθ = √(9−x²)/3
            F(x) = −√(9−x²)
            [−√(9−x²)]₀³ = 0 − (−3) = 3
            """,
            extraExamples: [
                ("∫₀² x/√(4−x²) dx", """
                Let x = 2sinθ → √(4−x²) = 2cosθ
                Antiderivative: −√(4−x²)
                [−√(4−x²)]₀² = 0−(−2) = 2
                """)
            ],
            commonMistakes: [
                "Picking the wrong substitution form. Identify whether it's (a²−x²), (a²+x²), or (x²−a²) first.",
                "Forgetting to change dx. If x = a·sinθ, then dx = a·cosθ dθ.",
                "Not converting back to x after integrating. Draw a right triangle to find cosθ, tanθ, etc. in terms of x."
            ],
            videoURL: "https://www.khanacademy.org/math/integral-calculus/ic-integration/ic-trig-substitution/v/introduction-to-trigonometric-substitution"
        ),

        LearningTopic(
            name: "Integration by Parts",
            subtitle: "Reverse product rule — ∫u dv = uv − ∫v du",
            icon: "🤝",
            level: .expert, technique: "Integration by Parts", color: .purple,
            formula: "∫u dv = uv − ∫v du\nChoose u with LIATE: Log, Inverse trig, Algebraic, Trig, Exponential",
            keyInsight: "IBP is the product rule in reverse. Pick u to be the function that simplifies when you differentiate it.",
            whyItWorks: """
            The product rule states d/dx[uv] = u'v + uv'. Integrating both sides and rearranging gives ∫u v' dx = uv − ∫u' v dx, which is the IBP formula. The key insight is that you're trading one integral (∫u dv) for another (∫v du) that should be easier. The LIATE order tells you which function to call u: logarithms and inverse trig simplify dramatically when differentiated, so they always make better choices for u.
            """,
            whenToUse: "A product of two 'different type' functions: polynomial × exponential (x·eˣ), polynomial × trig (x·sin x), or expressions like ln(x) or arctan(x) alone.",
            workedExample: """
            ∫₀¹ x·eˣ dx
            u = x       dv = eˣ dx
            du = dx     v = eˣ
            = [x·eˣ]₀¹ − ∫₀¹ eˣ dx
            = [x·eˣ − eˣ]₀¹
            = (e − e) − (0 − 1) = 0 + 1 = 1
            """,
            extraExamples: [
                ("∫₁ᵉ ln(x) dx", """
                u = ln(x)    dv = dx
                du = (1/x)dx  v = x
                = [x·ln(x)]₁ᵉ − ∫₁ᵉ x·(1/x) dx
                = [x·ln(x) − x]₁ᵉ
                = (e·1 − e) − (0 − 1) = 0 + 1 = 1
                """),
                ("∫₀^(π) x·sin(x) dx", """
                u = x       dv = sin(x)dx
                du = dx     v = −cos(x)
                = [−x·cos(x)]₀^π + ∫₀^π cos(x)dx
                = π + [sin(x)]₀^π = π + 0 = π ≈ 3
                """)
            ],
            commonMistakes: [
                "Choosing dv = ln(x)dx — ln(x) has no easy antiderivative, so pick u = ln(x) instead.",
                "Sign errors in [uv] − ∫v du. The minus applies to the ENTIRE remaining integral, not just the next term.",
                "Forgetting to apply bounds to the uv term as well as the remaining integral."
            ],
            videoURL: "https://www.khanacademy.org/math/integral-calculus/ic-integration/ic-integration-by-parts/v/deriving-integration-by-parts-formula"
        ),

        LearningTopic(
            name: "Double Integrals",
            subtitle: "Integrating over a 2D region",
            icon: "🔲",
            level: .expert, technique: "Double Integral", color: .indigo,
            formula: "∫∫ f(x,y) dy dx\nAlways integrate the INNER variable first (treat outer as constant)",
            keyInsight: "A double integral is just two single integrals done one at a time — inner first, outer second.",
            whyItWorks: """
            A double integral computes the volume under a surface z = f(x,y) above a rectangular region. Fubini's Theorem guarantees you can compute it by iterating: first integrate over y (treating x as a constant), then integrate the result over x. Each pass is just a single-variable integral. Think of it as summing up infinitely thin slices, then summing those slices.
            """,
            whenToUse: "Volume under a surface, mass of a 2D plate with variable density, or any quantity accumulated over a 2D region.",
            workedExample: """
            ∫₀² ∫₀¹ 6xy dy dx

            Inner integral (treat x as constant):
            ∫₀¹ 6xy dy = [3xy²]₀¹ = 3x

            Outer integral:
            ∫₀² 3x dx = [3x²/2]₀² = 6
            """,
            extraExamples: [
                ("∫₀¹ ∫₀² 4y dx dy", """
                Inner (treat y constant):
                ∫₀² 4y dx = [4xy]₀² = 8y
                Outer:
                ∫₀¹ 8y dy = [4y²]₀¹ = 4
                """),
                ("∫₀³ ∫₀² 2x dy dx", """
                Inner:
                ∫₀² 2x dy = [2xy]₀² = 4x
                Outer:
                ∫₀³ 4x dx = [2x²]₀³ = 18
                """)
            ],
            commonMistakes: [
                "Integrating the outer variable first. Always work inside-out.",
                "Treating the outer variable as a variable during the inner integral — hold it constant.",
                "Using the wrong bounds for the wrong variable. Match each bound set to its own variable."
            ],
            videoURL: "https://www.khanacademy.org/math/multivariable-calculus/integrating-multivariable-functions/double-integrals-topic/v/double-integrals-1"
        ),

        LearningTopic(
            name: "Partial Fractions",
            subtitle: "Decompose rational functions",
            icon: "🧩",
            level: .expert, technique: "Partial Fractions", color: .indigo,
            formula: "P(x)/[(x−a)(x−b)] = A/(x−a) + B/(x−b)\nSolve for A, B by clearing denominators",
            keyInsight: "Partial fractions splits a hard rational integrand into simple pieces you already know how to integrate.",
            whyItWorks: """
            Any rational function (polynomial over polynomial) with distinct linear factors in the denominator can be decomposed into a sum of simple fractions. Each simple fraction has the form A/(x − r) whose antiderivative is A·ln|x − r| + C. Once you decompose, each piece integrates trivially. The method works by multiplying out and matching coefficients — or by the 'cover-up' shortcut.
            """,
            whenToUse: "Integrand is a fraction where the denominator factors into linear terms, and degree of numerator < degree of denominator.",
            workedExample: """
            ∫ 1/[(x−1)(x+1)] dx
            Decompose: A/(x−1) + B/(x+1)
            1 = A(x+1) + B(x−1)
            x=1: 1 = 2A → A = 1/2
            x=−1: 1 = −2B → B = −1/2
            ∫ [1/2·1/(x−1) − 1/2·1/(x+1)] dx
            = ½ln|x−1| − ½ln|x+1| + C
            """,
            extraExamples: [
                ("∫₂³ 1/[(x)(x−1)] dx", """
                A/x + B/(x−1) → A=−1, B=1
                = [ln|x−1| − ln|x|]₂³
                = (ln2−ln3) − (ln1−ln2)
                = ln(4/3)
                """)
            ],
            commonMistakes: [
                "Using partial fractions when the degree of numerator ≥ denominator. Do polynomial long division first.",
                "Forgetting to check that the denominator is fully factored before setting up the decomposition."
            ],
            videoURL: "https://www.khanacademy.org/math/integral-calculus/ic-integration/ic-partial-fractions/v/partial-fraction-expansion-1"
        ),
    ]
}

// MARK: - DERIVATIVES

extension LearningTopic {
    static let derivativesTopics: [LearningTopic] = [

        LearningTopic(
            name: "Power Rule",
            subtitle: "Differentiating xⁿ",
            icon: "⚡️",
            level: .basic, technique: "Power Rule", color: .green, subject: .derivatives,
            formula: "d/dx[xⁿ] = n·xⁿ⁻¹",
            keyInsight: "Differentiation lowers the exponent by 1 and multiplies by the old exponent.",
            whyItWorks: """
            The formal definition of the derivative uses the limit of [f(x+h)−f(x)]/h as h→0. For f(x) = xⁿ, expanding (x+h)ⁿ via the binomial theorem and taking the limit leaves exactly n·xⁿ⁻¹. The beauty of the power rule is that it works for any real exponent n — fractions (x^(1/2) = √x), negatives (x^(−1) = 1/x), even irrational numbers.
            """,
            whenToUse: "Any expression that's a power of x — polynomials, square roots, reciprocals. Also works with coefficients: d/dx[c·xⁿ] = c·n·xⁿ⁻¹.",
            workedExample: """
            f(x) = x⁴
            f'(x) = 4x³
            f'(2) = 4·8 = 32
            """,
            extraExamples: [
                ("f(x) = 3x²", """
                f'(x) = 6x
                f'(3) = 18
                """),
                ("f(x) = x⁵", """
                f'(x) = 5x⁴
                f'(1) = 5
                """),
                ("f(x) = x^(1/2) = √x", """
                f'(x) = (1/2)x^(−1/2) = 1/(2√x)
                f'(4) = 1/4
                """)
            ],
            commonMistakes: [
                "Multiplying by (n−1) instead of n. The old exponent n goes in front, and the new exponent is n−1.",
                "Treating the constant: d/dx[5] = 0 (constants vanish), not d/dx[5] = 5.",
                "Confusing power rule with product rule when the variable appears in two factors."
            ],
            videoURL: "https://www.youtube.com/watch?v=S0_qX4VJhMQ"
        ),

        LearningTopic(
            name: "Chain Rule",
            subtitle: "Derivative of a composite function",
            icon: "🔗",
            level: .intermediate, technique: "Chain Rule", color: .orange, subject: .derivatives,
            formula: "d/dx[f(g(x))] = f'(g(x)) · g'(x)\n'Outer derivative times inner derivative'",
            keyInsight: "If a function is nested inside another, you must differentiate both and multiply their derivatives.",
            whyItWorks: """
            The chain rule follows from how rates of change compose. If y changes at rate dy/du and u changes at rate du/dx, then y changes at rate (dy/du)·(du/dx). Formally: if h(x) = f(g(x)), then h'(x) = f'(g(x))·g'(x). In practice: differentiate the outer function (leaving the inner alone), then multiply by the derivative of the inner function. This 'multiply by the inside derivative' step is what students most often forget.
            """,
            whenToUse: "Whenever you see a function inside another function: sin(x²), (3x+1)⁴, e^(x²), ln(2x+1), etc. If you'd need parentheses to describe it, you need the chain rule.",
            workedExample: """
            f(x) = (2x+1)³
            Outer: u³, inner: u = 2x+1
            f'(x) = 3(2x+1)² · 2 = 6(2x+1)²
            f'(0) = 6·1² = 6
            """,
            extraExamples: [
                ("f(x) = sin(3x)", """
                Outer: sin, inner: 3x
                f'(x) = cos(3x)·3 = 3cos(3x)
                f'(π/6) = 3cos(π/2) = 0
                """),
                ("f(x) = e^(4x)", """
                Outer: eˣ, inner: 4x
                f'(x) = e^(4x)·4 = 4e^(4x)
                f'(0) = 4
                """),
                ("f(x) = (x²+1)⁵", """
                f'(x) = 5(x²+1)⁴ · 2x = 10x(x²+1)⁴
                f'(0) = 0
                """)
            ],
            commonMistakes: [
                "Forgetting to multiply by the inner derivative. d/dx[sin(x²)] = cos(x²)·2x, NOT just cos(x²).",
                "Differentiating the inner function as if it were the whole expression. For (3x+1)⁴, you need both the outer ×4(…)³ AND the inner ×3.",
                "Using the chain rule when the product rule is needed. (x²·eˣ) is a product, not a composition."
            ],
            videoURL: "https://www.youtube.com/watch?v=YG15m2VwSjA"
        ),

        LearningTopic(
            name: "Product Rule",
            subtitle: "Derivative of u·v",
            icon: "✖️",
            level: .intermediate, technique: "Product Rule", color: .blue, subject: .derivatives,
            formula: "d/dx[u·v] = u'·v + u·v'\n'First times derivative of second, plus second times derivative of first'",
            keyInsight: "Differentiation does NOT distribute over multiplication — you must use the product rule.",
            whyItWorks: """
            By definition, d/dx[u·v] = lim[(u(x+h)v(x+h) − u(x)v(x))/h]. Adding and subtracting u(x+h)v(x) inside the limit and factoring leads to u'v + uv'. Think of it geometrically: if u and v are side lengths of a rectangle, a small increase in x changes the area by approximately (Δu)·v + u·(Δv), leading directly to the product rule.
            """,
            whenToUse: "Two functions multiplied together where both depend on x: x·eˣ, x²·sin(x), (x+1)·ln(x).",
            workedExample: """
            f(x) = x·eˣ
            u = x   → u' = 1
            v = eˣ  → v' = eˣ
            f'(x) = 1·eˣ + x·eˣ = eˣ(1+x)
            f'(0) = e⁰(1+0) = 1
            """,
            extraExamples: [
                ("f(x) = x²·sin(x)", """
                u = x²  → u' = 2x
                v = sinx → v' = cosx
                f'(x) = 2x·sinx + x²·cosx
                f'(0) = 0
                """),
                ("f(x) = (x+1)·(x²+3)", """
                u = x+1  → u' = 1
                v = x²+3 → v' = 2x
                f'(x) = (x²+3) + (x+1)·2x
                f'(2) = 7 + 3·4 = 19
                (Or expand first: x³+x²+3x+3, f'=3x²+2x+3, f'(2)=19)
                """)
            ],
            commonMistakes: [
                "Writing d/dx[u·v] = u'·v'. This is wrong — you need BOTH terms: u'v + uv'.",
                "Confusing product rule with chain rule. Product = two factors multiplied. Chain = one function INSIDE another.",
                "For three factors uvw: the rule extends to u'vw + uv'w + uvw'."
            ],
            videoURL: "https://www.khanacademy.org/math/differential-calculus/dc-diff-intro/dc-product-rule/v/product-rule"
        ),

        LearningTopic(
            name: "Quotient Rule",
            subtitle: "Derivative of u/v",
            icon: "➗",
            level: .intermediate, technique: "Quotient Rule", color: .cyan, subject: .derivatives,
            formula: "d/dx[u/v] = (u'v − uv') / v²\n'Low d-high minus high d-low, over low squared'",
            keyInsight: "Quotient rule = product rule applied to u·v⁻¹, but the mnemonic makes it faster.",
            whyItWorks: """
            You can derive the quotient rule by writing u/v = u·v⁻¹ and applying the product rule with d/dx[v⁻¹] = −v⁻²·v' (chain rule). This gives (u'·v⁻¹) + u·(−v'/v²) = (u'v − uv')/v². The denominator is always v squared — never v or v³. The numerator order matters: it's u'v minus uv', not the reverse.
            """,
            whenToUse: "One function divided by another where both depend on x: sin(x)/x, (x²+1)/(x−1), eˣ/x².",
            workedExample: """
            f(x) = sin(x)/x
            u = sinx   u' = cosx
            v = x      v' = 1
            f'(x) = (cosx·x − sinx·1)/x²
            f'(π) = (−1·π − 0)/π² = −1/π
            """,
            extraExamples: [
                ("f(x) = (x²+1)/(x+1)", """
                u = x²+1  u'= 2x
                v = x+1   v'= 1
                f'(x) = [2x(x+1) − (x²+1)] / (x+1)²
                = (x²+2x−1)/(x+1)²
                f'(1) = (1+2−1)/4 = 2/4 = 1/2
                """)
            ],
            commonMistakes: [
                "Getting the subtraction backwards: it's u'v MINUS uv', not uv' minus u'v.",
                "Forgetting v² in the denominator — it's always the denominator squared.",
                "Using quotient rule when you could simplify first: d/dx[x³/x] = d/dx[x²] = 2x is much easier."
            ],
            videoURL: "https://www.khanacademy.org/math/differential-calculus/dc-diff-intro/dc-quotient-rule/v/quotient-rule"
        ),

        LearningTopic(
            name: "Trig Derivatives",
            subtitle: "sin, cos, tan and all six",
            icon: "〰️",
            level: .advanced, technique: "Trig Derivative", color: .pink, subject: .derivatives,
            formula: "d/dx[sinx] = cosx\nd/dx[cosx] = −sinx\nd/dx[tanx] = sec²x\nd/dx[secx] = secx·tanx",
            keyInsight: "The derivatives of sin and cos cycle with period 4 — differentiate 4 times and you're back where you started.",
            whyItWorks: """
            Using the limit definition: d/dx[sinx] = lim[(sin(x+h)−sinx)/h]. Applying the angle addition formula and two known limits (lim[sinh/h]=1 and lim[(cosh−1)/h]=0 as h→0) gives exactly cosx. For cosx, the same process gives −sinx. The minus sign on −sinx is what trips most people up — it only appears when differentiating cosine, not sine. The chain rule handles sin(kx): d/dx[sin(kx)] = k·cos(kx).
            """,
            whenToUse: "Any expression involving sin, cos, tan, sec, csc, cot. Always pair with the chain rule if the argument isn't just x.",
            workedExample: """
            f(x) = sin(2x)
            Chain rule: inner = 2x, inner' = 2
            f'(x) = cos(2x)·2 = 2cos(2x)
            f'(0) = 2cos(0) = 2
            """,
            extraExamples: [
                ("f(x) = cos(3x)", """
                f'(x) = −sin(3x)·3 = −3sin(3x)
                f'(π/6) = −3sin(π/2) = −3
                """),
                ("f(x) = tan(x)", """
                f'(x) = sec²(x)
                f'(π/4) = sec²(π/4) = (√2)² = 2
                """)
            ],
            commonMistakes: [
                "d/dx[cosx] = sinx (missing the minus). It must be −sinx.",
                "Forgetting the chain rule factor: d/dx[sin(3x)] = cos(3x), NOT 3cos(3x) ... wait, it IS 3cos(3x). Don't drop the 3.",
                "Mixing up which trig functions get a negative: only cosine and cosecant pick up a minus sign."
            ],
            videoURL: "https://www.khanacademy.org/math/differential-calculus/dc-diff-intro/dc-trig-derivatives/v/derivatives-of-sinx-and-cosx"
        ),

        LearningTopic(
            name: "Second Derivative",
            subtitle: "Differentiate twice — concavity & acceleration",
            icon: "2️⃣",
            level: .advanced, technique: "Second Derivative", color: .purple, subject: .derivatives,
            formula: "f''(x) = d/dx[f'(x)]\nf'' > 0 → concave up;  f'' < 0 → concave down",
            keyInsight: "The second derivative tells you whether the rate of change is itself increasing or decreasing.",
            whyItWorks: """
            The first derivative measures rate of change (slope). The second derivative measures how that slope is changing — essentially the 'curvature' of the function. In physics: if position is x(t), then x'(t) = velocity and x''(t) = acceleration. A positive second derivative means the curve is concave up (opening upward like a bowl); negative means concave down. Inflection points occur where f'' changes sign.
            """,
            whenToUse: "When asked for f'', acceleration, concavity, or inflection points. Also used to verify whether a critical point is a max or min (second derivative test).",
            workedExample: """
            f(x) = x⁴
            f'(x) = 4x³
            f''(x) = 12x²
            f''(2) = 12·4 = 48
            """,
            extraExamples: [
                ("f(x) = sin(x)", """
                f'(x) = cos(x)
                f''(x) = −sin(x)
                f''(π/2) = −sin(π/2) = −1
                """),
                ("f(x) = x³ − 3x", """
                f'(x) = 3x² − 3
                f''(x) = 6x
                Inflection at x=0 (f''=0 changes sign)
                """)
            ],
            commonMistakes: [
                "Differentiating f instead of f'. You must differentiate f' to get f''.",
                "Confusing f'' = 0 with a guaranteed inflection point. f'' = 0 is necessary but not sufficient — you need a sign change."
            ],
            videoURL: "https://www.khanacademy.org/math/differential-calculus/dc-analytic-app/dc-second-derivative-test/v/second-derivative-test"
        ),

        LearningTopic(
            name: "Implicit Differentiation",
            subtitle: "Differentiate both sides, solve for dy/dx",
            icon: "🔀",
            level: .expert, technique: "Implicit Differentiation", color: .teal, subject: .derivatives,
            formula: "Differentiate both sides w.r.t. x\nEvery y-term gets a factor of dy/dx via chain rule\nSolve for dy/dx",
            keyInsight: "When y is tangled with x, treat y as a function of x and apply the chain rule to every y-term.",
            whyItWorks: """
            Not every curve can be written as y = f(x) (think of a circle). Implicit differentiation sidesteps this by differentiating the equation as-is. When you differentiate a term involving y, you apply the chain rule: d/dx[y²] = 2y·(dy/dx), because y is a function of x. After differentiating, collect all dy/dx terms on one side and solve.
            """,
            whenToUse: "When the equation relates x and y in a way that can't easily be solved for y, such as x² + y² = 25, x³ + y³ = 6xy, or sin(xy) = x.",
            workedExample: """
            x² + y² = 25  (circle of radius 5)
            Differentiate both sides w.r.t. x:
            2x + 2y·(dy/dx) = 0
            2y·(dy/dx) = −2x
            dy/dx = −x/y
            At point (3, 4): dy/dx = −3/4
            """,
            extraExamples: [
                ("x³ + y³ = 8", """
                3x² + 3y²·(dy/dx) = 0
                dy/dx = −x²/y²
                At (0,2): dy/dx = 0
                """)
            ],
            commonMistakes: [
                "Forgetting the dy/dx factor after differentiating y. d/dx[y³] = 3y²·(dy/dx), not just 3y².",
                "Differentiating x terms and adding dy/dx there too. Only y-terms get dy/dx."
            ],
            videoURL: "https://www.khanacademy.org/math/differential-calculus/dc-diff-intro/dc-implicit-diff/v/implicit-differentiation-1"
        ),

        LearningTopic(
            name: "Inverse Trig Derivatives",
            subtitle: "arcsin, arccos, arctan",
            icon: "🔄",
            level: .expert, technique: "Inverse Trig", color: .teal, subject: .derivatives,
            formula: "d/dx[arcsin x] = 1/√(1−x²)\nd/dx[arctan x] = 1/(1+x²)\nd/dx[arccos x] = −1/√(1−x²)",
            keyInsight: "Inverse trig derivatives are algebraic (no trig in the answer) — derived by implicit differentiation.",
            whyItWorks: """
            To find d/dx[arcsin x]: let y = arcsin x, so sin y = x. Differentiating implicitly: cos y · dy/dx = 1, so dy/dx = 1/cos y. Using the identity cos y = √(1−sin²y) = √(1−x²), we get dy/dx = 1/√(1−x²). The arctan formula follows from a similar argument with tan y = x. These formulas appear constantly in integral tables (as antiderivatives) and in physics and engineering.
            """,
            whenToUse: "Differentiating arcsin, arctan, or arccos — alone or composed with other functions via chain rule.",
            workedExample: """
            f(x) = arctan(x)
            f'(x) = 1/(1+x²)
            f'(0) = 1/(1+0) = 1
            """,
            extraExamples: [
                ("f(x) = arcsin(x)", """
                f'(x) = 1/√(1−x²)
                f'(0) = 1/√1 = 1
                """),
                ("f(x) = arctan(2x)", """
                Chain rule: f'(x) = 1/(1+(2x)²)·2
                = 2/(1+4x²)
                f'(0) = 2
                """)
            ],
            commonMistakes: [
                "Writing d/dx[arcsin x] = 1/cos(arcsin x) — simplify using the Pythagorean identity to get 1/√(1−x²).",
                "Confusing arctan and arcsin formulas. arctan has (1+x²) in the denominator; arcsin has √(1−x²).",
                "Forgetting the chain rule factor when the argument is not just x."
            ],
            videoURL: "https://www.khanacademy.org/math/differential-calculus/dc-diff-intro/dc-inverse-trig-derivatives/v/derivative-of-inverse-sine"
        ),
    ]
}

// MARK: - ALGEBRA

extension LearningTopic {
    static let algebraTopics: [LearningTopic] = [

        LearningTopic(
            name: "Linear Equations",
            subtitle: "Solving ax + b = c",
            icon: "📏",
            level: .basic, technique: "Linear Equation", color: .green, subject: .algebra,
            formula: "ax + b = c  →  x = (c − b) / a",
            keyInsight: "Whatever you do to one side of an equation, you must do to the other — equations are balances.",
            whyItWorks: """
            An equation is a statement of equality between two expressions. To 'solve' means to isolate x. You can add, subtract, multiply, or divide any quantity from both sides without changing the truth of the equation — as long as you do the same thing to both sides. The standard strategy: move all constant terms to one side, move the x-terms to the other, then divide by the coefficient of x.
            """,
            whenToUse: "Any equation where x appears only to the first power (no x², √x, etc.).",
            workedExample: """
            3x + 7 = 22
            Subtract 7: 3x = 15
            Divide by 3: x = 5
            """,
            extraExamples: [
                ("5x − 3 = 2x + 9", """
                Subtract 2x: 3x − 3 = 9
                Add 3: 3x = 12
                x = 4
                """),
                ("2(x + 4) = 18", """
                Distribute: 2x + 8 = 18
                Subtract 8: 2x = 10
                x = 5
                """)
            ],
            commonMistakes: [
                "Adding when you should subtract (or vice versa). Moving a term across the equals sign flips its sign.",
                "Dividing only the first term: (3x + 6)/3 = x + 6, not x + 2. Divide EVERY term."
            ],
            videoURL: "https://www.khanacademy.org/math/algebra/x2f8bb11595b61c86:solve-equations-inequalities/x2f8bb11595b61c86:linear-equations-variables-on-both-sides/v/equations-3"
        ),

        LearningTopic(
            name: "Factoring Quadratics",
            subtitle: "Find roots by factoring ax² + bx + c",
            icon: "🔢",
            level: .intermediate, technique: "Factoring", color: .orange, subject: .algebra,
            formula: "x² + bx + c = (x+p)(x+q)\nwhere p + q = b  and  p × q = c",
            keyInsight: "To factor x² + bx + c, find two numbers that ADD to b and MULTIPLY to c.",
            whyItWorks: """
            When you expand (x+p)(x+q) = x² + (p+q)x + pq. Matching coefficients: the coefficient of x is p+q = b, and the constant is pq = c. So factoring works by finding two numbers with the right sum and product. This only finds nice integer or rational roots — for irrational roots, you need the quadratic formula. For ax² + bx + c (a ≠ 1), factor out a first or use the AC method.
            """,
            whenToUse: "When the quadratic has 'nice' integer roots. Try factoring before using the quadratic formula — it's faster when it works.",
            workedExample: """
            x² − 5x + 6 = 0
            Need: p+q = −5,  pq = 6
            → p = −2, q = −3
            (x−2)(x−3) = 0
            x = 2  or  x = 3
            """,
            extraExamples: [
                ("x² + 7x + 12 = 0", """
                p+q=7, pq=12 → p=3, q=4
                (x+3)(x+4) = 0
                x = −3 or x = −4
                """),
                ("x² − 9 = 0", """
                Difference of squares: (x−3)(x+3)=0
                x = 3 or x = −3
                """),
                ("2x² − 8x = 0", """
                Factor out 2x: 2x(x−4) = 0
                x = 0 or x = 4
                """)
            ],
            commonMistakes: [
                "Sign errors: for x²−5x+6, you need BOTH numbers negative (−2 and −3), not positive.",
                "Forgetting x = 0 as a solution when factoring out x: 3x² − 6x = 3x(x−2) = 0 gives x=0 AND x=2.",
                "Setting up the wrong sum/product: for x²+bx+c, it's p+q=b and pq=c. Students often swap these."
            ],
            videoURL: "https://www.khanacademy.org/math/algebra/x2f8bb11595b61c86:quadratics-multiplying-factoring/x2f8bb11595b61c86:factor-quadratics-intro/v/factoring-simple-quadratic-expression"
        ),

        LearningTopic(
            name: "Quadratic Formula",
            subtitle: "x = (−b ± √(b²−4ac)) / 2a",
            icon: "🌠",
            level: .intermediate, technique: "Quadratic Formula", color: .red, subject: .algebra,
            formula: "x = [−b ± √(b² − 4ac)] / (2a)\nDiscriminant: b²−4ac > 0 → 2 roots, = 0 → 1 root, < 0 → no real roots",
            keyInsight: "The quadratic formula always works — it's the guaranteed last resort when factoring fails.",
            whyItWorks: """
            The formula is derived by completing the square on ax² + bx + c = 0. Divide by a, complete the square on the left, then solve for x. The result is x = [−b ± √(b²−4ac)]/(2a). The term under the radical — the discriminant — tells you everything about the roots before you finish the calculation. A negative discriminant means the roots are complex (not real).
            """,
            whenToUse: "Any quadratic ax² + bx + c = 0, especially when factoring looks hard or impossible.",
            workedExample: """
            x² − 5x + 4 = 0
            a=1, b=−5, c=4
            x = [5 ± √(25−16)] / 2
            x = [5 ± 3] / 2
            x = 4  or  x = 1
            """,
            extraExamples: [
                ("x² + 4x + 4 = 0", """
                Discriminant = 16 − 16 = 0
                x = −4/2 = −2 (double root)
                """),
                ("2x² − 7x + 3 = 0", """
                x = [7 ± √(49−24)] / 4
                = [7 ± 5] / 4
                x = 3  or  x = 1/2
                """)
            ],
            commonMistakes: [
                "Only computing one root (forgetting the ± means TWO solutions).",
                "Putting 2a only under the square root instead of the whole numerator. The 2a divides everything.",
                "Computing b² before flipping the sign: if b = −5, then b² = 25 (positive), not −25."
            ],
            videoURL: "https://www.khanacademy.org/math/algebra/x2f8bb11595b61c86:quadratics-multiplying-factoring/x2f8bb11595b61c86:quadratic-formula/v/using-the-quadratic-formula"
        ),

        LearningTopic(
            name: "Systems of Equations",
            subtitle: "Substitution and elimination",
            icon: "⚖️",
            level: .intermediate, technique: "Systems of Equations", color: .blue, subject: .algebra,
            formula: "Substitution: solve one eq for one variable, sub into other\nElimination: multiply to match coefficients, then add/subtract equations",
            keyInsight: "Two equations, two unknowns — find the (x, y) point where both lines cross.",
            whyItWorks: """
            Geometrically, each linear equation represents a line. A system of two equations asks where two lines intersect. Substitution eliminates one variable algebraically by expressing it in terms of the other. Elimination scales the equations so one variable's coefficients are equal and opposite — adding the equations cancels that variable entirely. Either method gives the same answer; choose whichever looks easier based on the coefficients.
            """,
            whenToUse: "Two equations with two unknowns. Use elimination when coefficients look close to matching; use substitution when one variable is already isolated.",
            workedExample: """
            x + y = 10
            x − y = 4
            Add equations: 2x = 14 → x = 7
            Substitute: 7 + y = 10 → y = 3
            """,
            extraExamples: [
                ("2x + 3y = 12,  x = 2y", """
                Substitute x=2y:
                2(2y) + 3y = 12 → 7y = 12 → y ≈ 1.7
                (Integer setup: 2x + y = 10, x − y = 2)
                2x + y = 10, x − y = 2 → x=4, y=2
                """),
                ("3x + 2y = 16,  x + y = 6", """
                From eq 2: x = 6 − y
                Sub: 3(6−y)+2y=16 → 18−y=16 → y=2
                x = 4
                """)
            ],
            commonMistakes: [
                "Substituting into the same equation you solved from. Always substitute into the OTHER equation.",
                "Sign errors when subtracting equations: write out the full step including sign changes.",
                "Forgetting to find BOTH x and y. The answer is always a pair (x, y)."
            ],
            videoURL: "https://www.khanacademy.org/math/algebra/x2f8bb11595b61c86:systems-of-equations/x2f8bb11595b61c86:introduction-to-systems-of-equations/v/solving-systems-by-substitution"
        ),

        LearningTopic(
            name: "Logarithms",
            subtitle: "log rules and solving log equations",
            icon: "📈",
            level: .advanced, technique: "Logarithms", color: .purple, subject: .algebra,
            formula: "logₐ(b) = c  ↔  aᶜ = b\nlog(xy) = log x + log y\nlog(x/y) = log x − log y\nlog(xⁿ) = n·log x",
            keyInsight: "A logarithm answers the question: 'What power do I raise the base to in order to get this number?'",
            whyItWorks: """
            Logarithms were invented to turn multiplication into addition (before calculators). The key definition: logₐ(b) = c means exactly aᶜ = b. All the log rules (product, quotient, power) follow directly from exponent rules. For example, log(xy) = log x + log y because aˢ·aᵗ = aˢ⁺ᵗ — when you multiply numbers, their exponents add. The change of base formula log_a(b) = ln(b)/ln(a) lets you compute any base logarithm using the natural log.
            """,
            whenToUse: "When you need to undo an exponential, solve for an exponent, or simplify expressions involving multiplication/division of powers.",
            workedExample: """
            log₂(32) = ?
            2? = 32 = 2⁵
            Answer: 5

            Solve: log₃(x) = 4
            x = 3⁴ = 81
            """,
            extraExamples: [
                ("log₅(125) = ?", """
                5? = 125 = 5³
                Answer: 3
                """),
                ("log₂(8) + log₂(4) = ?", """
                = log₂(8·4) = log₂(32) = 5
                """),
                ("Solve: 2^x = 32", """
                Take log₂: x = log₂(32) = 5
                """)
            ],
            commonMistakes: [
                "log(a + b) ≠ log(a) + log(b). The product rule applies to log(a·b), not log(a+b).",
                "log(x²) = 2·log(x), NOT log(x)². The exponent comes out as a MULTIPLIER.",
                "Using log = log₁₀ vs ln = logₑ interchangeably. They're different bases — be careful which one the problem uses."
            ],
            videoURL: "https://www.khanacademy.org/math/algebra2/x2ec2f6f830c9fb89:logs/x2ec2f6f830c9fb89:log-intro/v/logarithms"
        ),

        LearningTopic(
            name: "Exponential Equations",
            subtitle: "Solve for x in the exponent",
            icon: "🚀",
            level: .advanced, technique: "Exponential Equation", color: .pink, subject: .algebra,
            formula: "aˣ = aⁿ  →  x = n (same base)\naˣ = b  →  x = logₐ(b) (different base, take log)",
            keyInsight: "If two exponentials with the same base are equal, their exponents must be equal.",
            whyItWorks: """
            Exponential functions aˣ are one-to-one (strictly increasing for a > 1). That means aˣ = aⁿ has exactly one solution: x = n. When the bases aren't the same, take the log of both sides. log(aˣ) = x·log(a), so x = log(b)/log(a). The natural log (ln) is especially useful since many calculators have it directly. Remember: taking log of both sides doesn't change the equation — logs are defined to undo exponentials.
            """,
            whenToUse: "The variable appears in an exponent. Try to make both sides the same base first; if that's impossible, take log of both sides.",
            workedExample: """
            2^x = 64
            64 = 2⁶
            x = 6
            """,
            extraExamples: [
                ("3^(2x) = 81", """
                81 = 3⁴, so 2x = 4
                x = 2
                """),
                ("5^x = 125", """
                125 = 5³
                x = 3
                """),
                ("2^x = 32", """
                32 = 2⁵
                x = 5
                """)
            ],
            commonMistakes: [
                "Trying to solve 2^x = 12 by rewriting 12 as a power of 2 — you can't. Take log: x = log(12)/log(2).",
                "Confusing 2^x = 8 (answer x=3) with x^2 = 8 (answer x = 2√2). The position of x changes everything."
            ],
            videoURL: "https://www.khanacademy.org/math/algebra2/x2ec2f6f830c9fb89:exp/x2ec2f6f830c9fb89:exp-equation/v/solving-exponential-equations"
        ),

        LearningTopic(
            name: "Sequences & Series",
            subtitle: "Arithmetic and geometric patterns",
            icon: "…",
            level: .expert, technique: "Sequences", color: .teal, subject: .algebra,
            formula: "Arithmetic: aₙ = a₁ + (n−1)d,   Sₙ = n(a₁+aₙ)/2\nGeometric:  aₙ = a₁·rⁿ⁻¹,   Sₙ = a₁(rⁿ−1)/(r−1)",
            keyInsight: "Arithmetic sequences grow by addition (constant gap). Geometric sequences grow by multiplication (constant ratio).",
            whyItWorks: """
            An arithmetic sequence has a constant difference d between terms: a, a+d, a+2d, … The sum of n terms can be computed by pairing the first and last: Sₙ = n·(first+last)/2. A geometric sequence has a constant ratio r between terms: a, ar, ar², … Each term is the previous term times r. The sum formula for geometric series comes from the clever trick of computing S − rS, which collapses to just a−arⁿ.
            """,
            whenToUse: "Pattern problems: constant gap between terms → arithmetic. Constant ratio between terms → geometric.",
            workedExample: """
            Arithmetic: 3, 7, 11, 15, …  (d = 4)
            10th term: 3 + 9·4 = 39
            Sum of 5 terms: 5·(3+19)/2 = 55
            """,
            extraExamples: [
                ("Geometric: 2, 6, 18, …  (r=3), find 5th term", """
                a₅ = 2·3⁴ = 2·81 = 162
                """),
                ("Sum first 4 terms of 1, 2, 4, 8, …", """
                Sₙ = 1·(2⁴−1)/(2−1) = 15
                """)
            ],
            commonMistakes: [
                "Using aₙ = a₁ + n·d instead of a₁ + (n−1)·d. When n=1, the first term should just be a₁ (no d added).",
                "Using the geometric formula when the sequence is arithmetic. Check: constant difference or constant ratio?"
            ],
            videoURL: "https://www.khanacademy.org/math/algebra/x2f8bb11595b61c86:sequences/x2f8bb11595b61c86:constructing-arithmetic-sequences/v/arithmetic-sequences"
        ),

        LearningTopic(
            name: "Completing the Square",
            subtitle: "Rewrite quadratics in vertex form",
            icon: "⬛",
            level: .advanced, technique: "Completing the Square", color: .indigo, subject: .algebra,
            formula: "x² + bx + c → (x + b/2)² + (c − b²/4)\nVertex form: a(x−h)² + k",
            keyInsight: "Completing the square turns any quadratic into a perfect square plus a constant — revealing the vertex instantly.",
            whyItWorks: """
            A perfect square trinomial looks like (x + p)² = x² + 2px + p². To complete the square on x² + bx, you need to add (b/2)² to make it a perfect square. But since you're changing the expression, you must also subtract it. This gives x² + bx = (x + b/2)² − (b/2)². The resulting vertex form a(x−h)² + k reveals the vertex (h, k) directly and makes the min/max value obvious. The quadratic formula is actually just the completed-square result solved for x.
            """,
            whenToUse: "Converting to vertex form, finding the vertex of a parabola, or when the quadratic formula is needed but you want to derive it from scratch.",
            workedExample: """
            x² + 6x + 5
            Half of 6 = 3,  3² = 9
            = (x² + 6x + 9) − 9 + 5
            = (x+3)² − 4
            Vertex: (−3, −4)
            Zeros: x+3 = ±2 → x=−1 or x=−5
            """,
            extraExamples: [
                ("x² − 4x + 1", """
                Half of −4 = −2,  (−2)² = 4
                = (x−2)² − 4 + 1 = (x−2)² − 3
                Vertex: (2, −3)
                """)
            ],
            commonMistakes: [
                "Forgetting to subtract what you added. Adding (b/2)² changes the expression, so you must subtract it too.",
                "Completing the square when a ≠ 1. Factor out the leading coefficient from the x² and x terms first."
            ],
            videoURL: "https://www.khanacademy.org/math/algebra/x2f8bb11595b61c86:quadratics-multiplying-factoring/x2f8bb11595b61c86:completing-the-square/v/completing-the-square-1"
        ),
    ]
}

// MARK: - SAT MATH

extension LearningTopic {
    static let satTopics: [LearningTopic] = [

        LearningTopic(
            name: "Percent & Ratio",
            subtitle: "Convert, scale, and compare",
            icon: "%",
            level: .basic, technique: "Percent", color: .green, subject: .satMath,
            formula: "percent = (part/whole) × 100\npart = (percent/100) × whole\nwhole = part / (percent/100)",
            keyInsight: "Percent just means 'per hundred' — convert to a decimal (divide by 100) before multiplying.",
            whyItWorks: """
            'Percent' comes from the Latin 'per centum' — per hundred. So 30% literally means 30/100 = 0.30. To find 30% of 80, you compute 0.30 × 80 = 24. The SAT loves percent questions because they test whether you can move fluidly between the part, whole, and percent when any one of them is unknown. The most useful trick: when percent and whole are given, multiply; when part and whole are given, divide.
            """,
            whenToUse: "Any '% of' problem, percent increase/decrease, or expressing one number as a percent of another.",
            workedExample: """
            25% of 60:
            0.25 × 60 = 15

            18 is what % of 90?
            18/90 × 100 = 20%

            Price increases 40% from $50:
            50 × 1.40 = $70
            """,
            extraExamples: [
                ("30% off a $120 item", """
                Discount = 0.30 × 120 = 36
                Final price = 120 − 36 = 84
                Or: 120 × 0.70 = 84
                """),
                ("What % is 12 of 48?", """
                12/48 × 100 = 25%
                """)
            ],
            commonMistakes: [
                "Percent increase ≠ percent of final value. A 20% increase on $100 gives $120, not $80.",
                "Consecutive percents don't add: 20% off then 20% off ≠ 40% off. 0.8 × 0.8 = 0.64 (36% off total)."
            ],
            videoURL: "https://www.khanacademy.org/test-prep/sat/x0a8d1a85898e2b1a:math/x0a8d1a85898e2b1a:problem-solving-data-analysis-advanced/v/sat-math-problem-solving-data-analysis-percents"
        ),

        LearningTopic(
            name: "Slope & Linear Equations",
            subtitle: "Slope, intercepts, parallel/perpendicular lines",
            icon: "📐",
            level: .intermediate, technique: "Slope", color: .blue, subject: .satMath,
            formula: "m = (y₂−y₁)/(x₂−x₁)\ny = mx + b  (slope-intercept)\ny−y₁ = m(x−x₁)  (point-slope)",
            keyInsight: "Slope is rise over run — how much y changes for every 1 unit increase in x.",
            whyItWorks: """
            The slope formula measures steepness by comparing vertical change (rise = Δy) to horizontal change (run = Δx). The y-intercept b is where the line crosses the y-axis (set x = 0). For parallel lines, slopes are equal. For perpendicular lines, slopes multiply to −1 (they're negative reciprocals). Point-slope form is useful when you know a point and the slope — you don't need to solve for b first.
            """,
            whenToUse: "Finding slope from two points, graphing a line, identifying parallel/perpendicular lines, or writing a line's equation.",
            workedExample: """
            Line through (1,2) and (4,8):
            m = (8−2)/(4−1) = 6/3 = 2
            y = 2x + b
            2 = 2(1) + b → b = 0
            Equation: y = 2x
            """,
            extraExamples: [
                ("Slope of 4x − 2y = 8", """
                Solve for y: y = 2x − 4
                Slope = 2
                """),
                ("Perpendicular to slope 3", """
                Perpendicular slope = −1/3
                """)
            ],
            commonMistakes: [
                "Flipping rise and run: slope = Δy/Δx (rise over run), NOT Δx/Δy.",
                "Parallel lines have equal slopes; perpendicular lines have slopes that are NEGATIVE RECIPROCALS, not just reciprocals."
            ],
            videoURL: "https://www.khanacademy.org/test-prep/sat/x0a8d1a85898e2b1a:math/x0a8d1a85898e2b1a:heart-of-algebra/v/sat-math-heart-of-algebra-slope"
        ),

        LearningTopic(
            name: "Geometry Essentials",
            subtitle: "Area, perimeter, Pythagorean theorem, circles",
            icon: "📦",
            level: .basic, technique: "Geometry", color: .orange, subject: .satMath,
            formula: "Triangle: A = ½bh\nCircle: A = πr², C = 2πr\nPythagorean: a²+b²=c²\nRectangle: A = lw",
            keyInsight: "The SAT provides a formula sheet — the challenge is identifying WHICH formula applies, not memorizing them.",
            whyItWorks: """
            Geometry problems on the SAT are really logic problems: identify the shape, identify what you know, identify what you need, choose the formula. The Pythagorean theorem is the most used. Memorize the common right triangles (3-4-5, 5-12-13, 30-60-90, 45-45-90) — they show up constantly. For area problems, always identify base and height carefully: height must be perpendicular to the base.
            """,
            whenToUse: "Any problem involving shapes, distances, angles, or areas.",
            workedExample: """
            Right triangle: legs 5 and 12.
            c² = 5²+12² = 25+144 = 169
            c = 13

            Circle with radius 4:
            A = π(16) ≈ 50.3
            C = 8π ≈ 25.1
            """,
            extraExamples: [
                ("Triangle: base=10, height=6", """
                A = ½·10·6 = 30
                """),
                ("Rectangle: l=8, w=5", """
                A = 40,  Perimeter = 26
                """)
            ],
            commonMistakes: [
                "Using a slant side as the 'height' in area formulas. Height must be perpendicular to the base.",
                "Confusing radius and diameter: d = 2r. If the problem gives diameter, halve it first."
            ],
            videoURL: "https://www.khanacademy.org/test-prep/sat/x0a8d1a85898e2b1a:math/x0a8d1a85898e2b1a:passport-to-advanced-math/v/sat-math-passport-to-advanced-math-triangles"
        ),

        LearningTopic(
            name: "Functions",
            subtitle: "Evaluate, compose, and interpret f(x)",
            icon: "f(x)",
            level: .intermediate, technique: "Function", color: .purple, subject: .satMath,
            formula: "f(a): substitute x = a everywhere\n(f∘g)(x) = f(g(x))\nf⁻¹: swap x and y, solve for y",
            keyInsight: "A function is a machine — f(x) tells you what comes out when x goes in. Just substitute.",
            whyItWorks: """
            A function maps each input to exactly one output. f(3) means: wherever you see x in the formula, replace it with 3. Composition f(g(x)) means: compute g(x) first, then feed that result into f. Inverse functions reverse the machine: f⁻¹ takes the output and gives back the input. On the SAT, most function questions are substitution or reading from a graph — they're testing whether you know that f(x) = 'plug in x.'
            """,
            whenToUse: "Any problem with f(x) notation, tables of values, or function machines.",
            workedExample: """
            f(x) = 3x² − 2
            f(3) = 3(9) − 2 = 25
            f(−1) = 3(1) − 2 = 1

            g(x) = x+1: f(g(2)) = f(3) = 25
            """,
            extraExamples: [
                ("f(x) = x²+1, g(x) = 2x, find f(g(3))", """
                g(3) = 6
                f(6) = 36+1 = 37
                """),
                ("If f(x) = 2x+4, find f⁻¹(x)", """
                y = 2x+4 → swap: x = 2y+4
                y = (x−4)/2 = f⁻¹(x)
                f⁻¹(8) = 2
                """)
            ],
            commonMistakes: [
                "f(2x) ≠ 2·f(x). You must substitute 2x everywhere x appears, then simplify.",
                "f(a+b) ≠ f(a)+f(b) in general. Only linear functions satisfy this."
            ],
            videoURL: "https://www.khanacademy.org/test-prep/sat/x0a8d1a85898e2b1a:math/x0a8d1a85898e2b1a:passport-to-advanced-math/v/sat-math-passport-to-advanced-math-functions"
        ),

        LearningTopic(
            name: "Exponents & Roots",
            subtitle: "Power rules and simplifying radicals",
            icon: "√",
            level: .advanced, technique: "Exponents", color: .teal, subject: .satMath,
            formula: "aᵐ·aⁿ = aᵐ⁺ⁿ\n(aᵐ)ⁿ = aᵐⁿ\naᵐ/aⁿ = aᵐ⁻ⁿ\na⁻ⁿ = 1/aⁿ\na^(1/n) = ⁿ√a",
            keyInsight: "All exponent rules follow from the definition: aⁿ = a × a × a × … (n times).",
            whyItWorks: """
            When you multiply aᵐ · aⁿ, you're multiplying m copies of a by n copies of a — total m+n copies, so aᵐ⁺ⁿ. Raising to a power: (aᵐ)ⁿ is aᵐ repeated n times, giving aᵐⁿ. Negative exponents come from the division rule: a⁰/aⁿ = 1/aⁿ = a⁻ⁿ. Fractional exponents are defined so the rules still work: (a^(1/n))ⁿ = a, so a^(1/n) must equal the nth root.
            """,
            whenToUse: "Simplifying expressions with the same base, solving equations like 2^(2x) = 64, or converting between radical and exponent form.",
            workedExample: """
            Simplify: (2³)² = 2⁶ = 64

            Solve: 2^(2x) = 64 = 2⁶
            2x = 6 → x = 3

            √48 = √(16·3) = 4√3
            """,
            extraExamples: [
                ("Simplify: x³·x⁵", """
                x³⁺⁵ = x⁸
                """),
                ("Simplify: (x²)³/x⁴", """
                = x⁶/x⁴ = x²
                """)
            ],
            commonMistakes: [
                "(a+b)² ≠ a²+b². You must FOIL: (a+b)² = a²+2ab+b².",
                "a^(−n) = 1/aⁿ, NOT −aⁿ. The negative exponent means reciprocal, not negative value."
            ],
            videoURL: "https://www.khanacademy.org/math/cc-eighth-grade-math/cc-8th-numbers-operations/cc-8th-exponent-properties/v/exponent-properties-involving-products"
        ),

        LearningTopic(
            name: "Statistics & Data",
            subtitle: "Mean, median, range, and standard deviation",
            icon: "📊",
            level: .basic, technique: "Statistics", color: .indigo, subject: .satMath,
            formula: "Mean = sum of values / count\nMedian = middle value when sorted\nRange = max − min\nMode = most frequent value",
            keyInsight: "On the SAT, the median is more robust than the mean — an outlier can dramatically skew the mean.",
            whyItWorks: """
            The mean (average) adds everything and divides — it accounts for every value but is sensitive to outliers. The median finds the middle value when sorted — it's resistant to extreme values. If a dataset has n numbers (sorted), the median is the ((n+1)/2)th value for odd n, or the average of the two middle values for even n. The range tells you the spread; standard deviation tells you how far values typically stray from the mean.
            """,
            whenToUse: "Any SAT problem with a list of numbers, a bar chart, histogram, or scatter plot asking for a statistical measure.",
            workedExample: """
            Data: 4, 7, 9, 12, 3
            Sorted: 3, 4, 7, 9, 12
            Mean = (3+4+7+9+12)/5 = 35/5 = 7
            Median = 7 (middle value)
            Range = 12 − 3 = 9
            """,
            extraExamples: [
                ("Data: 2, 5, 5, 8, 10", """
                Mean = 30/5 = 6
                Median = 5
                Mode = 5 (appears twice)
                Range = 10−2 = 8
                """)
            ],
            commonMistakes: [
                "Finding median without sorting first — always sort the data before finding the middle.",
                "For an even number of data points, the median is the AVERAGE of the two middle values, not either one."
            ],
            videoURL: "https://www.khanacademy.org/test-prep/sat/x0a8d1a85898e2b1a:math/x0a8d1a85898e2b1a:problem-solving-data-analysis-basic/v/sat-math-problem-solving-data-analysis-mean-median-mode"
        ),
    ]
}

// MARK: - PHYSICS

extension LearningTopic {
    static let physicsTopics: [LearningTopic] = [

        LearningTopic(
            name: "Newton's Laws",
            subtitle: "Force = mass × acceleration",
            icon: "🍎",
            level: .basic, technique: "Newton's 2nd Law", color: .green, subject: .physics,
            formula: "F = ma\nWeight: W = mg  (g ≈ 10 m/s²)\nNet force = sum of all forces",
            keyInsight: "Forces cause acceleration — the more mass, the more force needed to produce the same acceleration.",
            whyItWorks: """
            Newton's First Law says objects don't accelerate unless a net force acts on them. The Second Law (F = ma) quantifies this: net force equals mass times acceleration. The Third Law adds that forces come in pairs — if A pushes B, B pushes A with equal force in the opposite direction. On a free-body diagram, always identify ALL forces acting on the object, then sum them to find the net force. Weight is a force (not mass): W = mg, pointing downward.
            """,
            whenToUse: "Any problem asking for force, mass, or acceleration — or finding the net force from multiple forces.",
            workedExample: """
            m = 5 kg, a = 6 m/s²
            F = ma = 5 × 6 = 30 N

            Weight of m = 8 kg:
            W = 8 × 10 = 80 N downward
            """,
            extraExamples: [
                ("F = 45 N, m = 9 kg, find a", """
                a = F/m = 45/9 = 5 m/s²
                """),
                ("Two forces: 20 N right, 8 N left", """
                Net F = 20−8 = 12 N right
                If m = 3 kg: a = 12/3 = 4 m/s²
                """)
            ],
            commonMistakes: [
                "Confusing mass (kg) and weight (N). Weight is the gravitational force: W = mg.",
                "Using g = 9.8 vs g = 10. In AP problems use 9.8; in algebra-based use 10 unless told otherwise.",
                "Forgetting that F = ma uses NET force, not any single force."
            ],
            videoURL: "https://www.khanacademy.org/science/physics/forces-newtons-laws/newtons-laws-of-motion/v/newton-s-second-law-of-motion"
        ),

        LearningTopic(
            name: "Kinematics",
            subtitle: "The Big 4 motion equations",
            icon: "🚗",
            level: .basic, technique: "Kinematics", color: .blue, subject: .physics,
            formula: "v = u + at\nd = ut + ½at²\nv² = u² + 2ad\nd = (u+v)/2 · t",
            keyInsight: "You need 3 knowns to find the 4th. Match the equation to avoid the unknown you don't need.",
            whyItWorks: """
            For constant acceleration, these four equations completely describe motion. They come from calculus: integrating a = constant gives v = u + at (velocity as a function of time); integrating again gives d = ut + ½at². The equation v² = u² + 2ad is derived by eliminating t from the first two. In problems: identify u (initial velocity), v (final velocity), a (acceleration), t (time), d (displacement). Then pick the equation that contains your 3 knowns and 1 unknown.
            """,
            whenToUse: "Any constant-acceleration problem: projectile, car braking, free fall (a = g = 10 m/s² downward).",
            workedExample: """
            u=0, a=3 m/s², t=4 s
            v = 0 + 3·4 = 12 m/s
            d = 0·4 + ½·3·16 = 24 m
            """,
            extraExamples: [
                ("u=20, v=0, a=−5 (braking) find d", """
                v² = u² + 2ad
                0 = 400 + 2(−5)d
                d = 400/10 = 40 m
                """),
                ("Free fall from rest, t=3 s", """
                d = ½·10·9 = 45 m
                v = 10·3 = 30 m/s downward
                """)
            ],
            commonMistakes: [
                "Using the wrong sign for a. Deceleration means a is negative (or opposite to v). Free fall: a = −10 m/s² (down).",
                "Using u and v interchangeably. u = INITIAL velocity, v = FINAL velocity.",
                "Using these equations when acceleration is NOT constant (e.g., friction with changing normal force)."
            ],
            videoURL: "https://www.khanacademy.org/science/physics/one-dimensional-motion/kinematic-formulas/v/kinematic-formulas-and-projectile-motion"
        ),

        LearningTopic(
            name: "Work & Energy",
            subtitle: "W = Fd, conservation of energy",
            icon: "⚡️",
            level: .intermediate, technique: "Work", color: .yellow, subject: .physics,
            formula: "W = Fd·cosθ\nKE = ½mv²\nPE (gravity) = mgh\nConservation: KE₁ + PE₁ = KE₂ + PE₂",
            keyInsight: "Energy is conserved — it just converts between forms. What's lost to friction becomes heat.",
            whyItWorks: """
            Work transfers energy: W = Fd measures how much energy a force F transfers over displacement d. If F and d are in the same direction, cosθ = 1 and all the force contributes. If perpendicular (θ=90°), no work is done. Kinetic energy (½mv²) is the energy of motion; gravitational PE (mgh) is stored energy based on height. The Work-Energy Theorem states the net work done on an object equals its change in KE: W_net = ΔKE. When friction is absent, total mechanical energy (KE + PE) is constant.
            """,
            whenToUse: "Energy transfer, objects on ramps, collisions (elastic: KE conserved; inelastic: KE lost), conservation of energy problems.",
            workedExample: """
            F = 10 N, d = 6 m (same direction):
            W = 10 × 6 = 60 J

            Ball: m=2 kg, v=6 m/s
            KE = ½·2·36 = 36 J

            Object: m=3 kg, h=4 m:
            PE = 3·10·4 = 120 J
            """,
            extraExamples: [
                ("Ball drops from h=5 m (m=1 kg)", """
                PE lost = mgh = 1·10·5 = 50 J
                KE gained = 50 J
                v = √(2·50/1) = √100 = 10 m/s
                """),
                ("W done by 30 N force at 60° over 10 m", """
                W = 30·10·cos(60°) = 300·0.5 = 150 J
                """)
            ],
            commonMistakes: [
                "Forgetting the cosθ factor. Only the component of force along the displacement does work.",
                "Using mass instead of weight for PE. PE = mgh uses mass (kg), not weight (N)."
            ],
            videoURL: "https://www.khanacademy.org/science/physics/work-and-energy/work-and-energy-tutorial/v/introduction-to-work-and-energy"
        ),

        LearningTopic(
            name: "Impulse & Momentum",
            subtitle: "p = mv, J = FΔt, conservation of momentum",
            icon: "💥",
            level: .intermediate, technique: "Momentum", color: .orange, subject: .physics,
            formula: "p = mv\nJ = FΔt = Δp\nConservation: m₁v₁ + m₂v₂ = m₁v₁' + m₂v₂'",
            keyInsight: "Momentum is always conserved in collisions — even when kinetic energy is not.",
            whyItWorks: """
            Momentum (p = mv) measures the 'quantity of motion.' Newton's Second Law can be rewritten as F = Δp/Δt — force is the rate of change of momentum. Impulse (J = FΔt) is the change in momentum; it equals the area under a force-time graph. In a closed system (no external forces), total momentum is conserved: the sum before equals the sum after a collision. In elastic collisions, KE is also conserved; in perfectly inelastic collisions, objects stick together and KE is lost.
            """,
            whenToUse: "Collisions, explosions, rockets, objects that exert forces on each other, and any situation where you need to find change in velocity from a force over time.",
            workedExample: """
            Collision: m₁=2kg, v₁=6, m₂=3kg, v₂=0
            Perfectly inelastic (stick together):
            2·6 + 3·0 = (2+3)v'
            12 = 5v' → v' = 2.4 m/s

            Impulse: F=20N, Δt=3s
            J = 60 N·s = Δp
            """,
            extraExamples: [
                ("p of m=5 kg, v=8 m/s", """
                p = 5·8 = 40 kg·m/s
                """),
                ("Force 15N for 4s on 3kg object at rest", """
                J = 60 N·s = Δp
                v_f = 60/3 = 20 m/s
                """)
            ],
            commonMistakes: [
                "Momentum is a vector — direction matters. In 1D: take rightward as positive and leftward as negative.",
                "Confusing elastic and inelastic. Objects sticking together = perfectly inelastic, NOT elastic."
            ],
            videoURL: "https://www.khanacademy.org/science/physics/linear-momentum/momentum-tutorial/v/introduction-to-momentum"
        ),

        LearningTopic(
            name: "Calculus-Based Mechanics (AP C)",
            subtitle: "Derivatives and integrals in motion",
            icon: "∫",
            level: .advanced, technique: "Kinematics (Integral)", color: .purple, subject: .physics,
            formula: "v = dx/dt → x = ∫v dt\na = dv/dt → v = ∫a dt\nW = ∫F dx",
            keyInsight: "Position, velocity, and acceleration are just successive derivatives of the same motion — and integration gives the totals.",
            whyItWorks: """
            In AP Physics C, acceleration is rarely constant. When a = f(t) or F = f(x), you need calculus. Velocity is the derivative of position: v = dx/dt. Acceleration is the derivative of velocity: a = dv/dt. To go the other way, integrate: x = ∫v dt, v = ∫a dt. Work done by a variable force uses W = ∫F(x)dx (the area under a force-position graph). These ideas connect Newton's second law (F = ma = m dv/dt) directly to calculus.
            """,
            whenToUse: "AP Physics C problems where position, velocity, acceleration, or force is given as a function of time or position.",
            workedExample: """
            v(t) = 3t²  m/s
            x = ∫₀² 3t² dt = [t³]₀² = 8 m

            F(x) = 2x  N
            W = ∫₀³ 2x dx = [x²]₀³ = 9 J
            """,
            extraExamples: [
                ("a(t) = 6t, find v at t=4 (v₀=0)", """
                v = ∫₀⁴ 6t dt = [3t²]₀⁴ = 48 m/s
                """),
                ("v(t) = 4t, find displacement t=0 to t=3", """
                x = ∫₀³ 4t dt = [2t²]₀³ = 18 m
                """)
            ],
            commonMistakes: [
                "Differentiating to get displacement — that's wrong. Integrate velocity to get position.",
                "Forgetting initial conditions. v = ∫a dt gives v(t) = … + v₀, using whatever the initial velocity is."
            ],
            videoURL: "https://www.khanacademy.org/science/ap-physics-1/ap-one-dimensional-motion/ap-kinematic-formulas/v/deriving-kinematics-equations-using-calculus"
        ),

        LearningTopic(
            name: "Rotational Motion (AP C)",
            subtitle: "τ = Iα, angular kinematics",
            icon: "🌀",
            level: .expert, technique: "Rotational Dynamics", color: .cyan, subject: .physics,
            formula: "τ = rF·sinθ (torque)\nτ_net = Iα\nI = Σmr²\nL = Iω  (angular momentum)",
            keyInsight: "Rotational mechanics mirrors linear mechanics: torque plays the role of force, moment of inertia plays the role of mass.",
            whyItWorks: """
            Every concept in linear mechanics has a rotational analog. Where F=ma governs linear motion, τ=Iα governs rotation. Torque τ (tau) is the rotational equivalent of force — it depends on the force AND how far from the pivot it acts (the moment arm r). The moment of inertia I measures how mass is distributed around the axis of rotation; farther mass means larger I and harder to spin. Conservation of angular momentum (L = Iω = constant when no external torque) explains why a spinning skater speeds up when pulling arms in.
            """,
            whenToUse: "Any AP Physics C problem involving rotating objects, pulleys, rolling, or angular acceleration.",
            workedExample: """
            Torque: F=20N, r=0.5m at 90°
            τ = 0.5·20·sin(90°) = 10 N·m

            I=2 kg·m², α=5 rad/s²
            τ_net = 2·5 = 10 N·m
            """,
            extraExamples: [
                ("Disk: M=4kg, R=0.5m, I=½MR²", """
                I = ½·4·0.25 = 0.5 kg·m²
                τ=2 N·m → α = τ/I = 4 rad/s²
                """)
            ],
            commonMistakes: [
                "Using F=ma for rotation. Torque isn't force × mass — it's τ = Iα.",
                "Forgetting the sinθ in τ = rFsinθ. If the force is perpendicular to the moment arm, sinθ=1; otherwise it reduces the torque."
            ],
            videoURL: "https://www.khanacademy.org/science/ap-physics-1/ap-torque-angular-momentum/introduction-to-torque-ap/v/introduction-to-torque"
        ),

        LearningTopic(
            name: "E&M: Circuits (AP C)",
            subtitle: "Capacitors, inductors, RC/RL circuits",
            icon: "⚛️",
            level: .expert, technique: "Faraday's Law", color: .cyan, subject: .physics,
            formula: "Q = CV,  U_C = ½CV²\nEMF = |dΦ/dt|,  Φ = B·A\nU_L = ½LI²\nτ_RC = RC,  τ_RL = L/R",
            keyInsight: "Faraday's Law says changing magnetic flux creates EMF — this is the principle behind every generator and transformer.",
            whyItWorks: """
            Faraday's Law (EMF = −dΦ/dt) connects magnetism and electricity: a changing magnetic flux Φ = B·A·cosθ through a loop creates an electromotive force (voltage). The negative sign (Lenz's Law) means the induced current opposes the change that created it. For circuits: capacitors store energy in electric fields (U = ½CV²), inductors store energy in magnetic fields (U = ½LI²). RC circuits charge/discharge exponentially with time constant τ = RC; RL circuits with τ = L/R. These time constants describe how 'fast' the circuit responds.
            """,
            whenToUse: "AP Physics C E&M problems involving changing flux, induced EMF, capacitors storing charge, or inductors in circuits.",
            workedExample: """
            Φ(t) = 3t² Wb
            EMF = |dΦ/dt| = 6t V
            At t=5 s: EMF = 30 V

            C=4F, V=3V:
            Q = CV = 12 C
            U = ½·4·9 = 18 J
            """,
            extraExamples: [
                ("Φ(t) = 5t + 2, find EMF", """
                EMF = |dΦ/dt| = 5 V (constant)
                """),
                ("L=3H, I=4A, find energy", """
                U = ½·3·16 = 24 J
                """)
            ],
            commonMistakes: [
                "EMF = Φ, NOT EMF = dΦ/dt. Flux itself doesn't create EMF — only CHANGING flux does.",
                "Forgetting the absolute value: EMF is always a positive magnitude; the negative sign (Lenz) tells you direction."
            ],
            videoURL: "https://www.khanacademy.org/science/ap-physics-2/ap-circuits/ap-capacitors-and-capacitance/v/capacitors-and-capacitance"
        ),
    ]
}
