# Coverage comparison

Timestamp: 2026-10-29T13-11
Command: summary script under SCRATCH reading artifacts/pester/powershell-coverage.xml (line elements with ci > 0 over all line elements, per source file under .claude/); baseline from coverage-baseline.2026-10-29T12-16.md
EXIT_CODE: 0
Output Summary: post-change line coverage versus baseline (all at least 85% and none below baseline)
- CleanupWorktreeManifest.psm1: 92.52% -> 92.79% (103 of 111)
- WorktreeRunRecordPath.psm1: 100% -> 100% (37 of 37)
- enforce-parallel-worktree-removal-gate.ps1: 93.10% -> 95.54% (107 of 112)
- enforce-epic-worktree-removal-gate.ps1: 95.61% -> 95.61% (109 of 114)
- enforce-epic-worktree-removal-gate-resolution.ps1: 98.18% -> 100% (51 of 51)
Note: deleting the two covered helper functions alone lowered the parallel gate to 92.86% and the resolution file to 98.04%, both below baseline. Rows RP5 and RP6 (shipped epic checkpoint reader, Test-Path and Get-Content mocked) and RE5 (Find-EpicWorktreeGateParallelItemRecord with null checkpoint or blank path) were added to cover pre-existing uncovered lines so that no file is below its baseline. PowerShell has no branch gate.
