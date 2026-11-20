# Final QC static - PowerShell (remediation cycle 1)

Timestamp: 2026-11-18T02-36
Command: sh SCRATCH/issue-1201-ps-static.sh <the 16 test files changed in cycle 1>; sh SCRATCH/issue-1201-leak-scan.sh
EXIT_CODE: 0
Output Summary: format 0 drift, PSScriptAnalyzer 0 findings, and leak scan 0 failures over 16 changed files; one file exceeds 500 lines (deviation below).

| Step | Command | EXIT_CODE | Finding count |
|---|---|---|---|
| 1. Format (check-only in-memory Invoke-Formatter compare with scripts/powershell/PoshQC/settings/pssa.settings.psd1; no file written) | sh SCRATCH/issue-1201-ps-static.sh <16 files> | 0 | 0 ("format_drift=0"; every file "format: unchanged") |
| 2. PSScriptAnalyzer (repository settings) | same script | 0 | 0 ("pssa_findings=0") |
| 3. Invoke-PoshQCLeakScan (branch-current PoshQC module, -Root the worktree) | sh SCRATCH/issue-1201-leak-scan.sh | 0 | 0 failures ("Leak scan: 865 files, 78 findings, 76 exempt, 2 allowlisted, 0 failures.") |
| Type checking | not applicable to PowerShell | - | - |

The formatter would change no file, so the loop needed no restart.

## Physical line counts

| File | Lines |
|---|---|
| tests/scripts/claude-hooks/hook-release-allowance-context.Tests.ps1 | 284 |
| tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | 539 |
| tests/scripts/claude-hooks/owner-directive-pass-down-target.Tests.ps1 | 265 |
| tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | 259 |
| tests/scripts/claude-hooks/validate-orchestrator-output-target.Tests.ps1 | 314 |
| tests/scripts/claude-hooks/validate-orchestrator-output.FeatureFolder.Tests.ps1 | 197 |
| tests/scripts/claude-hooks/validate-orchestrator-output.MutationRejection.Tests.ps1 | 421 |
| tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1 | 368 |
| tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectives.Tests.ps1 | 216 |
| tests/scripts/claude-hooks/validate-orchestrator-output.Reentry.Tests.ps1 | 215 |
| tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 | 459 |
| tests/scripts/claude-hooks/validate-orchestrator-output.WaveBarrier.Tests.ps1 | 255 |
| tests/scripts/claude-hooks/validate-orchestrator-output.WorktreeResolution.Tests.ps1 | 379 |
| tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 | 335 |
| tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 | 143 |
| tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 | 166 |

## Deviation (non-blocking)

- tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 was already 536 lines before cycle 1. The diagnosis names it as a leaker, so the both-sides rule required its 3-line teardown. It is now 539 lines, which is above the 500-line guidance tier (no gate fails) and below the 700-line advisory and 800-line hard limits. The P2-T3 condition "each changed file is below 500 lines" was written for the victim file only and does not hold for this leaker. The other 15 files are below 500 lines.
