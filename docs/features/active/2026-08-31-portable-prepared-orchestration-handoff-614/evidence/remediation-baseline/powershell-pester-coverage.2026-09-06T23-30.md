# PowerShell No-Regression Baseline — Issue #614 Remediation

Timestamp: 2026-09-07T01-35
Cycle: 2026-09-06T23-30
Task: [P0-T12]
Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-31T07-29` and no other argument
EXIT_CODE: 0

## 1. MCP result, verbatim

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-31T07-29","summary":"Ran bundled PoshQC test against 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-31T07-29'."}
```

The tool returns only an ok flag and a one-sentence summary. It prints no test counts and
no coverage percentage, so the numbers below are read from the run's own result artifacts.

## 2. Test counts from `artifacts/pester/pester-junit.xml`

Root `testsuites` attributes:

```
name="Pester" tests="3940" errors="0" failures="0" disabled="9" time="182.730"
```

Per-`testcase` tally:

```
total=3940 passed=3931 failed=0 errored=0 skipped=9
```

The root element carries `failures="0"` and `errors="0"`.

## 3. Report-level `LINE` counter from `artifacts/pester/powershell-coverage.xml`

The file carries 868 elements matching `counter type="LINE"`, one per method, class, and
package in addition to the report-level total. The value below is taken from the counter
whose parent is the root `report` element; it is the only such direct child and it is the
last `counter type="LINE"` element in the file, both of which were verified for this run.

```
covered=7447 missed=411 total=7858
```

`LINE` percentage: 94.7697% (7447 / 7858).

Output Summary: The PoshQC test run reports `ok: true`. Pester ran 3940 test cases with
0 failures, 0 errors, and 9 skipped. Report-level line coverage is 94.7697% over 7858
lines. No PowerShell file is changed by this plan, so P4-T10 compares against these same
figures as a floor.
