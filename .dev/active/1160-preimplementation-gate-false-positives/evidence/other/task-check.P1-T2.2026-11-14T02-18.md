# Task Check [P1-T2] (cycle 4, expect-fail)

Timestamp: 2026-11-14T02-18
Command: sh SCRATCH/issue-1160-r4-tc.sh (Invoke-Formatter comparison and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over the Cases file; Invoke-Pester through New-PesterConfiguration with Run.Path set to the two classification runners)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: changed file `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1` (235 lines; formatter difference 0, analyzer findings 0). Selection rule: every test file that dot-sources the changed file, namely `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-classification.Tests.ps1`. Result: 568 tests, 488 passed, 80 failed. The 80 failures are exactly `classifies existing-denial row ED-97` to `ED-116` and `denies existing-denial row ED-97` to `ED-116 with the generic deny text` in the Claude and Codex runners (2 tests per row per runner); ED-117 to ED-120 pass. The file defines 120 existing-denial rows with 120 unique identifiers.
