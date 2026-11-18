# Finding CI-1 - folder proof over the Linux job's file set

Timestamp: 2026-11-18T02-35
Command: sh SCRATCH/issue-1201-suite-retry.sh rc1-folder pester -TestPath tests/scripts/claude-hooks tests/scripts/codex-hooks (launcher `pester` suite, Invoke-PoshQCParallelTest, 8 workers); sh SCRATCH/issue-1201-leak-scan.sh (Invoke-PoshQCLeakScan -Root the worktree, branch-current PoshQC module)
EXIT_CODE: 0
Output Summary: the folder run passed with 15526 tests, 15518 passed, 0 failed, 0 errors, 8 skipped. The row `hook-release-allowance-context.ps1 (Claude).baseline mock interception probe` passed. The leak scan exited 0 with 0 failures.

## Folder run

- Run window 2026-11-18T02-27 to 2026-11-18T02-35 UTC; 1 attempt; wall-clock 467.44 s; EXIT_CODE 0.
- JUnit (artifacts/pester/pester-junit.xml, copied to SCRATCH/issue-1201-rc1-folder-junit.xml): tests 15526, passed 15518, failed 0, errors 0, skipped 8.
- `hook-release-allowance-context.ps1 (Claude).baseline mock interception probe`: Passed. `hook-release-allowance-context.ps1 (Codex).baseline mock interception probe`: Passed.
- The selection is the file set of `poshqc / PowerShell hook suites (Linux)`. The local run splits it across 8 processes, while the Linux job runs it in one process (see evidence/other/ci1-diagnosis.2026-11-18T02-06.md, section 3). This run therefore proves the fix keeps every hook suite green; it does not reproduce the shared-process ordering. The authoritative Linux confirmation is the CI run the orchestrator dispatches at S9.

## Leak scan

- EXIT_CODE 0; "Leak scan: 865 files, 78 findings, 76 exempt, 2 allowlisted, 0 failures." Failure count: 0, unchanged from evidence/remediation-baseline/leak-scan.2026-11-18T01-51.md.

## Fail-before reference

- Observed pre-fix failure: CI run 44214588875 on PR #1202 at the cycle-0 head, job `poshqc / PowerShell hook suites (Linux)`: Tests Passed 15529, Failed 1, Skipped 8. The failing row was `hook-release-allowance-context.ps1 (Claude).baseline mock interception probe`, with the message "Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 time exactly, but was called 0 times" (remediation-inputs.2026-11-18T01-37.md, Finding CI-1).
- A local fail-before run is not possible under the parallel-only rule: the failure needs a run-module-replacing suite to run before the victim in one process, and the local launcher distributes files across processes. The diagnosis records the code path that produces the observed counts.
