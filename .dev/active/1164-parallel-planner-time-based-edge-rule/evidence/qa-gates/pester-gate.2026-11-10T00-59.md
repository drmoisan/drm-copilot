# Final Pester Gate (P6-T5)

Timestamp: 2026-11-10T00-59
Command: sh SCRATCH/issue-1164-pester-gate.sh (pwsh: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 from the branch; Invoke-PoshQCParallelTest -Root <worktree>; exit with the returned ExitCode)
EXIT_CODE: 0
Output Summary:
- Run started 2026-11-10T00-48 (UTC) after the restarted static loop; wall clock 625.41 s; 8 shard processes, every shard exit 0; returned ExitCode 0; merged reports written at 2026-11-10T00-58.
- Counts from artifacts/pester/pester-junit.xml: 21486 tests, 21476 passed, 0 failed, 0 errors, 10 skipped (Phase 0 baseline: 21216 tests, 21206 passed, 0 failed, 10 skipped).
- Repo-wide line coverage (artifacts/pester/powershell-coverage.xml): 37624 / 39271 = 95.81% (baseline 95.79%; threshold 85%).
- Per-file line coverage of every changed or new PowerShell production file:
  - .claude/lib/blast-radius/BlastRadiusScheduling.psm1: 136 / 136 = 100.00% (baseline 100.00%)
  - .claude/lib/blast-radius/BlastRadiusAccess.psm1 (new): 53 / 53 = 100.00%
  - .claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1: 179 / 179 = 100.00% (baseline 100.00%)
  - .claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1 (new): 41 / 42 = 97.62%
  - .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1: 241 / 249 = 96.79% (baseline 96.48%)
  - .claude/lib/parallel-drift/ParallelDrift.psm1: 128 / 128 = 100.00% (baseline 100.00%)
  - .claude/lib/parallel-drift/ParallelDriftAccess.psm1 (new): 14 / 14 = 100.00%
- Named cases of Phases 1-5 in the JUnit output (SCRATCH/issue-1164-junit-names.py over SCRATCH/issue-1164-pester-names.txt): every listed name present and PASSED, NAMED_NOT_ALL_PASSED 0. This covers the 19 BlastRadiusAccess.Tests.ps1 cases, both new scheduling stems, both new drift fixtures, the 3 ParallelDriftAccess cases, the 2 new Scheduling record cases and the unchanged projection and committed-record cases, the 9 gate cases, the 5 CLI cases, the unchanged unknown-subcommand case, and the 228 cases of parallel-scheduling-rule-wording.Tests.ps1 (12 pinned sentence, 12 precedence_not_justified, 108 rule element, 74 surface token, 2 admission paragraph, 6 helper description, 14 absence), all PASSED.
- FileSizePolicy: 146 cases including tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1, all PASSED.
- The earlier failing run of this gate is recorded in pester-gate.2026-11-10T00-46.md.
