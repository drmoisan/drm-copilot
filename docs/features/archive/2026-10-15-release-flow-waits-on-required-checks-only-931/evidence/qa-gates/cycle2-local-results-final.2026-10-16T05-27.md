# Cycle 2 Final QC: Local Results and Per-File Coverage (Issue #931)

Timestamp: 2026-10-16T05-27
Command: Read root of artifacts/pester/pester-junit.xml; Grep `sourcefilename="Invoke-FullReleaseFlow.ps1"` and `sourcefilename="Invoke-FullReleaseFlow.CheckHelpers.ps1"` in artifacts/pester/powershell-coverage.xml and Read of the found `<class>` element (lines 17816-17871); date -u -r artifacts/pester/pester-junit.xml +%Y-%m-%dT%H-%M; date -u -r artifacts/pester/powershell-coverage.xml +%Y-%m-%dT%H-%M
EXIT_CODE: 1
Output Summary: BLOCKED. Test results pass: 665 tests = 655 + 10, 0 failures, 0 errors. SCRIPT_PERCENT 94.93 (131/138), above the 94.26 floor. HELPER_PERCENT unavailable: the coverage report contains no class element for Invoke-FullReleaseFlow.CheckHelpers.ps1 (Grep for `CheckHelpers` returns 0 matches). COMBINED values cannot be computed. Cause: the MCP test tool runs the installed extension's bundled PoshQC (version 1.1.18), whose runsettings carry an explicit per-file CodeCoverage.Path allow-list that does not name the new helper file. Outcome: remediation-required; task left unchecked.

FINAL_JUNIT_WRITTEN: 2026-10-16T05-27
FINAL_COVERAGE_WRITTEN: 2026-10-16T05-27
FINAL_CALL_TS: 2026-10-16T05-26

## Test results

FINAL_TESTS: 665
FINAL_FAILURES: 0
FINAL_ERRORS: 0
BASELINE_TESTS: 655 (from `cycle2-local-results-baseline.2026-10-16T05-15.md`)

Root element (verbatim):

```xml
<testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="Pester" tests="665" errors="0" failures="0" disabled="2" time="26.122">
```

## Script coverage (`scripts/dev-tools/Invoke-FullReleaseFlow.ps1`)

Class-level counter (verbatim): `<counter type="LINE" missed="7" covered="131" />`

SCRIPT_COVERED: 131
SCRIPT_MISSED: 7
SCRIPT_VALID: 138
SCRIPT_PERCENT: 94.93

The seven missed lines are the unchanged mocked seams: Invoke-GitExe (2), Invoke-GhExe (2), Invoke-ChildPowerShellScript (2), Invoke-Sleep (1). Wait-ForPullRequestChecks reports 41 covered, 0 missed.

## Helper coverage (`scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1`)

HELPER_COVERED: unavailable
HELPER_MISSED: unavailable
HELPER_VALID: unavailable
HELPER_PERCENT: unavailable

SearchScope: `artifacts/pester/powershell-coverage.xml`
SearchPatterns: regex `sourcefilename="Invoke-FullReleaseFlow(\.CheckHelpers)?\.ps1"` (1 match, line 17816, the main script only); literal `CheckHelpers` (0 matches)
SearchResult: none for the helper file

## Combined

COMBINED_COVERED, COMBINED_MISSED, COMBINED_VALID, COMBINED_PERCENT: not computable (helper values unavailable).

## Baseline and floor

BASELINE_COVERED: 153
BASELINE_MISSED: 7
BASELINE_VALID: 160
BASELINE_PERCENT: 95.63 (from `cycle2-local-coverage-baseline.2026-10-16T05-15.md`)
CI floor: 94.26 (from `ps-coverage-main.2026-10-16T01-23.md`)
Delta COMBINED_PERCENT - BASELINE_PERCENT: not computable.

## Acceptance evaluation

| Condition | Result |
|---|---|
| Both written stamps >= FINAL_CALL_TS | PASS (05-27 >= 05-26) |
| FINAL_FAILURES and FINAL_ERRORS are 0 | PASS |
| FINAL_TESTS = BASELINE_TESTS + 10 | PASS (665) |
| Helper class element exists | FAIL (absent) |
| SCRIPT_PERCENT >= 94.26 | PASS (94.93) |
| HELPER_PERCENT >= 94.26 and HELPER_MISSED = 0 | UNAVAILABLE |
| COMBINED_PERCENT >= BASELINE_PERCENT | UNAVAILABLE |
| COMBINED_MISSED <= BASELINE_MISSED | UNAVAILABLE |

## Blocker detail

- `mcp__drm-copilot__run_poshqc_test` runs the installed extension's bundled PoshQC, `danmoisan.drm-copilot-1.1.18`, using `resources/powershell/PoshQC/settings/pester.runsettings.psd1` from the extension folder.
- That runsettings file sets `CodeCoverage.Path` to an explicit per-file allow-list. The list names `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (line 64) and `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1` (line 287) but not `scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1`.
- The in-repo PoshQC (`scripts/powershell/PoshQC/PoshQC.Coverage.psm1`, README lines 68-73) derives the coverage population from `config/poshqc-coverage.json` (root `scripts`), which would include the new file. The plan fact in `## Verified Plan-Time Facts` (config/poshqc-coverage.json makes a new `.ps1` under `scripts/dev-tools/` measured) holds for the in-repo module and for CI, not for the MCP runner.
- The moved helper lines therefore left the local coverage denominator. They are not reported as missed.
- The plan forbids a shell wrapper that runs Pester, so the in-repo module cannot be invoked directly within this plan.
