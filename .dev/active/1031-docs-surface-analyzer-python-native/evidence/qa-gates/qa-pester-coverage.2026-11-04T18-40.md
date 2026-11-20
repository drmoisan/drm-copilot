# [P6-T9] Single-process Pester over tests/scripts with coverage

Timestamp: 2026-11-04T18-40
Command: sh SCRATCH/issue-1031-run.sh issue-1031-poshqc-gate.ps1 issue-1031-final-pester.out -Paths tests/scripts (new pwsh process; branch-current Invoke-PoshQCTest from scripts/powershell/PoshQC/PoshQC.psd1; coverage enabled from config/poshqc-coverage.json), the same command as the [P0-T8] baseline
EXIT_CODE: 255
Output Summary: Tests Passed: 14699, Failed: 409, Skipped: 10, Inconclusive: 0, NotRun: 0 (console summary line; 1921.7 s). Baseline [P0-T8]: Passed 14619, Failed 409, Skipped 10.

Result against the acceptance criterion: NOT MET on this host. The criterion requires 0 failed and 0 errored; this Linux Codespace run has 409 failures. They are the pre-existing host failures recorded in the [P0-T8] baseline before any 1031 file existed:
- The sorted, de-duplicated failure lines of this run (97 [-] lines, ANSI codes and timings stripped by SCRATCH/issue-1031-failset.py) are identical to the same extraction of the baseline output (diff empty; SCRATCH/issue-1031-final-failset.txt and SCRATCH/issue-1031-base-failset2.txt).
- No failure line lies under tests/scripts/claude-lib/docs or tests/scripts/claude-runtime, and no failure line names a 1031 suite.
- The pass count rose by 80 (the four new suites, the new registry case and the edited guard suite cases).
- As in the baseline, the run exits 255 because the Pester JUnit export fails on a 0x1B character in a pre-existing failure message, so artifacts/pester/pester-junit.xml is truncated and the counts come from the console line.
The authoritative zero-failure gate is CI: `poshqc / PowerShell QC` (windows-latest shards 1 to 3), which is pending-CI for this branch.

Coverage (artifacts/pester/powershell-coverage.xml, read by SCRATCH/issue-1031-pester-cov.ps1): overall line coverage 93.83% (26663 of 28417 lines; baseline 93.77%).

| File | Covered / total | Line % |
|---|---|---|
| .claude/lib/docs/DocsAnalyzerPythonNative.psm1 | 89 / 89 | 100.00 |
| .claude/lib/docs/DocsPythonNativeProtocol.psm1 | 132 / 132 | 100.00 |
| .claude/lib/docs/DocsAnalyzerRegistry.psm1 | 128 / 128 | 100.00 |
| .claude/lib/docs/DocsInventory.psm1 | 121 / 121 | 100.00 |
| .claude/lib/docs/Invoke-DocsCommand.ps1 | 136 / 155 | 87.74 (missed lines 212-228 and 251-253, unchanged since the baseline; the changed line 60 is covered) |
