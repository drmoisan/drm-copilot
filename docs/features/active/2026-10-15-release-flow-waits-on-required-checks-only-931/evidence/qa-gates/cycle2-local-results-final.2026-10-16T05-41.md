# Cycle 2 Final QC: Local Results and Per-File Coverage, amended (Issue #931)

Timestamp: 2026-10-16T05-41
Command: Read root of artifacts/pester/pester-junit.xml; Grep `sourcefilename="Invoke-FullReleaseFlow.ps1"` and `sourcefilename="Invoke-FullReleaseFlow.CheckHelpers.ps1"` and the path `scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers` in artifacts/pester/powershell-coverage.xml and Read of the found `<class>` element (lines 17816-17871, class name ending `scripts/dev-tools/Invoke-FullReleaseFlow`); date -u -r artifacts/pester/pester-junit.xml +%Y-%m-%dT%H-%M; date -u -r artifacts/pester/powershell-coverage.xml +%Y-%m-%dT%H-%M
EXIT_CODE: 0
Output Summary: PASS under the approved amendment fallback. 665 tests = 655 + 10, 0 failures, 0 errors. SCRIPT_PERCENT 94.93 (131/138, missed 7 <= baseline missed 7), above the 94.26 floor. HELPER_PERCENT not measured locally (no helper class row in the local report). COMBINED_PERCENT not computed. HELPER_COVERAGE: measured in PR CI only (job `poshqc / PowerShell QC`, artifact `poshqc-test-results`), gated at S9 per P2-T9.

## Approved amendment (orchestrator, 2026-10-16)

First attempt to measure the helper by invoking the in-repo PoshQC module directly (it reads the in-repo `config/poshqc-coverage.json`). If that run yields a CheckHelpers row: failures 0, errors 0, tests = baseline + 10, script percent >= 94.26 with missed <= baseline missed, helper percent >= 94.26, combined >= 95.63. If it yields no helper row: record the script row only plus a `HELPER_COVERAGE` line stating that it is measured in PR CI only, and add an S9 sentence to P2-T9. If the hook produces a false `PR_AUTHOR_SKILL_BLOCKED` on the direct pwsh command, report it and use `mcp__drm-copilot__run_poshqc_test` for the test run.

Outcome: the direct pwsh command was rejected by the PreToolUse hook with `PR_AUTHOR_SKILL_BLOCKED` (false positive; the command creates no pull request). The MCP rerun (`cycle2-ps-test.2026-10-16T05-41.md`) used the installed extension's runsettings allow-list, which omits the helper file, so no helper row exists. The fallback branch applies.

FINAL_CALL_TS: 2026-10-16T05-39
FINAL_JUNIT_WRITTEN: 2026-10-16T05-40 (date exit 0)
FINAL_COVERAGE_WRITTEN: 2026-10-16T05-40 (date exit 0)

## Test results

FINAL_TESTS: 665
FINAL_FAILURES: 0
FINAL_ERRORS: 0
BASELINE_TESTS: 655 (from `cycle2-local-results-baseline.2026-10-16T05-15.md`)

Root element (verbatim):

```xml
<testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="Pester" tests="665" errors="0" failures="0" disabled="2" time="20.001">
```

## Script coverage (`scripts/dev-tools/Invoke-FullReleaseFlow.ps1`)

Class element key: `name` ends `scripts/dev-tools/Invoke-FullReleaseFlow`, `sourcefilename="Invoke-FullReleaseFlow.ps1"` (line 17816; the only match).
Class-level counter (verbatim, line 17868): `<counter type="LINE" missed="7" covered="131" />`

SCRIPT_COVERED: 131
SCRIPT_MISSED: 7
SCRIPT_VALID: 138
SCRIPT_PERCENT: 94.93

## Helper coverage (`scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1`)

HELPER_COVERAGE: measured in PR CI only. The local MCP runner uses the installed extension's `CodeCoverage.Path` allow-list (`danmoisan.drm-copilot-1.1.18`), which does not name the helper file; the in-repo module, which would include it through `config/poshqc-coverage.json`, could not be invoked because the hook rejected the command.

SearchScope: `artifacts/pester/powershell-coverage.xml` (written 2026-10-16T05-40)
SearchPatterns: `sourcefilename="Invoke-FullReleaseFlow[^"]*"` (1 match, line 17816, main script only); `CheckHelpers` (0 matches); `scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers` (0 matches)
SearchResult: none for the helper file

HELPER_COVERED / HELPER_MISSED / HELPER_VALID / HELPER_PERCENT: not measured locally.
COMBINED_COVERED / COMBINED_MISSED / COMBINED_VALID / COMBINED_PERCENT: not computed (helper values not measured locally).

## Baseline and floor

BASELINE_COVERED: 153
BASELINE_MISSED: 7
BASELINE_VALID: 160
BASELINE_PERCENT: 95.63 (from `cycle2-local-coverage-baseline.2026-10-16T05-15.md`)
CI floor: 94.26 (from `ps-coverage-main.2026-10-16T01-23.md`)
Delta COMBINED_PERCENT - BASELINE_PERCENT: not computed. Script-only delta 94.93 - 95.63 = -0.70; the drop reflects the 22 fully covered helper lines (153 - 131) leaving the local denominator, not new missed lines (missed stays 7).

## Acceptance evaluation (amended fallback)

| Condition | Result |
|---|---|
| Both written stamps >= FINAL_CALL_TS | PASS (05-40 >= 05-39) |
| FINAL_FAILURES and FINAL_ERRORS are 0 | PASS |
| FINAL_TESTS = BASELINE_TESTS + 10 | PASS (665 = 655 + 10) |
| SCRIPT_PERCENT >= 94.26 | PASS (94.93) |
| SCRIPT_MISSED <= BASELINE_MISSED | PASS (7 <= 7) |
| HELPER_COVERAGE line present, stating PR CI only | PASS |
| Helper percent >= 94.26, missed 0 | Deferred to S9 (P2-T9 S9 instruction) |
