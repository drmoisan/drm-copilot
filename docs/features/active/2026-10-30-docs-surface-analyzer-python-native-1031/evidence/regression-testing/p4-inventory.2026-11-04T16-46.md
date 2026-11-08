# [P4-T6] inventory -AnalysisMethod option and the inventory suites

Timestamp: 2026-11-04T16-46
Command: sh SCRATCH/issue-1031-gate.sh issue-1031-p4t6.out tests/scripts/claude-lib/docs/DocsInventory.PythonNative.Tests.ps1,tests/scripts/claude-lib/docs/DocsInventory.Tests.ps1,tests/scripts/claude-lib/docs/DocsInventoryProperties.Tests.ps1 -NoCoverage (branch-current Invoke-PoshQCTest, all three suites in one process)
EXIT_CODE: 0
Output Summary: artifacts/pester/pester-junit.xml tests=32 failures=0 errors=0 (DocsInventory.PythonNative.Tests.ps1 11, DocsInventory.Tests.ps1 13, DocsInventoryProperties.Tests.ps1 8). The new suite runs Invoke-DocsCommandCli with an in-memory context and a fixed clock and passes:
- uses the native analyzers when the helper answers, with scanner elements for config-files and non-.py inputs (S11; each snapshot validates as surface-inventory-snapshot and each -Json envelope as docs-command-envelope through Test-DocsArtifactText)
- is silent with the pack absent: exit 0, scanner elements, no added diagnostic and zero InvokeProcess calls (S3)
- falls back to the scanner under auto with one PYTHON_NATIVE_UNAVAILABLE diagnostic (information, docs-inventory, path null) naming interpreter-not-found, version-below-floor, timeout, exit-nonzero, start-error and output-invalid (S4, six cases)
- exits 3 under native with one DOCS_PYTHON_NATIVE_UNAVAILABLE finding and no WriteText call
- makes zero InvokeProcess calls under scanner
- exits 2 with DOCS_CLI_ARGUMENTS for an unknown -AnalysisMethod value (S6)
Every pre-existing case of DocsInventory.Tests.ps1 and DocsInventoryProperties.Tests.ps1 passes; the only updates are the AnalysisMethod key in the exact option set of 'registers the inventory row with its options and Test-DocsCommandTable returns no finding' and the two AfterAll Remove-Module lists, which gain DocsAnalyzerPythonNative and DocsPythonNativeProtocol.

Command: git diff --numstat MERGE_BASE -- .claude/lib/docs/Invoke-DocsCommand.ps1
EXIT_CODE: 0
Output Summary: 1	1	.claude/lib/docs/Invoke-DocsCommand.ps1 (1 added, 1 deleted; the inventory row Option gains AnalysisMethod = 'value').
Supporting numstat: .claude/lib/docs/DocsInventory.psm1 32 added 6 deleted; tests/scripts/claude-lib/docs/DocsInventory.Tests.ps1 2 added 2 deleted; tests/scripts/claude-lib/docs/DocsInventoryProperties.Tests.ps1 1 added 1 deleted.
