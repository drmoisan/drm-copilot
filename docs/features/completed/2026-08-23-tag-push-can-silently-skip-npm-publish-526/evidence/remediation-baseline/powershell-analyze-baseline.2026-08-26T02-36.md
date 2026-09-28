# PSScriptAnalyzer Baseline (Remediation Cycle 2026-08-26T02-36)

Timestamp: 2026-08-26T03-19

Stamp substitution: the plan fixes the evidence filename stamp at `2026-08-26T02-36`; the `Timestamp:`
field records the actual execution stamp.

Command: `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path'`

EXIT_CODE: 0

Output Summary: PSScriptAnalyzer reported no findings. Final line of output:
`PSScriptAnalyzer passed: no findings under <worktree root>`. Finding count is 0.

One transient engine diagnostic was emitted and self-recovered: a `NullReferenceException` on
`.claude/lib/blast-radius/BlastRadius.psm1`, retried automatically at attempt 1 of 5 and succeeded
(PSScriptAnalyzer 1.25.0, PowerShell 7.6.5). It is a known transient of the analyzer engine, not a
finding, and it did not affect the exit code.
