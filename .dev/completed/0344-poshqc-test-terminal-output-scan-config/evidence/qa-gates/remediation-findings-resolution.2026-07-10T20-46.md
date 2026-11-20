# Findings Resolution and AC16 Re-Evaluation (Remediation Cycle 1)

- Issue: #344
- Timestamp: 2026-07-10T20-46
- Cycle: 1 (R1, R2, R3)

## R1 — Stale TypeScript coverage artifact at HEAD

- Finding: `extensions/drm-copilot/coverage/lcov.info` was stale — it contained no records for the three new modules and its totals equaled the baseline (31877/32985 lines; 4056/4577 branches).
- Resolving tasks: P0-T3 (fail-before), P2-T4 (regenerate via `npm run test:coverage`), P2-T5 (machine-readable verification), P2-T13 (comparison refresh).
- Machine-readable artifact: `extensions/drm-copilot/coverage/lcov.info` (regenerated) + `evidence/qa-gates/remediation-ts-lcov-verification.2026-07-10T20-46.md`.
- Numeric evidence: repo-wide 32547/33631 lines = 96.77% (denominator grew from 32985), 4149/4673 branches = 88.78% (grew from 4577). All four in-scope modules present: poshqc-scan-config.ts 96.49% line / 88.57% branch; poshqc-terminal-output.ts 99.29% / 100%; poshqc-folder-picker.ts 100% / 100%; poshqc-command-registration.ts 94.27% / 85.71%. No regression (both repo-wide metrics increased).
- Status: **RESOLVED**.

## R2 — PoshQC.ScanConfig.psm1 outside the Pester coverage denominator

- Finding: `PoshQC.psm1` loaded sub-modules via fileless `[scriptblock]::Create((Get-Content ... -Raw))`, so Pester breakpoints never bound and `PoshQC.ScanConfig.psm1` was outside the coverage denominator.
- Resolving tasks: P0-T2 (fail-before), P1-T1 (AST `[Parser]::ParseFile(...).GetScriptBlock()` dot-sourcing refactor), P1-T2 (add to `CodeCoverage.Path`), P1-T3 (bundled mirror resync), P1-T4 (instrumentation verification), P1-T5 (parity gate), P2-T6/T7/T8 (final PS toolchain), P2-T13 (comparison refresh).
- Machine-readable artifact: `artifacts/pester/powershell-coverage.xml` (now lists `PoshQC.ScanConfig.psm1` as a sourcefile) + `evidence/qa-gates/remediation-ps-scanconfig-coverage.2026-07-10T20-46.md` and `evidence/qa-gates/remediation-ps-test-coverage.2026-07-10T20-46.md`.
- Numeric evidence: `PoshQC.ScanConfig.psm1` line coverage 44/46 = **95.65%** (>= 85%). Branch: not emitted by Pester CoverageGutters (line-based; authorized limitation note). 1103-test authoritative gate: 1094 passed, 0 failed, 9 skipped — no regression. Eight-pair parity gate: PASS.
- R2 contingency check: the AST refactor makes breakpoints bind (proven by controlled Pester run: CommandsAnalyzed=53, CommandsExecuted=49; full-suite line coverage 95.65%). The contingency (breakpoints still fail to bind) did NOT trigger. No human coverage exception was taken.
- Status: **RESOLVED**.

## R3 — Absent Python coverage artifact

- Finding: `artifacts/python/lcov.info` was absent although `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` changed on the branch.
- Resolving tasks: P0-T4 (fail-before), P2-T9..P2-T12 (Python toolchain + coverage generation), P2-T13 (comparison refresh).
- Machine-readable artifact: `artifacts/python/lcov.info` (now present) + `evidence/qa-gates/remediation-py-coverage.2026-07-10T20-46.md`.
- Numeric evidence: 1309 tests passed (including the eight-pair parity test); repo-wide line coverage 8073/9320 = **86.62%** (>= 85%). Branch: not emitted by the coverage command configuration. Test-only change: no Python production code changed, so changed-line regression is structurally impossible.
- Status: **RESOLVED**.

## AC16 Re-Evaluation

AC16 (Cross-cutting) coverage clause: "line coverage >= 85% and branch coverage >= 75% for the changed code, and coverage evidence (baseline, post-change, comparison) is recorded under the feature `evidence/` tree."

- TypeScript changed code: all four modules >= 85% line and >= 75% branch (measured, P2-T5).
- PowerShell changed code: `PoshQC.ScanConfig.psm1` 95.65% line (measured, P2-T8); branch not emitted (line-based tool, authorized limitation note).
- Python: no production code changed; repo-wide line 86.62% (>= 85%); branch not emitted (tool configuration).
- Coverage evidence recorded under `evidence/` tree: baseline (`evidence/baseline/`), post-change (`evidence/qa-gates/remediation-*`), and comparison (`evidence/qa-gates/coverage-comparison.md`, remediation-cycle-1 section).

Conclusion: the AC16 coverage clause now evaluates **PASS**, referencing P2-T5, P2-T8, P2-T12, and P2-T13 evidence. AC16 is already marked `[x]` in both `spec.md` (line 347) and `user-story.md` (line 139); those marks are now accurate and no source-file edit is required. Confirmation recorded here.

## Out-of-Cycle Findings

1. `Get-PoshQCScanConfigFolder` is named in `PoshQC.psm1` `Export-ModuleMember -Function` (line ~101) but does not appear in `Get-Command -Module PoshQC` output (which lists 9 commands: the other eight functions plus the `Install-PoshQCTools` alias). This behavior is identical before and after the R2 refactor (verified via `git stash` comparison against the pre-change file), so it is pre-existing and NOT introduced by this cycle. The `Get-PoshQCScanConfigFolder` function is defined and callable — the 12 `PoshQC.ScanConfig.Tests.ps1` It blocks exercise it successfully. This is recorded as an observation for a follow-up issue and was not fixed in this cycle per the scope constraints. It does not affect any R1/R2/R3 resolution.

No other genuinely new defect was surfaced during remediation.
