# DocsProfileCommands Suite ([P4-T3])

Timestamp: 2026-11-03T13-41
Command: sh SCRATCH/issue-1020-test.sh tests/scripts/claude-lib/docs issue-1020-exec-p4-commands.log (branch-current `Invoke-PoshQCTest -ScanFolders tests/scripts/claude-lib/docs` from `scripts/powershell/PoshQC/PoshQC.psd1`); counts read from `artifacts/pester/pester-junit.xml` by SCRATCH/issue-1020-summary.ps1
EXIT_CODE: 0
Output Summary: `DocsProfileCommands.Tests.ps1` tests=22 failures=0 errors=0 (296 tests in the run minus 274 in the run before this suite existed). Whole run (8 suites): tests=296 failures=0 errors=0 skipped=0. Line coverage of `.claude/lib/docs/DocsProfileCommands.psm1` 97.1% (67 covered, 2 missed: the exit-3 branch for a starter profile that fails its own validation).

## Notes

- All command tests use the in-memory context of `Docs.TestSupport.psm1`; the init template path is driven by in-memory `-TemplateRow` rows whose `Source` entries are an empty text (`accept.txt`) and the text `x`.
- The init template table is asserted by membership only (anchors and a loop over returned rows); no row-count assertion.
