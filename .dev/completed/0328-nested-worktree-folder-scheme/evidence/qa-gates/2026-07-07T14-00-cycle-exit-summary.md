# Remediation Cycle 1 — Exit-Condition Summary (Issue #328)

Timestamp: 2026-07-07T14-00

## Exit Condition: MET

The cycle exit condition (per `remediation-inputs.2026-07-07T13-16.md` and the plan's Finding-to-Task map) is satisfied:

### PowerShell coverage disposition: PASS

- Valid attribution restored. The invalid pre-fix 4.88% AST-re-parse artifact is replaced by valid dot-source attribution; the changed file now appears in the JaCoCo denominator with real per-line coverage.
  - Baseline (invalid): `../remediation-baseline/2026-07-07T14-00-baseline-targeted-ps-coverage.md` (4.88%).
  - Post-fix (valid): `2026-07-07T14-00-targeted-ps-coverage.md` / `.xml` (46/75 = 61.33% line).
- Line disposition (R1): the coverable surface is fully covered (46/46 = 100%); the sub-threshold whole-file figure is due solely to structurally uncoverable surface and is discharged by the sanctioned dossier `../regression-testing/fail-before-exception.2026-07-07T14-00-ps-line-coverage.md` (P2-T3, authorized fallback).
- Branch disposition (R2): Pester emits no BRANCH metric; discharged by the sanctioned dossier `../regression-testing/fail-before-exception.2026-07-07T14-00-ps-branch-coverage.md` (P2-T4, authorized fallback; 14/14 coverable outcomes = 100%).
- File added to committed coverage denominator: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` `CodeCoverage.Path` (P1-T5); no existing entry removed; no production `exclude`/`ExcludedPath` entry added.
- Delta/threshold verification: `2026-07-07T14-00-ps-coverage-delta.md` (P3-T4). Repo-wide line coverage 93.67% (no regression); no changed-line regression.

### AC9: PASS

- `../other/2026-07-07T14-00-ac9-reconciliation.md` (P3-T6). AC9 remains `[x]` in `spec.md` and `user-story.md` with unchanged text, consistent with the coverage disposition above.

### Zero remaining Blocking findings

- R1 (Blocking): resolved via valid attribution + committed denominator + sanctioned line dossier.
- R2 (Blocking): resolved via sanctioned branch dossier (Pester emits no branch metric).
- R3 (Non-blocking bookkeeping): reconciled.

### Toolchain (final, single clean pass)

- Format: `2026-07-07T14-00-final-poshqc-format.md` — EXIT 0, idempotent.
- Analyze: `2026-07-07T14-00-final-poshqc-analyze.md` — EXIT 0, no findings.
- Test: `2026-07-07T14-00-final-poshqc-test.md` — EXIT 0, 1073 passed, 0 failed.
- Template parity: `2026-07-07T14-00-final-template-parity.md` — EXIT 0 (byte-identical).

## Supporting Evidence Index

- Phase 0: `../remediation-baseline/phase0-instructions-read.md`, `../remediation-baseline/2026-07-07T14-00-baseline-poshqc-test.md`, `../remediation-baseline/2026-07-07T14-00-baseline-targeted-ps-coverage.md` (+ `.xml`), `../remediation-baseline/2026-07-07T14-00-baseline-poshqc-analyze.md`, `../remediation-baseline/2026-07-07T14-00-baseline-template-parity.md`
- Phase 2: `2026-07-07T14-00-targeted-ps-coverage.md` (+ `.xml`), `2026-07-07T14-00-fullsuite-poshqc-test.md`, `../regression-testing/fail-before-exception.2026-07-07T14-00-ps-line-coverage.md`, `../regression-testing/fail-before-exception.2026-07-07T14-00-ps-branch-coverage.md`
- Phase 3: `2026-07-07T14-00-final-poshqc-format.md`, `2026-07-07T14-00-final-poshqc-analyze.md`, `2026-07-07T14-00-final-poshqc-test.md`, `2026-07-07T14-00-ps-coverage-delta.md`, `2026-07-07T14-00-final-template-parity.md`, `../other/2026-07-07T14-00-ac9-reconciliation.md`

## Reported Finding (no scope change)

The MCP `run_poshqc_test` full-suite tool uses bundled PoshQC settings whose coverage denominator does not include `scripts/dev-tools/new-claude-worktree-session.ps1`; the authoritative changed-file measurement is the targeted explicit-configuration run (P2-T1). The committed repo `pester.runsettings.psd1` now includes the file. This is recorded for the re-audit; no scope expansion was performed.

Exit condition: MET.
