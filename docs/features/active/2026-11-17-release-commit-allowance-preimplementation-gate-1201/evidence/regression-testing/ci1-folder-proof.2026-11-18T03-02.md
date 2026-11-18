# Finding CI-1 - folder proof over the Linux job's file set (re-run after the leaker supplement)

Timestamp: 2026-11-18T02-53
Command: sh SCRATCH/issue-1201-suite-retry.sh rc1-folder2 pester -TestPath tests/scripts/claude-hooks tests/scripts/codex-hooks (launcher `pester` suite, Invoke-PoshQCParallelTest, 8 workers); sh SCRATCH/issue-1201-leak-scan.sh
EXIT_CODE: 0
Output Summary: re-run after the three additional leaker teardowns (evidence/other/ci1-diagnosis.2026-11-18T02-52.md). Folder run: 15526 tests, 15518 passed, 0 failed, 0 errors, 8 skipped. The row `hook-release-allowance-context.ps1 (Claude).baseline mock interception probe` passed. Leak scan: EXIT_CODE 0, 0 failures.

- Run window 2026-11-18T02-53 to 2026-11-18T03-01 UTC; 1 attempt; wall-clock 457.67 s; EXIT_CODE 0. JUnit copied to SCRATCH/issue-1201-rc1-folder2-junit.xml.
- Leak scan at 2026-11-18T02-53: "Leak scan: 865 files, 78 findings, 76 exempt, 2 allowlisted, 0 failures."
- Fail-before reference, and the limit of local reproduction: unchanged from evidence/regression-testing/ci1-folder-proof.2026-11-18T02-35.md (CI run 44214588875, Linux job, 1 failed). The Linux confirmation is the CI run the orchestrator dispatches at S9.
