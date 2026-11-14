# PowerShell Final-QC Static ([P2-T1], remediation cycle R1)

Timestamp: 2026-11-12T05-46
Command: sh SCRATCH/issue-1167-psstatic-dir.sh (pwsh 7 from the item worktree root: Invoke-Formatter drift check per .ps1 file under tests/scripts/claude-runtime with scripts/powershell/PoshQC/settings/pssa.settings.psd1; Invoke-ScriptAnalyzer -Path tests/scripts/claude-runtime -Recurse -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCLeakScan -Root <worktree root>)
EXIT_CODE: 0
Output Summary:
- Step 1 format check (no write): files=37, drift=0, exit 0, finding count 0. git status --porcelain unchanged across the step.
- Step 2 PSScriptAnalyzer: findings=0 (0 in tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1), exit 0. Phase 0 baseline: 0; no increase.
- Step 3 Invoke-PoshQCLeakScan: 742 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures; exit 0. Phase 0 baseline: 741 files, 0 failures (one more file now: none added in this cycle; the count includes the test file added by the main cycle after the baseline).
- Type check: not applicable for PowerShell.
