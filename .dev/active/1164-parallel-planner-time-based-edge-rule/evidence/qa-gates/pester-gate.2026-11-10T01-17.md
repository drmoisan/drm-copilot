# Final Pester Gate, Restarted Loop (P6-T5)

Timestamp: 2026-11-10T01-17
Command: sh SCRATCH/issue-1164-pester-gate.sh (pwsh: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 from the branch; Invoke-PoshQCParallelTest -Root <worktree>; exit with the returned ExitCode)
EXIT_CODE: 0
Output Summary:
- Run started 2026-11-10T01-06 (UTC) after the second restart of the QA loop (pytest-gate record of 2026-11-10T01-05); wall clock 642.5 s; 8 shard processes, every shard exit 0; returned ExitCode 0; merged reports written at 2026-11-10T01-17. This run supersedes pester-gate.2026-11-10T00-59.md, which passed before the restart.
- Counts from artifacts/pester/pester-junit.xml: 21486 tests, 21476 passed, 0 failed, 0 errors, 10 skipped.
- Repo-wide line coverage (artifacts/pester/powershell-coverage.xml): 37624 / 39271 = 95.81% (Phase 0 baseline 95.79%; threshold 85%).
- Per-file line coverage of every changed or new PowerShell production file:
  - .claude/lib/blast-radius/BlastRadiusScheduling.psm1: 136 / 136 = 100.00% (baseline 100.00%)
  - .claude/lib/blast-radius/BlastRadiusAccess.psm1 (new): 53 / 53 = 100.00%
  - .claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1: 179 / 179 = 100.00% (baseline 100.00%)
  - .claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1 (new): 41 / 42 = 97.62%
  - .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1: 241 / 249 = 96.79% (baseline 96.48%)
  - .claude/lib/parallel-drift/ParallelDrift.psm1: 128 / 128 = 100.00% (baseline 100.00%)
  - .claude/lib/parallel-drift/ParallelDriftAccess.psm1 (new): 14 / 14 = 100.00%
- Named cases of Phases 1-5 (SCRATCH/issue-1164-junit-names.py over SCRATCH/issue-1164-pester-names.txt): NAMED_NOT_ALL_PASSED 0; parallel-scheduling-rule-wording.Tests.ps1: 228 cases (74 surface-token cases), 0 failed.
- FileSizePolicy cases, including tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1: all PASSED.
