# [P5-T4] Existing suites that scan LIB, the bundle or CORE

Timestamp: 2026-11-04T17-07
Command: sh SCRATCH/issue-1031-gate.sh issue-1031-p5t4.out <six suites> -NoCoverage (branch-current Invoke-PoshQCTest, all six suites in one process; none edited)
EXIT_CODE: 0
Output Summary: artifacts/pester/pester-junit.xml tests=162 failures=0 errors=0.

| Suite | Tests | Failures | Errors |
|---|---|---|---|
| tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1 | 7 | 0 | 0 |
| tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1 | 91 | 0 | 0 |
| tests/scripts/claude-lib/docs/DocsWriteBoundary.Tests.ps1 | 6 | 0 | 0 |
| tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1 | 47 | 0 | 0 |
| tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 | 6 | 0 | 0 |
| tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1 | 5 | 0 | 0 |

Named cases passing: 'Dispatch table.carries the anchors 1020, 1021, 1022, 1023, 1024 and 1034 in order, with no placeholder or 1031 anchor' and 'Write boundary of .claude/lib/docs.finds no filesystem write primitive outside Write-DocsFileText'.
