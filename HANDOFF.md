# Integate — Developer Handoff

**GitHub:** https://github.com/LeviMonte/Integate  
**Local project:** `~/Desktop/MathGate/`  
**App name:** Integate (was MathGate — fully renamed in code, bundle ID is `com.Monte.Integate`)  
**Owner:** Levi Monte — Levimonte18@gmail.com  

---

## What the app does

Integate uses Apple's FamilyControls API to **actually block** apps the user selects. When they try to open a blocked app, a custom shield appears: "Solve to Unlock." They tap a button, get redirected to Integate, solve a math problem, and earn timed access. The harder the problem, the more time unlocked.

**5 subjects:** Integrals, Derivatives, Algebra, SAT Math, AP Physics  
**4 difficulty levels** per subject, unlocked progressively  
**200+ problems** with digit-by-digit input, hint system, worked solutions on failure  
**Streak system** with multipliers and Double-or-Nothing  
**Learn tab** with explanations, examples, common mistakes, video links  
**Time-of-day difficulty scaling** (harder in evenings)  
**Report-a-problem** — opens Mail pre-filled with problem context  

---

## Current state — what works vs. what's broken

### ✅ Working
- All 5 subject problem banks, all 4 difficulty levels
- Digit-by-digit answer input (DigitInputView)
- Hint system with 50% time penalty
- Worked solution shown on failure
- Streak tracking + Double-or-Nothing
- Progress tab (XP, solves per subject, level unlock progress)
- Learn tab with rich topic content
- Settings: session time cap, blocked app picker, reset progress, report a problem
- Onboarding flow (first launch)
- FamilyControls authorization request
- FamilyActivityPicker (app/category selection UI)
- ManagedSettingsStore blocking (restrictions applied correctly in code)
- Pending unlock banner in UnlockView (shows when user taps "Open Integate →" on shield)
- Timer countdown + auto re-lock on expiry
- All code compiles clean (last known good build: July 2026)

### ❌ Broken — needs fixing before App Store submission

#### Bug 1: Custom shield doesn't appear — shows default iOS "restricted" message instead
**Symptom:** Opening a blocked app shows Apple's generic "You cannot use Instagram because it is restricted. Tap OK to continue." instead of the custom purple "Solve to Unlock" shield.  
**Root cause:** The `ShieldConfigurationExtension` and `ShieldActionExtension` Xcode targets have NOT been created yet. The Swift files exist in the repo (`ShieldConfigurationExtension/ShieldConfigurationExtension.swift` and `ShieldActionExtension/ShieldActionExtension.swift`) but Xcode doesn't know about them — they were never added as extension targets in the `.xcodeproj`. Without the targets, iOS has no custom shield extension to load and falls back to the default message.  
**Fix:** See "Xcode Setup Required" section below. This is entirely Xcode configuration — no Swift code changes needed.

#### Bug 2: Screen Time permission prompt appears every time a blocked app is opened
**Symptom:** The FamilyControls authorization dialog keeps appearing.  
**Root cause:** Likely the same as Bug 1 — without a properly signed + provisioned extension, iOS may re-trigger auth on every attempt. Once the extension targets are created with proper App Group entitlements, this should resolve. If it persists after fix #1, the secondary cause is that `applyRestrictions()` is being called in `resumeIfNeeded()` on every launch while `activitySelection` is empty (data not loaded yet from UserDefaults), which clears and re-sets the store unnecessarily. Fix: add a guard in `resumeIfNeeded()` to skip `applyRestrictions()` if `activitySelection.applicationTokens.isEmpty`.

---

## File structure

