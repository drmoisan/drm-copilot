# Task Check — [P1-T3] [expect-fail]

Timestamp: 2026-11-13T18-38
Command: sh SCRATCH/issue-1160-r4-tc.sh (pwsh 7: Invoke-Formatter comparison and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over the changed file; Invoke-Pester through New-PesterConfiguration with Run.Path set to the commands suite)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: static 0 formatter differences, 0 analyzer findings (361 lines); Pester passed 77, failed 34, total 111. The 34 failures are exactly the two updated pins and the fifteen new confirm cases on each surface (17 x 2); the five guard cases pass on both surfaces, and every pre-existing case passes.

- Changed file: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1`.
- Selection rule: the changed test file itself (it is the mirrored test of the commands sibling).

Failing on each surface (Claude copy and Codex copy):

- `mention-host table (spec AC-5)`: `returns exactly the decision D2 groups`; `returns exactly the decision D2 executing-option exclusions`.
- `pipeline consumers confirm the hit (decision D16)`: `confirms probe ED-43, a ForEach-Object consumer of Get-ChildItem tests/scripts/`; `confirms probe ED-44, a ForEach-Object consumer of a filtered Get-ChildItem`; `confirms probe ED-45, a % consumer`; `confirms probe ED-46, a ForEach-Object consumer of Get-Command pytest`; `confirms probe ED-47, a ForEach-Object consumer calling the Source property`; `confirms probe ED-48, a ForEach-Object consumer of Get-Command Invoke-Pester`; `confirms probe ED-49, an xargs env consumer of echo`; `confirms sort with --compress-program`; `confirms a non-host stage after an intervening host stage`; `reads NotHost before the host groups`; `confirms a PowerShell expression consumer containing ::`; `confirms a PowerShell expression consumer containing .Invoke`; `skips nested payload records when following the pipeline`; `reads NotHost before the host groups in the consumer check`; `confirms a consumer with an executing option`.

Passing on each surface (`pipeline guards keep a mention unclassified (decision D16)`): `clears a pipeline whose later stages are all hosts`; `does not treat a record after ; as a consumer`; `does not treat records nested in a wrapper payload as consumers of the wrapper`; `stops a PowerShell consumer search at the end of its payload`; `accepts a PowerShell expression consumer without :: or .Invoke`.
