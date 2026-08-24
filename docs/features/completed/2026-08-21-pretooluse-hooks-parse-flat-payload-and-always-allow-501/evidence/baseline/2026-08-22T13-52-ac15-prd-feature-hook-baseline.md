# Baseline — pre-fix state of enforce-prd-feature-before-planner.ps1 (AC-15) (#501)

Timestamp: 2026-08-22T13-52

## Context

AC-15 was added mid-remediation (see "Scope Expansion Recorded at Execution" in `spec.md`) to correct a
pre-existing, independent defect: `.claude/hooks/enforce-prd-feature-before-planner.ps1` hardcoded its
prerequisite file list to `spec.md` plus `user-story.md` regardless of the persisted `- Work Mode: ...`
marker, contradicting the mode-aware expectations in
`.claude/skills/feature-promotion-lifecycle/SKILL.md`. This artifact captures the pre-fix state, measured
by temporarily stashing the AC-15 changes (`git stash push`) and re-running the targeted toolchain against
the original committed file, then restoring the changes (`git stash pop`).

## Baseline source line (pre-fix)

`.claude/hooks/enforce-prd-feature-before-planner.ps1:141`:

```
$required = @('spec.md', 'user-story.md')
```

Unconditional for every work mode — this is the defect AC-15 corrects.

## Run 1 — PSScriptAnalyzer (targeted)

Command: `pwsh -NoProfile -File extensions/drm-copilot/resources/templates/run-poshqc-analyze.ps1 -WorkspaceRoot . -ScanFoldersJson '[".claude/hooks","tests/scripts/claude-hooks"]'`

EXIT_CODE: 0

Output Summary: `PSScriptAnalyzer passed: no findings under .` — 0 findings, pre-fix.

## Run 2 — Pester (targeted)

Command: `pwsh -NoProfile -File extensions/drm-copilot/resources/templates/run-poshqc-test.ps1 -WorkspaceRoot . -ScanFoldersJson '["tests/scripts/claude-hooks"]'`

EXIT_CODE: 0

Output Summary: `Tests Passed: 1010, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0`. Overall coverage line
`Covered 45.25% / 0%. 9,181 analyzed Commands in 79 Files.` (whole-suite figure, not per-file).

## Per-file coverage (pre-fix), `.claude/hooks/enforce-prd-feature-before-planner.ps1`

Source: `artifacts/pester/powershell-coverage.xml`, class-level `LINE` counter for this file.

- `<counter type="LINE" missed="9" covered="59" />` = **86.76%** over 68 measured lines.
- This figure matches the previously committed AC-11 qa-gate artifact
  (`evidence/qa-gates/2026-08-22T00-40-poshqc-test-final.md`, per-file table row for this file), confirming
  the re-measurement is consistent with the last recorded pre-AC-15 state.

## Behavioral baseline (pre-fix)

Pre-fix, the hook blocks every `atomic-planner` delegation targeting a `full-bug` or `minor-audit` feature
folder that correctly lacks `user-story.md` by design — including this feature's (#501) own `full-bug`
remediation cycle, once the `PreToolUse` hooks became live (the fix AC-1 through AC-14 deliver). No
work-mode-aware test coverage exists pre-fix; `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`
pre-fix asserts only the unconditional `spec.md` + `user-story.md` requirement.
