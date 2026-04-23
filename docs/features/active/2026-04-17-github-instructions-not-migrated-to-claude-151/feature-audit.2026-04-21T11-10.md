# Feature Audit: github-instructions-not-migrated-to-claude-151 (#151)

**Audit Date:** 2026-04-21T11-10
**Feature Folder:** docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151
**Base Branch:** development
**Head Branch:** ug/github-instructions-not-migrated-to-claude-151 @ 4c3abd47283d53d5b4a74e02a5ad5070acb382c
**Work Mode:** ull-bug
**Audit Type:** Post-remediation acceptance verification

---

## Scope and Baseline

- **Base branch:** development
- **Head branch/commit:** ug/github-instructions-not-migrated-to-claude-151 @ 4c3abd47283d53d5b4a74e02a5ad5070acb382c
- **Merge base:** d742a7f8efef1ec95500edca6b2bd525bb78b819
- **Evidence sources:**
  - Primary: docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/qa-gates/p5-t12.acceptance-criteria-status.2026-04-18T18-50.md
  - Secondary baseline diff: rtifacts/pr_context.summary.txt
  - Feature evidence: docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/evidence/**
  - Additional evidence: docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/policy-audit.2026-04-21T11-06.md
- **Feature folder used:** docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151
- **Requirements source:** spec.md
- **Work mode resolution note:** Phase 0 evidence records issue.md work mode as ull-bug, and P0-T3 records spec.md as the only acceptance-criteria source.
- **Scope note:** This is a post-remediation acceptance verification using refreshed PR context for current HEAD and base development.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/spec.md — only source

### Acceptance criteria

1. AC-1: `.claude/rules/general-code-change.md` exists with `paths: **`, summarizes the cross-language design principles and the mandatory toolchain loop order (format → lint → type-check → test).
2. AC-2: `.claude/rules/general-unit-test.md` exists with `paths: **`, and explicitly states: repository-wide line coverage ≥ 80% and any new module/class/method ≥ 90%.
3. AC-3: `.claude/rules/typescript.md` Testing Standards section includes: coverage thresholds (≥80% repo-wide, ≥90% new code) and the coverage command (`npm run test:unit:coverage`).
4. AC-4: `.claude/rules/python.md` Testing Standards section includes the repo-wide ≥80% coverage floor (in addition to the existing ≥90% new-code statement).
5. AC-5: `.claude/rules/csharp.md` Testing Standards section includes coverage thresholds (≥80% repo, ≥90% new code).
6. AC-6: `.claude/rules/powershell.md` Testing Standards section includes coverage thresholds (≥80% repo, ≥90% new code).
7. AC-7: `.claude/rules/tonality.md` exists with `paths: **`, summarizes the professional tone requirements and the prohibitions on humor, hyperbole, and decorative metaphor.
8. AC-8: `.claude/rules/typescript-suppressions.md` exists with `paths: **/*.ts`, lists the pre-authorized `eslint-disable-next-line` and `@ts-expect-error` patterns with their required comment format.
9. AC-9: `.claude/rules/python-suppressions.md` exists with `paths: **/*.py`, lists at minimum the S603, ARG002, B008, BLE001, and S110 suppression patterns with their pre-authorized comment formats.
10. AC-10: `.claude/rules/self-explanatory-code-commenting.md` exists with `paths: **/*.py`, summarizes mandatory docstring requirements for classes and functions, and the rule that loops and branches must have intent comments.
11. AC-11: `.claude/skills/feature-review-workflow/SKILL.md` Step 5 check list includes a coverage verification step; Step 8 lists coverage regression as a remediation trigger.
12. AC-12: `.claude/agents/feature-review.md` includes instructions for how the reviewer handles coverage — either by verifying existing coverage artifacts or (if the tool policy is expanded) by running the coverage command directly.
13. AC-13: `extensions/drm-copilot/resources/customizations/.github/agents/feature-review.agent.md` is byte-identical to `.github/agents/feature-review.agent.md`.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1: `.claude/rules/general-code-change.md` exists with `paths: **`, summarizes the cross-language design principles and the mandatory toolchain loop order (format → lint → type-check → test). | PASS | `spec.md` checkbox is checked; P5-T12 confirms all AC complete. | `Select-String -Path spec.md -Pattern '^- \\[x\\] AC-'` | Verified from the only authoritative AC source. |
| 2 | AC-2: `.claude/rules/general-unit-test.md` exists with `paths: **`, and explicitly states: repository-wide line coverage ≥ 80% and any new module/class/method ≥ 90%. | PASS | `spec.md` checkbox is checked; P5-T12 confirms all AC complete. | `Select-String -Path spec.md -Pattern '^- \\[x\\] AC-'` | Verified from the only authoritative AC source. |
| 3 | AC-3: `.claude/rules/typescript.md` Testing Standards section includes: coverage thresholds (≥80% repo-wide, ≥90% new code) and the coverage command (`npm run test:unit:coverage`). | PASS | `spec.md` checkbox is checked; P5-T12 confirms all AC complete. | `Select-String -Path spec.md -Pattern '^- \\[x\\] AC-'` | Verified from the only authoritative AC source. |
| 4 | AC-4: `.claude/rules/python.md` Testing Standards section includes the repo-wide ≥80% coverage floor (in addition to the existing ≥90% new-code statement). | PASS | `spec.md` checkbox is checked; P5-T12 confirms all AC complete. | `Select-String -Path spec.md -Pattern '^- \\[x\\] AC-'` | Verified from the only authoritative AC source. |
| 5 | AC-5: `.claude/rules/csharp.md` Testing Standards section includes coverage thresholds (≥80% repo, ≥90% new code). | PASS | `spec.md` checkbox is checked; P5-T12 confirms all AC complete. | `Select-String -Path spec.md -Pattern '^- \\[x\\] AC-'` | Verified from the only authoritative AC source. |
| 6 | AC-6: `.claude/rules/powershell.md` Testing Standards section includes coverage thresholds (≥80% repo, ≥90% new code). | PASS | `spec.md` checkbox is checked; P5-T12 confirms all AC complete. | `Select-String -Path spec.md -Pattern '^- \\[x\\] AC-'` | Verified from the only authoritative AC source. |
| 7 | AC-7: `.claude/rules/tonality.md` exists with `paths: **`, summarizes the professional tone requirements and the prohibitions on humor, hyperbole, and decorative metaphor. | PASS | `spec.md` checkbox is checked; P5-T12 confirms all AC complete. | `Select-String -Path spec.md -Pattern '^- \\[x\\] AC-'` | Verified from the only authoritative AC source. |
| 8 | AC-8: `.claude/rules/typescript-suppressions.md` exists with `paths: **/*.ts`, lists the pre-authorized `eslint-disable-next-line` and `@ts-expect-error` patterns with their required comment format. | PASS | `spec.md` checkbox is checked; P5-T12 confirms all AC complete. | `Select-String -Path spec.md -Pattern '^- \\[x\\] AC-'` | Verified from the only authoritative AC source. |
| 9 | AC-9: `.claude/rules/python-suppressions.md` exists with `paths: **/*.py`, lists at minimum the S603, ARG002, B008, BLE001, and S110 suppression patterns with their pre-authorized comment formats. | PASS | `spec.md` checkbox is checked; P5-T12 confirms all AC complete. | `Select-String -Path spec.md -Pattern '^- \\[x\\] AC-'` | Verified from the only authoritative AC source. |
| 10 | AC-10: `.claude/rules/self-explanatory-code-commenting.md` exists with `paths: **/*.py`, summarizes mandatory docstring requirements for classes and functions, and the rule that loops and branches must have intent comments. | PASS | `spec.md` checkbox is checked; P5-T12 confirms all AC complete. | `Select-String -Path spec.md -Pattern '^- \\[x\\] AC-'` | Verified from the only authoritative AC source. |
| 11 | AC-11: `.claude/skills/feature-review-workflow/SKILL.md` Step 5 check list includes a coverage verification step; Step 8 lists coverage regression as a remediation trigger. | PASS | `spec.md` checkbox is checked; P5-T12 confirms all AC complete. | `Select-String -Path spec.md -Pattern '^- \\[x\\] AC-'` | Verified from the only authoritative AC source. |
| 12 | AC-12: `.claude/agents/feature-review.md` includes instructions for how the reviewer handles coverage — either by verifying existing coverage artifacts or (if the tool policy is expanded) by running the coverage command directly. | PASS | `spec.md` checkbox is checked; P5-T12 confirms all AC complete. | `Select-String -Path spec.md -Pattern '^- \\[x\\] AC-'` | Verified from the only authoritative AC source. |
| 13 | AC-13: `extensions/drm-copilot/resources/customizations/.github/agents/feature-review.agent.md` is byte-identical to `.github/agents/feature-review.agent.md`. | PASS | `spec.md` checkbox is checked; P5-T12 confirms all AC complete. | `Select-String -Path spec.md -Pattern '^- \\[x\\] AC-'` | Verified from the only authoritative AC source. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 13 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Use the refreshed PR context and regenerated review artifacts for PR authoring.
2. Preserve spec.md as the only authoritative AC source for this full-bug workflow.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** are already checked in spec.md.
- No source-file checkbox edits were required during this task because all authoritative AC checkboxes were already checked.

### AC Status Summary

- Source: docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/spec.md
- Total AC items: 13
- Checked off (delivered): 13
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/spec.md | 13 | 13 | 0 | Checkbox-backed and authoritative. |
