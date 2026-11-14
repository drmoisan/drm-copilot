# [P4-T3] Native analyzer functions and parity suite

Timestamp: 2026-11-04T16-20
Command: sh SCRATCH/issue-1031-gate.sh issue-1031-p4t3.out tests/scripts/claude-lib/docs/DocsAnalyzerPythonNative.Tests.ps1,tests/scripts/claude-lib/docs/DocsAnalyzerPythonNative.Parity.Tests.ps1 -NoCoverage (branch-current Invoke-PoshQCTest, both suites in one process)
EXIT_CODE: 0
Output Summary: artifacts/pester/pester-junit.xml tests=21 failures=0 errors=0 (DocsAnalyzerPythonNative.Tests.ps1 15, DocsAnalyzerPythonNative.Parity.Tests.ps1 6). Shared rows compared: 105 (the 1022 corpus .py rows of the four identifiers: python-cli 36, python-public-api 26, python-http 23, python-architecture 20); each native element_id and source_sha256 equals the corpus value and the 1022 scanner output, every native element records analysis_method native, and each identifier's native element count equals its shared rows plus its native_only_elements. The scanner reports exactly native_input_scanner_diagnostics for the native inputs. The two new module texts contain none of Get-DocsDeclarationSha256, Get-DocsDeclarationDigest, Security.Cryptography, HashAlgorithm and ConvertTo-DiscoveryCanonicalJson (case-sensitive).

Note: the non-forcing -ImportModule seam is { param($Path) Import-Module -Name $Path -Global -ErrorAction Stop }. Without -Global, Invoke-DocsAnalyzer's Get-Command inside the registry module does not see an analyzer function imported by the suite when the runner (Invoke-PoshQCTest) hosts the test inside a module; the seam still never forces a re-import.
