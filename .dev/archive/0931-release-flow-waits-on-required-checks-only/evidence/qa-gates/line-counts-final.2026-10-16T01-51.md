# Final Line Counts (Issue #931)

Timestamp: 2026-10-16T01-51
Command: wc -l scripts/dev-tools/Invoke-FullReleaseFlow.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1 tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py
EXIT_CODE: 0
Output Summary: All five counts are at most 500: 499, 426, 297, 151, 298.

| File | Baseline | Final |
|---|---|---|
| scripts/dev-tools/Invoke-FullReleaseFlow.ps1 | 401 | 499 |
| tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 | 426 | 426 |
| tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 | 141 | 297 |
| tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1 | (new) | 151 |
| tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py | 266 | 298 |
