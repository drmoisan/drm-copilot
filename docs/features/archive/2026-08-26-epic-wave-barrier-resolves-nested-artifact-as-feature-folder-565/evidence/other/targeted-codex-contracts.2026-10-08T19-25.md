# Targeted Tests: Codex Hook Contract Suites

Timestamp: 2026-10-08T19-25
Command: Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path @('tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1', 'tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1') -PassThru -Output Normal; 'Passed=' + $r.PassedCount + ' Failed=' + $r.FailedCount + ' FailedBlocks=' + $r.FailedBlocksCount + ' FailedContainers=' + $r.FailedContainersCount + ' Skipped=' + $r.SkippedCount + ' NotRun=' + $r.NotRunCount; $r.Failed | ForEach-Object { 'FAILED: ' + $_.ExpandedPath }; exit ([int](($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount) -gt 0))
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P7-T5.ps1
EXIT_CODE: 0
Output Summary: Passed=53 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0. The legacy Codex contract suite (now including feature-folder-resolution.ps1 in $script:SharedModuleNames: parse, 500-line cap, root/bundle byte identity) and the Codex epic runtime contract suite pass. P7-T3 (same session) printed JSON-OK for both pack manifests.

```
Passed=53 Failed=0 FailedBlocks=0 FailedContainers=0 Skipped=0 NotRun=0
```
