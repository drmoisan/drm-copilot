# 2026-04-17-github-instructions-not-migrated-to-claude (Plan)

- **Issue:** #151
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-17
- **Status:** In Progress
- **Version:** 2.0
- **Work Mode:** full-bug
- **Plan path:** `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/plan.2026-04-17T16-13.md`

![In Progress](https://img.shields.io/badge/Status-In%20Progress-yellow)

---

## Overview

This plan closes the final two remaining gaps from issue #151 (incomplete migration of `.github/instructions/*.md` to `.claude/rules/*.md`). A prior agent session completed 14 of 15 in-scope implementation items. The sole required remaining action is synchronizing the bundled extension mirror `extensions/drm-copilot/resources/customizations/.github/agents/feature-review.agent.md` (41 lines) with the root `.github/agents/feature-review.agent.md` (112 lines): the Coverage Verification section, Constraints, Operating rules, and Phase A/B execution plan are absent from the bundled file. An optional improvement adds the explicit numbered-notes prohibition to `.claude/rules/self-explanatory-code-commenting.md` to align it with its source instruction file.

Source documents:
- `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/issue.md`
- `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/spec.md`
- `artifacts/research/20260417-github-instructions-not-migrated-to-claude-151-research.md`

---

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/issue.md` and `spec.md`; record the work mode (`full-bug`) and all 13 AC items (AC-1 through AC-13) verbatim in baseline evidence file `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/phase0-instructions-read.md`.
  - Acceptance: `phase0-instructions-read.md` exists and contains the fields `Timestamp:`, `Work Mode: full-bug`, `Policy Order:` (list of policy files read in compliance order), and all 13 AC item texts verbatim from `spec.md`.

- [x] [P0-T2] Record the current state of `extensions/drm-copilot/resources/customizations/.github/agents/feature-review.agent.md`: capture the line count and confirm the file does NOT contain the string "Coverage Verification". Record under a `Baseline: bundled-mirror` section in `phase0-instructions-read.md`.
  - Acceptance: `phase0-instructions-read.md` contains a `Baseline: bundled-mirror` section that states the line count (expected: 41) and explicitly records the absence of the string "Coverage Verification" in the file.

- [x] [P0-T3] Record the current state of `.claude/rules/self-explanatory-code-commenting.md`: confirm the file does NOT contain a prohibition on numbered notes (`NOTE 1:`, `NOTE 2:`). Record under a `Baseline: self-explanatory-commenting` section in `phase0-instructions-read.md`.
  - Acceptance: `phase0-instructions-read.md` contains a `Baseline: self-explanatory-commenting` section that explicitly records the absence of a numbered-notes prohibition in `.claude/rules/self-explanatory-code-commenting.md`.

---

### Phase 1 — Implementation

- [x] [P1-T1] Overwrite `extensions/drm-copilot/resources/customizations/.github/agents/feature-review.agent.md` with the complete, current content of `.github/agents/feature-review.agent.md`.
  - Acceptance: `git diff extensions/drm-copilot/resources/customizations/.github/agents/feature-review.agent.md .github/agents/feature-review.agent.md` exits with code 0 and produces zero output (the two files are byte-identical).

- [x] [P1-T2] Add the numbered-notes prohibition to `.claude/rules/self-explanatory-code-commenting.md`. The addition must state that numbered notes (`NOTE 1:`, `NOTE 2:`) are prohibited and that `TODO:`, `WARNING:`, `PERF:`, or `SECURITY:` tags must be used instead. Content must match the "6. Do not number notes" section in `.github/instructions/self-explanatory-code-commenting.instructions.md`.
  - Acceptance: `grep -i "numbered" .claude/rules/self-explanatory-code-commenting.md` returns at least one match, and the file contains both `NOTE 1:` and `TODO:` in the prohibition text.

---

### Phase 2 — Final QC and Verification

- [x] [P2-T1] Verify all 13 AC items from `spec.md` are satisfied. For AC-1 through AC-12, grep each target file for the required content and confirm presence. For AC-13, confirm `extensions/drm-copilot/resources/customizations/.github/agents/feature-review.agent.md` and `.github/agents/feature-review.agent.md` are byte-identical using `git diff`. Record all 13 verification results in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/phase2-ac-verification.md`.
  - Acceptance: `phase2-ac-verification.md` exists and contains one result line per AC item (AC-1 through AC-13), all marked PASS. The AC-13 result includes the `git diff` command and confirms zero output.

- [x] [P2-T2] Update `spec.md` status field from "In Progress" to "Delivered" after all 13 AC items are confirmed PASS in `phase2-ac-verification.md`.
  - Acceptance: `grep "Status" docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/spec.md` returns a line containing `Delivered`.

- [x] [P2-T3] Update the plan checklist in `plan.2026-04-17T16-13.md` to mark all completed tasks as `[x]`. Confirm no unchecked task boxes remain before reporting completion.
  - Acceptance: `grep "\- \[ \]" docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/plan.2026-04-17T16-13.md` returns zero results.

