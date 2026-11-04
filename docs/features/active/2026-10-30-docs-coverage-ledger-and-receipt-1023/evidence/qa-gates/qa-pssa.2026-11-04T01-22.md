# Final QA: PSScriptAnalyzer ([P7-T2])

Timestamp: 2026-11-04T01-22
Command: sh SCRATCH/issue-1023-pssa-file.sh <comma-separated list of every .ps1 and .psm1 under .claude/lib/docs and tests/scripts/claude-lib/docs, preceded by .claude/lib/docs/DocsJson.psm1> (PowerShell 7: Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file, PSScriptAnalyzer 1.25.0; prints OK <path> findings=<n> or ERROR <path> per file)
EXIT_CODE: 0
Output Summary: FINDINGS=0 over 59 distinct files (19 under LIB: the ten 1023 modules, the entry script and the eight 1020 modules; 40 under TESTS: the 26 1023 files, the 1020 suites, Docs.TestSupport.psm1 and fixtures/DocsAnalyzerFixture.psm1). Every file reports findings=0. The leading DocsJson.psm1 invocation reported the known PSScriptAnalyzer 1.25 first-file null-reference (ERROR, not a finding); the same file re-analyzed behind DocsFinding.psm1 reports findings=0, as it does inside the list. No finding by any rule; no fix and no loop restart. CI: poshqc / PowerShell QC static.

## Finding count by rule name

None (0 findings).

## Route note

The folder-level run `sh SCRATCH/issue-1023-pssa.sh` (`Invoke-ScriptAnalyzer -Recurse` over the two folders, the [P0-T5] route) raised the same null-reference on its first folder in this process and was replaced by the per-file route above, which the Phase 1-5 evidence also used.
