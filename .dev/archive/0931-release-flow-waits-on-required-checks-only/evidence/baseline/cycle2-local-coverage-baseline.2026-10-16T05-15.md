# Cycle 2 Local Coverage Baseline (Issue #931)

Timestamp: 2026-10-16T05-15
Command: Grep `sourcefilename="Invoke-FullReleaseFlow.ps1"` in artifacts/pester/powershell-coverage.xml (line 17816); Read of that `<class>` element (lines 17816-17881); date -u -r artifacts/pester/powershell-coverage.xml +%Y-%m-%dT%H-%M
EXIT_CODE: 0
Output Summary: Local scoped line coverage of scripts/dev-tools/Invoke-FullReleaseFlow.ps1 is 95.63% (153 covered of 160 valid, 7 missed), above the CI floor of 94.26%. Missed lines are in Invoke-GitExe (2), Invoke-GhExe (2), Invoke-ChildPowerShellScript (2), Invoke-Sleep (1).

BASELINE_COVERED: 153
BASELINE_MISSED: 7
BASELINE_VALID: 160
BASELINE_PERCENT: 95.63
COVERAGE_WRITTEN: 2026-10-16T05-15
CALL_TS: 2026-10-16T05-13
CI floor percent: 94.26 (from `ps-coverage-main.2026-10-16T01-23.md`, 115 / 122)

Class-level counter (verbatim): `<counter type="LINE" missed="7" covered="153" />`
