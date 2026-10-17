# Fail-before exception dossier: RI-1 and RI-2 (remediation cycle 1, P5-T6)

Timestamp: 2026-10-13T15-54

## RI-1 (P2-T1, U26 rows in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1`)

WhyFailingRunImpossible: The U26 rows add tests over unchanged, already-correct production code (`Get-OrchestrationEpicTargetDenyReason` in both surface copies), so the new assertions pass on first run and no failing test run exists.

Alternative proof:
- Before: Codex targets `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` lines 356 and 370 have `ci` 0 in `evidence/remediation-baseline/ps-coverage-rem-baseline.2026-10-13T15-16.md` (CI run 38410234897).
- After: lines 356 and 370 have `ci` 1 in `evidence/qa-gates/rem1-ri-lines.2026-10-13T15-54.md` (CI run 38423196404), and the U26 rows pass on both surfaces (Windows 4/0/0, Linux 4/0/0) in `evidence/qa-gates/rem1-ps-rows.2026-10-13T15-54.md`.

## RI-2 (P3-T1, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1`)

WhyFailingRunImpossible: The ES-D rows add tests over unchanged, already-correct production code (`Get-OrchestrationEpicScopeDecision` in the Codex copy), so the new assertions pass on first run and no failing test run exists.

Alternative proof:
- Before: Codex epic-scope `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` lines 206 and 207 have `ci` 0 in `evidence/remediation-baseline/ps-coverage-rem-baseline.2026-10-13T15-16.md`.
- After: lines 206 and 207 still have `ci` 0 in `evidence/qa-gates/rem1-ri-lines.2026-10-13T15-54.md` (attribution anomaly; see `evidence/qa-gates/rem1-ri2-exemption.2026-10-13T15-54.md`), while ES-D1 (deny) and ES-D2 (allow) pass on Windows 1/0/0 and Linux 1/0/0 in `evidence/qa-gates/rem1-ps-rows.2026-10-13T15-54.md`.
