#!/bin/bash
# ─────────────────────────────────────────────────────────────
# MathGate — push to GitHub
#
# BEFORE RUNNING:
#   1. Go to github.com → New repository → name it "MathGate"
#      (make it Private if you want, no README, no .gitignore)
#   2. Copy the repo URL (looks like https://github.com/levimonte/MathGate.git)
#   3. Paste it below, then run:  bash push_to_github.sh
# ─────────────────────────────────────────────────────────────

REPO_URL="https://github.com/levimonte/MathGate.git"   # ← replace this

# ── sanity check ─────────────────────────────────────────────
if [[ "$REPO_URL" == *"YOUR_USERNAME"* ]]; then
  echo "❌  Paste your actual GitHub repo URL into REPO_URL first."
  exit 1
fi

cd "$(dirname "$0")"   # make sure we're in the MathGate folder

# ── init if needed ───────────────────────────────────────────
if [ ! -d ".git" ]; then
  echo "→ Initializing git repo..."
  git init
  git branch -M main
fi

# ── stage & commit ───────────────────────────────────────────
echo "→ Staging all files..."
git add -A

echo "→ Committing..."
git commit -m "Initial commit — MathGate v1.0" 2>/dev/null || \
git commit -m "Update — $(date '+%Y-%m-%d %H:%M')"

# ── remote ───────────────────────────────────────────────────
if git remote | grep -q "origin"; then
  git remote set-url origin "$REPO_URL"
else
  git remote add origin "$REPO_URL"
fi

# ── push ─────────────────────────────────────────────────────
echo "→ Pushing to GitHub..."
git push -u origin main

echo ""
echo "✅  Done! Your code is at: $REPO_URL"
