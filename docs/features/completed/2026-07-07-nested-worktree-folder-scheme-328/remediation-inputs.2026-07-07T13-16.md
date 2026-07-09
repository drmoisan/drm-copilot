# Remediation Inputs: nested-worktree-folder-scheme (Issue #328)

- Timestamp: 2026-07-07T13-16
- Cycle: 1 (initial review findings)
- Base: `main` @ merge-base `3eda262ffbc3ab82e6eefed3e9a72ab4133b893c`
- Head: `drm-copilot-wt-2026-07-07-11-50` @ `f4bbfdf7c804f094ed11e42b56aed73444629f7d`
- Produced by: feature-review agent
- Handoff: route to `atomic-planner` per `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` (the remediation plan is authored by `atomic-planner`, preflighted and executed by `atomic-executor`, then re-audited by `feature-review`)

## Source Audit Artifacts

- `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/policy-audit.2026-07-07T13-16.md` — Section 8 (Identified Gaps 1 and 2), Section 1.2.1 (PowerShell disposition FAIL), Section 10 (verdict PARTIALLY COMPLIANT / Needs revision)
- `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/code-review.2026-07-07T13-16.md` — Findings Table (two Major coverage-verification findings)
- `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/feature-audit.2026-07-07T13-16.md` — AC9 PARTIAL and the AC9 pre-checked/PARTIAL discrepancy note
- Supporting evidence: `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/evidence/qa-gates/2026-07-07T13-16-review-targeted-ps-coverage.md`

## Remediation-Required Findings (enumerated fix list)

### R1 — Make the changed PowerShell production file's line coverage measurable and record a valid >= 85% figure (Blocking)

- **Files:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (add `scripts/dev-tools/new-claude-worktree-session.ps1` to `CodeCoverage.Path`); `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1` (adjust the function-import approach so executed commands attribute to the original file lines — the current `Import-ScriptFunction` AST re-parse restarts line numbers at 1 and defeats Pester breakpoint attribution).
- **Expected behavior:** A committed or evidence-recorded Pester JaCoCo report contains `scripts/dev-tools/new-claude-worktree-session.ps1` in its denominator with line coverage >= 85%, with the Pester suite still green and the repo mocking/import rules in `.claude/rules/powershell.md` still satisfied.
- **Acceptable alternative (repo precedent):** If coverage-valid attribution is structurally impossible without violating the repo test-import rules, produce a sanctioned tooling-limitation exception dossier under `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/evidence/regression-testing/` (schema per `evidence-and-timestamp-conventions`: `WhyFailingRunImpossible`/alternative-proof section) containing a complete per-function and per-command enumeration proving the >= 85% intent, following the precedent in `docs/features/completed/2026-06-16-bump-and-publish-task-191/policy-audit.2026-06-17T01-05.md`.
- **Verification commands:**
  - `pwsh -NoProfile -Command "$cfg = New-PesterConfiguration; $cfg.Run.Path = 'tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1'; $cfg.CodeCoverage.Enabled = $true; $cfg.CodeCoverage.Path = 'scripts/dev-tools/new-claude-worktree-session.ps1'; $cfg.CodeCoverage.OutputFormat = 'JaCoCo'; $cfg.CodeCoverage.OutputPath = '<evidence path>'; Invoke-Pester -Configuration $cfg"` → reported line coverage >= 85%
  - `mcp__drm-copilot__run_poshqc_test` (full suite) → exit 0, no regressions

### R2 — PowerShell branch coverage: emit or formally except (Blocking, may be bundled with R1)

- **Files:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (coverage output configuration) or an exception dossier as in R1's alternative.
- **Expected behavior:** Either the PowerShell coverage artifact emits a branch metric demonstrating >= 75% for the changed file, or a sanctioned exception dossier with a complete per-branch enumeration for the changed/new functions (`Get-WorktreeGroupDirectory`, `New-WorktreeParentDirectory`, updated `Build-WorktreePath`/`Get-WorktreeTimestamp`) discharges the branch-threshold intent.
- **Verification command:** parse the resulting artifact for a `BRANCH` counter (or validate the dossier's enumeration covers every conditional in the changed functions).

### R3 — Reconcile AC9 source-file state after R1/R2 (Non-blocking, bookkeeping)

- **Files:** `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/spec.md`, `user-story.md` (AC9 checkbox).
- **Expected behavior:** After R1/R2 verification passes, AC9's `[x]` state is consistent with a PASS evaluation in the re-audit. No text changes to the criterion.
- **Verification command:** re-audit by `feature-review` evaluates AC9 PASS.

## Do-Not-Do List

- Do not lower, remove, or reinterpret any coverage threshold (line >= 85%, branch >= 75% are uniform across tiers; no tier-specific floors).
- Do not exclude any production file from coverage measurement; do not add `exclude` entries matching production paths.
- Do not weaken, delete, or skip existing tests to influence coverage numbers.
- Do not modify production behavior in `scripts/dev-tools/new-claude-worktree-session.ps1`, the bundled template, or any TypeScript production file — the code itself passed review; this cycle is measurement/evidence only. If the test-import approach changes require touching the script (e.g., adding a dot-source guard), keep script/template lockstep parity and re-verify with `git diff --no-index`.
- Do not mock `git` or other executables directly; respect the wrapper/scriptblock seam rules in `.claude/rules/powershell.md`.
- Do not write evidence outside `docs/features/active/2026-07-07-nested-worktree-folder-scheme-328/evidence/<kind>/`.
- Do not modify policy documents under `.claude/rules/` or `.github/instructions/`.

## Exit Condition for This Cycle

Re-audit by `feature-review` shows: policy-audit PowerShell coverage disposition PASS (valid numeric line figure >= 85% for the changed file, and branch figure >= 75% or a sanctioned exception dossier), AC9 PASS, and zero remaining Blocking findings.
