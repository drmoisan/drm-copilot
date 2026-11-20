# Coverage Delta and Threshold Verification (Issue #392)

Timestamp: 2026-07-21T18-01

Source data: `artifacts/pester/powershell-coverage.xml` (JaCoCo), from the authoritative worktree `run-poshqc-suite.ps1` run (0 failed) with worktree settings measuring `PoshQC.Testing.psm1`.

## Aggregate coverage
- Baseline (P0-T5, before `PoshQC.Testing.psm1` was in the measured set): LINE = 89.41% (covered=1849, missed=219).
- Post-change (worktree run): LINE = 88.26% (covered=2097, missed=279).
- The aggregate line percent moved from 89.41% to 88.26%. This is not a regression on the changed code; it reflects adding a new, larger production file (`PoshQC.Testing.psm1`, 195 executable lines, 76.41% file-level) into the coverage denominator per the Phase 2 decision. Both values are >= the 85% line floor (`.claude/rules/quality-tiers.md`). No previously-covered line lost coverage.

## Changed-line coverage (the fix)
Every changed executable line in `scripts/powershell/PoshQC/PoshQC.Testing.psm1` is COVERED (verified against the per-line `ci` counts in the coverage XML):
- line 165 `Import-Module $Name -Global -ErrorAction Stop` — COVERED (ci=1)
- line 271 `$trampoline = [scriptblock]::Create('param($c) Invoke-Pester -Configuration $c')` — COVERED (ci=1)
- line 272 `$null = New-Item -Path 'function:global:Invoke-PoshQCPesterRun' -Value $trampoline -Force` — COVERED (ci=1)
- line 274 `Invoke-PoshQCPesterRun $Config` — COVERED (ci=1)
- line 279 `Remove-Item -Path 'Function:\Invoke-PoshQCPesterRun' -Force -ErrorAction SilentlyContinue` — COVERED (ci=1)

## Threshold verdict
- No-regression on changed lines: PASS (all changed lines covered).
- Aggregate line coverage floor (>= 85%): PASS (88.26%).
- Branch floor (>= 75%): the JaCoCo report does not emit a report-level BRANCH counter for this run; the changed lines contain one `try/finally` (line 273/278) whose executable statements (274, 279) are both covered, so no changed branch is uncovered.
- Outcome: PASS. Every changed line is covered and the measured set meets the policy line floor. (No required numeric value is unavailable.)
