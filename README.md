# Integate

**Earn your screen time by solving math problems.**

Integate uses Apple's Screen Time API (FamilyControls) to actually block apps you choose. When you try to open one, a solve screen appears — answer a calculus, algebra, or physics problem to unlock it. The harder the problem, the more time you earn.

---

## Features

- **Real app blocking** via FamilyControls + ManagedSettingsStore — not an honor system
- **5 subjects**: Integrals, Derivatives, Algebra, SAT Math, AP Physics
- **4 difficulty levels** per subject, unlocked progressively
- **200+ problems** with digit-by-digit input (no guessing)
- **Hint system** with time penalty for using hints
- **Worked solution** shown on failure so you actually learn
- **Streak tracking** — consecutive first-try solves earn bonus time
- **Learn tab** — explanations, worked examples, common mistakes, and video links per topic
- **Difficulty scales with time of day** — harder at night, easier late night
- **Report a problem** — opens Mail pre-filled with problem context

---

## How it works

1. Open Integate → go to Settings → Manage Blocked Apps
2. Grant Screen Time permission
3. Pick the apps you want blocked
4. When you open a blocked app, a shield appears: "Solve to Unlock"
5. Tap "Open Integate →" → a notification fires → tap it → Integate opens with a problem ready
6. Solve the problem → shields lift → you have earned time to use the app freely
7. Timer runs out → apps re-lock automatically

---

## Setup (Xcode)

See `FAMILYCONTROLS_SETUP.md` for the full step-by-step guide to add the FamilyControls capability and the two required app extension targets (`ShieldConfigurationExtension` and `ShieldActionExtension`).

**Requirements:**
- Xcode 15+
- iOS 16+ deployment target
- Apple Developer account (any tier)
- Real iPhone for testing (FamilyControls does not work in Simulator)

---

## Project structure

```
MathGate/
├── MathGate/                      Main app target
│   ├── MathGateApp.swift
│   ├── ContentView.swift          Tab bar + Settings
│   ├── Managers/
│   │   ├── ScreenTimeManager.swift   FamilyControls + ManagedSettings
│   │   ├── MathEngine.swift          Problem bank (200+ problems)
│   │   └── StreakManager.swift
│   ├── Models/
│   │   ├── MathProblem.swift
│   │   ├── UserProgress.swift
│   │   └── LearningContent.swift     Rich topic data for the Learn tab
│   └── Views/
│       ├── UnlockView.swift          Main solve screen
│       ├── LearningView.swift
│       ├── AppPickerView.swift       FamilyActivityPicker wrapper
│       ├── OnboardingView.swift
│       └── ReportProblemView.swift
├── ShieldConfigurationExtension/  Customizes the iOS block screen UI
├── ShieldActionExtension/         Handles "Solve to Unlock" button tap
└── FAMILYCONTROLS_SETUP.md        Xcode capability setup guide
```

---

## Contact

Levimonte18@gmail.com
