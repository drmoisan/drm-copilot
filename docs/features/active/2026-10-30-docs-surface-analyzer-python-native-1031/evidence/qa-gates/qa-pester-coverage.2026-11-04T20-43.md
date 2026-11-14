# [P6-T9] Single-process Pester over tests/scripts with coverage (fresh run on the post-merge head)

Timestamp: 2026-11-04T20-43
Command: sh SCRATCH/issue-1031-pester.sh final-cov <worktree> -ScanFolders tests/scripts (new pwsh process running SCRATCH/issue-1031-poshqc-gate.ps1: branch-current Invoke-PoshQCTest from scripts/powershell/PoshQC/PoshQC.psd1; coverage enabled from config/poshqc-coverage.json, population 329 files)
EXIT_CODE: 255
Output Summary: Tests Passed: 15406, Failed: 409, Skipped: 10, Inconclusive: 0, NotRun: 0 (console summary line; 2452 s). Discovery found 15825 tests in 590 files.

Result against the acceptance criterion: NOT MET on this host; task left unchecked and marked pending-CI on `poshqc / PowerShell QC`. The criterion requires 0 failed and 0 errored; this Linux Codespace run has 409 failures, all pre-existing host failures:
- Merge-base reference: the same gate script was run without coverage over an extract of MERGE_BASE (`git archive 729ff55ef6b8fcfcf632d9d2220a674bb437bf7e` under SCRATCH/base, which holds the 1024 and 1033 siblings and no 1031 file): Passed 15321, Failed 414, Skipped 10 (SCRATCH/issue-1031-base-ref.out, 1052 s).
- The failure lines of both runs (`[-]` lines, ANSI codes and timings stripped, root prefix normalized, sorted and de-duplicated by SCRATCH/issue-1031-pester.sh and SCRATCH/issue-1031-compare.sh) were compared: branch 97 lines, reference 102 lines; lines only in the branch run: none. The five lines only in the reference run are Invoke-FullReleaseFlow.ps1 cases that fail in the extracted tree (no git repository), not on the branch.
- No failure line lies under tests/scripts/claude-lib/docs or tests/scripts/claude-runtime, and none names a 1031 suite.
- The branch failure count (409) and line count (97) equal the pre-merge [P0-T8] baseline and the earlier [P6-T9] record (qa-pester-coverage.2026-11-04T18-40.md).
- As in the baseline, the run exits 255 because the Pester JUnit export fails on a 0x1B character in a pre-existing failure message, so artifacts/pester/pester-junit.xml is truncated and the counts come from the console line.

Coverage (artifacts/pester/powershell-coverage.xml, read by SCRATCH/issue-1031-pester-cov.ps1): overall line coverage 94.33% (29998 of 31800 lines; [P0-T8] baseline 93.77% of a smaller pre-merge population).

| File | Covered / total | Line % |
|---|---|---|
| .claude/lib/docs/DocsAnalyzerPythonNative.psm1 | 89 / 89 | 100.00 |
| .claude/lib/docs/DocsPythonNativeProtocol.psm1 | 132 / 132 | 100.00 |
| .claude/lib/docs/DocsAnalyzerRegistry.psm1 | 135 / 135 | 100.00 |
| .claude/lib/docs/DocsInventory.psm1 | 121 / 121 | 100.00 |
| .claude/lib/docs/Invoke-DocsCommand.ps1 | 137 / 156 | 87.82 (missed lines 213, 215-229 and 252-254, none changed by this plan; the one changed line, 60, is covered) |

Changed-line check (`git diff -U0 MERGE_BASE` hunks): every added line of DocsAnalyzerRegistry.psm1 and DocsInventory.psm1 lies in a file with no missed line, and line 60 of Invoke-DocsCommand.ps1 is covered.

CI: `poshqc / PowerShell QC` (windows-latest shards 1 to 3) is the authoritative zero-failure gate (pending-CI).
