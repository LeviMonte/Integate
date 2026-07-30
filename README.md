# Integate

**Earn your screen time by solving math problems.**

Integate uses Apple's Screen Time API (FamilyControls) to block apps you choose. When you try to open an app, a solve screen appears where you must answer a calculus, algebra, or physics problem to gain screentime and unlock it. The harder the problem, the more time you earn.

---

## Features

- **5 subjects**: Integrals, Derivatives, Algebra, SAT Math, AP Physics
- **4 difficulty levels** per subject, unlocked progressively
- **200+ problems** with digit-by-digit input (no guessing)
- **Hint system** with time penalty for using hints
- **Worked solution** shown on failure so you can learn
- **Streak tracking**: consecutive first-try solves earn bonus time
- **Learn tab**: explanations, worked examples, common mistakes, and video links per topic
- **Timer behavior (optional)**: earned time either counts down continuously from the moment you solve, or — if you flip the "only count down while using apps" setting — only depletes while you're actually in a blocked app
- **Report a problem** opens Mail pre-filled with problem context (OR JUST USE THIS GITHUB)

8 Bugs fixed to date (7/29/26)

---

## How it works

1. First launch walks you straight into granting Screen Time permission and picking the apps/categories to block, no digging through Settings required
2. (Or later: Integate → Settings → Manage Blocked Apps)
3. When you open a blocked app, a shield appears: "Solve to Unlock"
4. Tap "Open Integate →" → a notification fires → tap it → Integate opens with a problem ready
5. Solve the problem → shields lift → you have earned time to use the app freely
6. Timer runs out → apps re-lock automatically, which is enforced by Apple's FamilyControls/DeviceActivity APIs, not an honor system like earlier descriptions stated.

---

## Contact

Levimonte18@gmail.com
