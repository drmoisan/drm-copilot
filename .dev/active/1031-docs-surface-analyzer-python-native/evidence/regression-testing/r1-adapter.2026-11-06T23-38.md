# [P1-T1] Adapter suppressions and the scanner-row contract error

Timestamp: 2026-11-06T23-38
Command: branch-current Invoke-PoshQCTest over TESTS/DocsAnalyzerPythonNative.Tests.ps1, TESTS/DocsAnalyzerPythonNative.Parity.Tests.ps1 and TESTS/DocsInventory.PythonNative.Tests.ps1 (`sh SCRATCH/issue-1031-pwsh.sh issue-1031-pester-gate.ps1 -NoCoverage -Paths ...`); counts from artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary: tests 38, failures 0, errors 0, skipped 0, suites 3. Every pre-existing case passes unchanged; one case added, `throws DOCS_PYTHON_NATIVE_SCANNER_ROW_MISSING when a native row has no scanner row`.

SHA-256 of LIB/DocsAnalyzerPythonNative.psm1: 18a112293233ec80f4b0077622a305df8cc1b1d4050941d136a101bc492001f8
SHA-256 of MIRROR/DocsAnalyzerPythonNative.psm1: 18a112293233ec80f4b0077622a305df8cc1b1d4050941d136a101bc492001f8