```
MathGate/
├── MathGate/                          Main app target
│   ├── MathGateApp.swift              App entry point, injects environment objects
│   ├── ContentView.swift              TabView (Unlock, Learn, Progress, Settings) + SettingsView
│   ├── Item.swift                     Unused boilerplate — can delete
│   ├── Managers/
│   │   ├── MathEngine.swift           Problem bank (200+ problems, all 5 subjects × 4 levels)
│   │   ├── ScreenTimeManager.swift    FamilyControls + ManagedSettingsStore (the core manager)
│   │   └── StreakManager.swift        Streak tracking, multipliers, Double-or-Nothing
│   ├── Models/
│   │   ├── MathProblem.swift          MathProblem struct, MathSubject/MathLevel enums
│   │   ├── UserProgress.swift         XP, solves, level unlock logic, persistence
│   │   └── LearningContent.swift      Rich topic data for the Learn tab
│   └── Views/
│       ├── UnlockView.swift           Main solve screen (idle → solving → success/failed)
│       ├── LearningView.swift         Topic list + detail view
│       ├── ProgressView.swift         Stats, XP, per-subject progress bars
│       ├── AppPickerView.swift        FamilyActivityPicker wrapper (blocked app selector)
│       ├── DigitalInputView.swift     Digit-by-digit answer input + submit logic
│       ├── ProblemCardView.swift      Problem display card
│       ├── OnboardingView.swift       First-launch walkthrough
│       └── ReportProblemView.swift    Opens Mail with problem context pre-filled
├── ShieldConfigurationExtension/      ⚠️ Swift file exists, Xcode target NOT created yet
│   └── ShieldConfigurationExtension.swift
├── ShieldActionExtension/             ⚠️ Swift file exists, Xcode target NOT created yet
│   └── ShieldActionExtension.swift
├── ShieldConfigExtension/             ⚠️ Duplicate folder — appears to be an Xcode artifact, delete this
│   └── ShieldConfigurationExtension.swift
├── MathGateTests/                     Unit test stub (mostly empty)
├── MathGateUITests/                   UI test stub (mostly empty)
├── README.md
├── FAMILYCONTROLS_SETUP.md            Detailed Xcode setup instructions
├── HANDOFF.md                         This file
├── AppStoreDescription.md
└── PRIVACY.md
```

---

## Key architecture notes

### ScreenTimeManager (the most important file)
`MathGate/Managers/ScreenTimeManager.swift`

- `appGroupID = "group.com.monte.integate"` — must match in both extensions and the main app's App Groups entitlement
- `activitySelection: FamilyActivitySelection` — stored via JSONEncoder in both `UserDefaults.standard` and shared `UserDefaults(suiteName: appGroupID)`
- `applyRestrictions()` — writes to `ManagedSettingsStore.shared.shield.applications`; only works if `isAuthorized == true`
- `grantTime(seconds:)` — call this on successful solve; lifts shields, starts countdown
- `hasPendingUnlockRequest: Bool` — reads `mg_pendingUnlock` from shared UserDefaults; set to `true` by ShieldActionExtension when user taps "Open Integate →"
- `clearPendingUnlockRequest()` — called inside `grantTime()` automatically

### Inter-process communication (main app ↔ shield extensions)
The shield extensions are separate processes. They can't call UIApplication or directly open Integate. The flow is:
1. User taps "Open Integate →" on shield
2. `ShieldActionExtension` writes `mg_pendingUnlock = true` to App Group UserDefaults and fires a local notification
3. Shield closes (`.close` response)
4. User taps the notification or opens Integate manually
5. `UnlockView` checks `screenTime.hasPendingUnlockRequest` on appear → shows the blue "Solve to Unlock" banner
6. User solves → `grantTime()` → `clearPendingUnlockRequest()` + lifts shields

### UnlockView pending unlock banner
`MathGate/Views/UnlockView.swift` lines 52–237

Only shown when `screenTime.hasPendingUnlockRequest && phase == .idle`. Has:
- Inline subject switcher (horizontal scroll)
- Inline level picker (4 buttons, locked levels disabled)
- "Solve Now →" button that auto-picks highest unlocked level for the selected subject

---

## Xcode setup required (do this before archiving)

**These steps must be done manually in Xcode. No code changes needed.**

See `FAMILYCONTROLS_SETUP.md` for the full guide. Summary:

### Step 1 — Main app target (Integate)
Signing & Capabilities → + Capability → add all three:
- `Family Controls`
- `App Groups` → add group ID: `group.com.monte.integate`
- `Push Notifications`

### Step 2 — Create ShieldConfigurationExtension target
File → New → Target → **Shield Configuration Extension** → name it `ShieldConfigurationExtension`

Then:
1. Delete the auto-generated `.swift` file Xcode creates
2. Select `ShieldConfigurationExtension/ShieldConfigurationExtension.swift` in sidebar → File Inspector → Target Membership: check `ShieldConfigurationExtension`, uncheck `MathGate`
3. Add App Groups capability: `group.com.monte.integate`
4. Build Phases → Link Binary With Libraries → add `ManagedSettingsUI.framework` + `ManagedSettings.framework`

### Step 3 — Create ShieldActionExtension target
File → New → Target → **Shield Action Extension** → name it `ShieldActionExtension`

