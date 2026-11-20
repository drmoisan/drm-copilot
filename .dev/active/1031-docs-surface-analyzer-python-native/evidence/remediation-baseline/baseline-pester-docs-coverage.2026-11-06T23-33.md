# [P0-T6] Remediation baseline on the merged tree: Pester with coverage over the docs suites

Timestamp: 2026-11-06T23-33
Command: branch-current Invoke-PoshQCTest with coverage in one run, launched by `sh SCRATCH/issue-1031-pwsh.sh issue-1031-pester-gate.ps1 -Paths tests/scripts/claude-lib/docs` (TESTS/DocsPythonTokens.Tests.ps1 included; no suite excluded, skipped or run separately)
EXIT_CODE: 0
Output Summary: artifacts/pester/pester-junit.xml: tests 2129, failures 0, errors 0, skipped 0, suites 102. The run finished in about 11 minutes. Overall line coverage over the measured population 27.17% (9230/33977), which is low because only the docs suites ran. This artifact supersedes baseline-pester-docs-coverage.2026-11-06T16-37.md.

## DocsPythonTokens.Tests.ps1 testsuite element

`testsuite` for tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1: tests 58, failures 0, errors 0, time 53.223 s.

## Line coverage (artifacts/pester/powershell-coverage.xml)

| File | Line % (covered/total) |
|---|---|
| `LIB/DocsAnalyzerPythonNative.psm1` | 100.00 (91/91) |
| `LIB/DocsPythonNativeProtocol.psm1` | 100.00 (132/132) |
| `LIB/DocsAnalyzerRegistry.psm1` | 100.00 (135/135) |
| `LIB/DocsInventory.psm1` | 100.00 (121/121) |
| `LIB/Invoke-DocsCommand.ps1` | 87.82 (137/156) |
