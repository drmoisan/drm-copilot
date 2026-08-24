# Phase 3 — PoshQC Loop (Remediation Cycle 1)

- **Issue:** #415
- **Task:** [P3-T2] (unconditional)
- **Finding:** R1

Timestamp: 2026-07-26T11-41

## Loop attempt 1 (failed at analyze — recorded, then restarted from format per C2)

1. `mcp__drm-copilot__run_poshqc_format` — EXIT_CODE: 0, no files changed.
2. `mcp__drm-copilot__run_poshqc_analyze` — **EXIT_CODE: 1**, `PSScriptAnalyzer reported 1 issue(s)`:
   - `PSReviewUnusedParameter` — `codex-batch-budget-hooks.Tests.ps1:251`, `$Path` declared but not used in the injected `WriteState` fake.

Root cause fixed without a suppression: the `WriteState` fake now captures and asserts the state-file path it is handed (`$script:WrittenStatePath`), which both uses the parameter and strengthens the case — it now verifies the hook composes the per-session state path `…/.codex/state/<lang>-batch-budget.fresh.json` rather than only that a write was attempted. No assertion was weakened.

## Loop attempt 2 (clean, uninterrupted pass)

Commands, in C2 order, `workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T16-53`:

1. Command: `mcp__drm-copilot__run_poshqc_format` — EXIT_CODE: 0 (`ok: true`); zero files changed.
2. Command: `mcp__drm-copilot__run_poshqc_analyze` — EXIT_CODE: 0 (`ok: true`); 0 errors, 0 warnings, 0 information.
3. Command: `mcp__drm-copilot__run_poshqc_test` — EXIT_CODE: 0 (`ok: true`); `artifacts/pester/pester-junit.xml` reports tests=**1659**, failures=**0**, errors=**0**, disabled=9.

All three stages passed in one uninterrupted pass.

## Supplementary CI-equivalent run (coverage measurement path, see Phase 1 deviation record)

4. Command: `pwsh -NoProfile -Command "Import-Module './scripts/powershell/PoshQC/PoshQC.psm1' -Force; Invoke-PoshQCTest -Root (Get-Location).Path"` — EXIT_CODE: 0.
   `Tests Passed: 1650, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0`; `Covered 93.57% / 0%. 4,246 analyzed Commands in 39 Files.`

## Output Summary

- Test counts: 1659 total (1650 executed + 9 skipped), 0 failures, 0 errors — up from 1525 at [P2-T3] (+134 new cases from batch 2).
- Repo-wide line coverage headline: covered = **2857**, missed = **185**, total instrumented = **3042**, **line coverage = 2857 / 3042 = 93.92%** (up from 81.30% at [P2-T3]; +384 newly covered lines).
- The repo-wide >= 85% gate is now met; it is formally verified at [P4-T3] and [P6-T3].
- Side-effect check: `Test-Path .codex/state` after the full run = **False**. The batch-budget entrypoint cases are deliberately restricted to payloads that cannot reach the state-writing path, and every filesystem seam in the unit cases is injected, so the suite creates no repository state.
- PowerShell branch coverage remains not separately measurable (no `BRANCH` counter in the JaCoCo output).
