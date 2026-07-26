# Final PoshQC Test + Coverage Gate (Remediation Cycle 1)

- **Issue:** #415
- **Task:** [P6-T3]
- **Finding:** R1

Timestamp: 2026-07-26T11-41

## Commands

1. Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T16-53`

   EXIT_CODE: 0

   ```json
   {"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-07-25T16-53","summary":"Ran bundled PoshQC test against 'C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-07-25T16-53'."}
   ```

   `artifacts/pester/pester-junit.xml`: tests=**1668**, failures=**0**, errors=**0**, disabled=9.

2. Command (CI-equivalent coverage measurement path, per the Phase 1 deviation record):
   `pwsh -NoProfile -Command "Import-Module './scripts/powershell/PoshQC/PoshQC.psm1' -Force; Invoke-PoshQCTest -Root (Get-Location).Path"`

   EXIT_CODE: 0

   `Tests Passed: 1659, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0`
   `Covered 94.02% / 0%. 4,246 analyzed Commands in 39 Files.`

Both ran in the same single uninterrupted pass as [P6-T1] (format, 0 files changed) and [P6-T2] (analyze, 0 findings). No restart was required.

## Output Summary

### Post-remediation repo-wide line coverage (NUMERIC)

- covered = **2869**
- missed = **173**
- total instrumented = **3042**
- **repo-wide line coverage = 2869 / 3042 = 94.31%**
- **>= 85% verdict: PASS**

### Per-file confirmation — all 8 C5 paths present under the `.codex/hooks` package

C4 package-qualified extraction from `artifacts/pester/powershell-coverage.xml`, package
`C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T16-53/.codex/hooks`:

| C5 path | Present in coverage XML? | Covered | Missed | Total | Percent |
|---|---|---:|---:|---:|---:|
| `.codex/hooks/codex-pretooluse-file-mapping.ps1` | YES | 101 | 0 | 101 | 100.00% |
| `.codex/hooks/check-python-test-purity.ps1` | YES | 67 | 0 | 67 | 100.00% |
| `.codex/hooks/check-powershell-test-purity.ps1` | YES | 62 | 0 | 62 | 100.00% |
| `.codex/hooks/enforce-python-batch-budget.ps1` | YES | 84 | 3 | 87 | 96.55% |
| `.codex/hooks/enforce-powershell-batch-budget.ps1` | YES | 84 | 3 | 87 | 96.55% |
| `.codex/hooks/enforce-evidence-locations.ps1` | YES | 41 | 0 | 41 | 100.00% |
| `.codex/hooks/enforce-checkpoint-monotonic.ps1` | YES | 103 | 1 | 104 | 99.04% |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | YES | 98 | 0 | 98 | 100.00% |

All 8 are present, which is the direct measured resolution of finding R1: the changed production surface is now inside the coverage denominator. The two previously measured `.codex/hooks` files are also present: `enforce-completion-consistency.ps1` at 136/136 = 100.00% (a C7 verdict-set file) and `enforce-completion-helpers.ps1` at 33/43 = 76.74% (pre-existing, unchanged on this branch, outside the verdict set).

The `.codex/hooks` package now contains 10 sourcefiles; at the [P0-T5] baseline it contained 2.

### Suite health in the same pass

- All suites green, including the root/bundle parity suites that re-verify hook byte-identity between `.codex/hooks/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`, and `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`, which asserts exact text parity between the two `pester.runsettings.psd1` copies edited at [P1-T1].
- Independent parity re-verification: `git diff --no-index scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` exits **0**.
- Independent hook-immutability re-verification: `git diff fef82fa2 --name-only -- .codex/` returns **0 paths** — no `.codex/hooks/*.ps1` production file and no `.codex/config.toml` changed during this remediation.
- Side-effect check: `Test-Path .codex/state` after the full run = **False**.

### Branch-coverage toolchain limitation

PowerShell branch coverage is not separately measurable in this toolchain (`spec.md:248`). The JaCoCo XML emitted by the PoshQC Pester run carries report-level counters of type `INSTRUCTION` (missed 254 / covered 3992), `LINE`, `METHOD` (missed 25 / covered 221), and `CLASS` (missed 2 / covered 37) only; there is no `BRANCH` counter and every `line` element's `mb`/`cb` attributes are 0. The >= 75% branch threshold is therefore evaluated for Python only in this remediation (see `python-coverage.2026-07-26T11-41.md`), and the PowerShell branch figure is unavailable by tooling limitation rather than by omission.
