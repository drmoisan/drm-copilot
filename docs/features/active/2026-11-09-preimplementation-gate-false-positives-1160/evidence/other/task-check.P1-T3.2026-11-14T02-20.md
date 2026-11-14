# Task Check [P1-T3] (cycle 4, expect-fail)

Timestamp: 2026-11-14T02-20
Command: sh SCRATCH/issue-1160-r4-tc.sh (Invoke-Formatter comparison and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over the commands suite; Invoke-Pester through New-PesterConfiguration with Run.Path set to the commands suite); git diff --numstat <remediation start ref> -- the commands suite
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: changed file `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1` (380 lines; formatter difference 0, analyzer findings 0). Selection rule: the changed test file itself (mirrored suite of the commands sibling). Result: 119 tests, 115 passed, 4 failed. The 4 failures are exactly `confirms a host subcommand word that is a global option value (decision D19)` and `confirms a global option before a host subcommand (decision D19)` on the Claude and Codex surfaces; `clears a host subcommand directly after the command word (decision D19)` and `clears a host subcommand directly after a transparent wrapper (decision D19)` pass on both. Anchored diff against the remediation start ref: 19 added, 0 removed lines.
