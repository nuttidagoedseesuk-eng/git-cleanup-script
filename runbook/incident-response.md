# Incident Response Runbook — FLOWPILOT AI

## 🚨 Purpose
This document defines how to respond when the system enters an unstable state such as:
- Merge conflicts
- Broken branch state
- Unexpected repository divergence
- Failed deployments

---

## 🔴 Severity Levels

### LOW
Minor conflict, safe to resolve on GitHub UI

### MEDIUM
Branch out of sync with main

### HIGH
Multiple conflicts across files or broken repo state

### CRITICAL
Cannot merge, unstable history, or accidental destructive operations

---

## 🧭 Step 1 — Stop All Changes

Do NOT:
- commit
- push
- force merge

Freeze changes immediately.

---

## 🔁 Step 2 — Return to Stable State

```bash id="step2"
git checkout main
git pull origin main