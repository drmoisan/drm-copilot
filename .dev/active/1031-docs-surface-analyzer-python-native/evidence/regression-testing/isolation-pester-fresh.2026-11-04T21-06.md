# [P6-T14] Fresh single-process Pester over tests/scripts without coverage

Timestamp: 2026-11-04T21-06
Command: sh SCRATCH/issue-1031-pester.sh fresh-nocov <worktree> -ScanFolders tests/scripts -NoCoverage -TestResultPath SCRATCH/issue-1031-fresh-junit.xml (new pwsh process running SCRATCH/issue-1031-poshqc-gate.ps1: branch-current Invoke-PoshQCTest with CodeCoverage.Enabled set to false through the LoadSettings seam)
EXIT_CODE: 255
Output Summary: Tests Passed: 15406, Failed: 409, Skipped: 10, Inconclusive: 0, NotRun: 0 (console summary line; 959 s).

Result against the acceptance criterion: NOT MET on this host; task left unchecked and pending-CI on `poshqc / PowerShell QC`. All 409 failures are pre-existing host failures:
- Compared with the merge-base reference run (SCRATCH/issue-1031-base-ref.out, MERGE_BASE extract, Failed 414) by SCRATCH/issue-1031-compare.sh: branch 97 normalized failure lines, reference 102; lines only in the branch run: none. The five reference-only lines are Invoke-FullReleaseFlow.ps1 cases that fail in the extracted tree only.
- The failure set equals that of the coverage run [P6-T9] (qa-pester-coverage.2026-11-04T20-43.md) and the [P0-T8] baseline counts (409 failures, 97 lines).
- No failure line lies under tests/scripts/claude-lib/docs or tests/scripts/claude-runtime, and none names a 1031 suite.
- The run exits 255 because the Pester JUnit export fails on a 0x1B character in a pre-existing failure message; counts come from the console line.
