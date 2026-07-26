# Phase 2 — PoshQC Loop (Remediation Cycle 1)

- **Issue:** #415
- **Task:** [P2-T3]
- **Finding:** R1

Timestamp: 2026-07-26T11-41

## Loop attempt 1 (failed at analyze — recorded, then restarted from format per C2)

1. `mcp__drm-copilot__run_poshqc_format` — EXIT_CODE: 0, no files changed.
2. `mcp__drm-copilot__run_poshqc_analyze` — **EXIT_CODE: 1**, `PSScriptAnalyzer reported 7 issue(s)`:
   - `PSUseShouldProcessForStateChangingFunctions` — `codex-pretooluse-file-mapping.Tests.ps1:24`, helper named `New-CodexPayloadObject`.
   - `PSUseShouldProcessForStateChangingFunctions` — `codex-pretooluse-transport.Tests.ps1:277`, helper named `New-CompletionCheckpointJson`.
   - `PSReviewUnusedParameter` ×5 — `codex-pretooluse-transport.Tests.ps1:366, 373, 380, 387, 431`, `$Path` declared but not used in the injected `CheckpointReader` scriptblock stubs.

Root causes fixed; no analyzer suppression was added:

- Both helpers were renamed to the non-state-changing approved verb `ConvertTo-`: `ConvertTo-CodexPayloadObject` and `ConvertTo-CompletionCheckpointJson`. The helpers build objects and JSON text; they change no system state, so the rename removes the finding rather than masking it.
- Each `CheckpointReader` stub now uses its `$Path` parameter (`{ param($Path) if ($Path) { ... } }`), preserving signature parity with the production seam `& $CheckpointReader 'artifacts/orchestration/orchestrator-state.json'` while making the parameter genuinely referenced.

## Loop attempt 2 (clean, uninterrupted pass)

Commands, in C2 order, `workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T16-53`:

1. Command: `mcp__drm-copilot__run_poshqc_format` — EXIT_CODE: 0 (`ok: true`); zero files changed.
2. Command: `mcp__drm-copilot__run_poshqc_analyze` — EXIT_CODE: 0 (`ok: true`); 0 errors, 0 warnings, 0 information.
3. Command: `mcp__drm-copilot__run_poshqc_test` — EXIT_CODE: 0 (`ok: true`); `artifacts/pester/pester-junit.xml` reports tests=**1525**, failures=**0**, errors=**0**, disabled=9.

All three stages passed in one uninterrupted pass.

## Supplementary CI-equivalent run (coverage measurement path, see Phase 1 deviation record)

4. Command: `pwsh -NoProfile -Command "Import-Module './scripts/powershell/PoshQC/PoshQC.psm1' -Force; Invoke-PoshQCTest -Root (Get-Location).Path"` — EXIT_CODE: 0.
   `Tests Passed: 1516, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0`; `Covered 78.71% / 0%. 4,246 analyzed Commands in 39 Files.`

## Output Summary

- Test counts: 1525 total (1516 executed + 9 skipped), 0 failures, 0 errors — up from 1429 at [P1-T2] (+96 new cases from this batch).
- Repo-wide line coverage headline: covered = **2473**, missed = **569**, total instrumented = **3042**, **line coverage = 2473 / 3042 = 81.30%** (up from 76.73% at [P1-T2]; +139 newly covered lines).
- Still below the 85% repo-wide gate, which binds at [P4-T3] and [P6-T3]; the six remaining sub-threshold hooks are the Phase 3 batch-2 scope.
- PowerShell branch coverage remains not separately measurable (no `BRANCH` counter in the JaCoCo output).
