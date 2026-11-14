# Pester gate (feature-review reviewer run at head)

Timestamp: 2026-11-14T07-32
Command: pwsh 7: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <item worktree root>; exit with the returned ExitCode (launched by the reviewer through sh SCRATCH/r1162-pester.sh at head 73ecccd13); figures read from artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml by SCRATCH/r1162-jac2.cjs
EXIT_CODE: 0
Output Summary:
- Reason: the executor's coverage report (written 2026-11-14T06:54:40Z) predated the newest PowerShell-touching commit 6c6959e96 (2026-11-14T06:55:26Z) by 46 seconds, although the committed PowerShell sources were last modified before that gate started. This run refreshes the canonical report at head.
- One Invoke-PoshQCParallelTest run: workers=8, every shard exited 0, wall-clock 1180.95 s, started 2026-11-14T07:12:41Z, ended 2026-11-14T07:32:23Z; merged JUnit and coverage reports written.
- JUnit totals: tests=24321, failures=0, errors=0, disabled (skipped)=10, passed=24311.
- Repository-wide line coverage: 40622 covered, 1706 missed, 95.97% (Phase 0 baseline 95.80%; executor final 95.97%).
- EpicCrossDependency.psm1 349/356 (98.03%); Invoke-EpicCrossReadiness.ps1 5/5 (100%); OrchestratorStateEpicCrossDependency.psm1 52/52 (100%); OrchestratorStateEpicWaveBarrier.psm1 139/139 (100%); Get-EpicProgressReport.CrossEpic.ps1 56/56 (100%); Get-EpicProgressReport.ps1 110/114 (96.49%); Logic 74/74, Schedule 210/210, CriticalPath 116/116, Render 226/226 (100% each).
- Figures equal the executor's final gate (pester.2026-11-14T06-55.md) exactly.
