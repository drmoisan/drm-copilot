# QC Pass 2: Full Pester Run with Coverage ([P10-T5])

Timestamp: 2026-10-08T23-19
Command: sh <SCRATCHPAD>/s-full-run.sh (Bash run_in_background: true; launcher runs `pwsh -NoProfile -File s-full-run.ps1`, which runs `Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root .`)
EXIT_CODE: 2
ExpectedExitCode: 2
Output Summary:
FULL_RUN_EXIT_CODE: 2
Tests completed in 293.41s
Tests Passed: 7211, Failed: 2, Skipped: 10, Inconclusive: 0, NotRun: 0
Covered 85.15% / 0%. 23,254 analyzed Commands in 183 Files.

The exit code 2 is caused by the two failing tests, both members of `B_FULL` (baseline `pester-full-run.2026-10-08T17-32.md` recorded `FULL_RUN_EXIT_CODE: 2` with the same two failures). The failing names are listed by [P10-T6]. Passed count rose by 14 over pass 1 (7197 to 7211), matching the 14 executions added between passes.

Task start: 2026-10-08T23:11:58Z.
Artifact last-write times after the run (UTC):
- artifacts/pester/powershell-coverage.xml: 2026-10-08T23:17:28Z
- artifacts/pester/pester-junit.xml: 2026-10-08T23:19:44Z
Both files were rewritten by this run (last-write time after the task start). Before the run, they carried 23:10:31Z and 23:11:47Z from the [P10-T4] MCP call.