Then:
1. Delete the auto-generated `.swift` file
2. Select `ShieldActionExtension/ShieldActionExtension.swift` → Target Membership: check `ShieldActionExtension` only
3. Add App Groups capability: `group.com.monte.integate`
4. Build Phases → Link Binary With Libraries → add `ManagedSettings.framework`

### Step 4 — Signing
All three targets (main app + 2 extensions) need the same Team selected under Signing & Capabilities. Bundle IDs will be:
- Main app: `com.Monte.Integate`
- ShieldConfigurationExtension: `com.Monte.Integate.ShieldConfigExtension`
- ShieldActionExtension: `com.Monte.Integate.ShieldActionExtension`
(Xcode sets these automatically when you use the target template.)

### Step 5 — Clean and test on real device
- Product → Clean Build Folder (⇧⌘K)
- Select your iPhone (not Simulator — FamilyControls does not work in Simulator)
- Run (⌘R)
- Go through full flow: Settings → Manage Blocked Apps → Grant Permission → pick Instagram → press Home → open Instagram → should show purple "Solve to Unlock" shield

---

## App Store submission (after Xcode setup is confirmed working)

### 1. Create app in App Store Connect
- appstoreconnect.apple.com → My Apps → + → New App
- Name: `Integate`
- Bundle ID: `com.Monte.Integate`
- SKU: `integate-2026`
- Category: Education
- Price: Free

### 2. Fill metadata
- **Description:** use `AppStoreDescription.md`
- **Keywords:** `math, calculus, screen time, focus, integral, derivative, algebra, SAT, physics`
- **Support URL:** https://github.com/LeviMonte/Integate
- **Privacy Policy URL:** required — host `PRIVACY.md` content somewhere (GitHub Pages works)
- **App Privacy:** no data collected → answer No to all questions

### 3. Screenshots (required before submission)
Need screenshots at these sizes (take in Xcode Simulator with ⌘S):
- **6.9"** iPhone 16 Pro Max Simulator — required
- **6.5"** iPhone 14 Plus Simulator — required
- **5.5"** iPhone 8 Plus Simulator — required

Suggested screens to capture: the purple "Solve to Unlock" banner, a problem being solved (DigitInputView), the success screen, the Settings/blocked apps view.

### 4. Archive and upload
- Set destination in Xcode to **Any iOS Device (arm64)** (not your phone, not Simulator)
- Product → Archive
- Organizer opens → Distribute App → App Store Connect → Upload
- Wait 5–10 min for processing

### 5. Submit
- In App Store Connect, 1.0 Prepare for Submission → + Add Build → select the uploaded build
- Review Information notes: *"This app uses FamilyControls to block selected apps. To test: Settings → Manage Blocked Apps → Grant Permission → pick an app. Open that app — the custom shield appears. Solve the problem to unlock. FamilyControls requires a real device, not Simulator."*
- Click Submit to App Review

### Common rejection reasons to pre-empt
- Missing privacy policy URL — must be a live URL, not just a file
- FamilyControls entitlement requires Apple to approve the capability for App Store distribution — when submitting, make sure Family Controls is in your provisioning profile (Xcode does this automatically with automatic signing)
- Screenshots must actually show the app working

---

## If Bug 2 (repeated auth prompt) persists after fixing the extension targets

Add this guard to `resumeIfNeeded()` in `ScreenTimeManager.swift`:

```swift
private func resumeIfNeeded() {
    // Don't apply empty restrictions on launch — wait until activitySelection is loaded
    if let expiry = UserDefaults.standard.object(forKey: Keys.unlockExpiry) as? Date, expiry > Date() {
        removeRestrictions()
        unlockExpiryDate     = expiry
        timeRemainingSeconds = max(0, Int(expiry.timeIntervalSinceNow))
        isUnlocked           = true
        startCountdown(until: expiry)
    } else {
        UserDefaults.standard.removeObject(forKey: Keys.unlockExpiry)
        // Only apply if we actually have apps selected
        if !activitySelection.applicationTokens.isEmpty || !activitySelection.categoryTokens.isEmpty {
            applyRestrictions()
        }
    }
}
```

---

## Minor cleanup items (not blockers)

- `MathGate/Item.swift` — unused CoreData boilerplate from project template, safe to delete
- `ShieldConfigExtension/` folder — appears to be a duplicate of `ShieldConfigurationExtension/`, created accidentally. Delete the whole folder (keep `ShieldConfigurationExtension/`).
- `MathGateTests/` and `MathGateUITests/` — stub files, no real tests written. Not a blocker.
