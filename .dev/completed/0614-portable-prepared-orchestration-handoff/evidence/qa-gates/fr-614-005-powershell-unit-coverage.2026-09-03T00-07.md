# PowerShell Unit Tests and Coverage — P3-T12

Timestamp: 2026-09-06T00-00
Task: [P3-T12]

Command: MCP tool `mcp__drm-copilot__run_poshqc_test` invoked with only
`{"workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-31T07-29"}`
and `scan_folders` omitted. No direct Pester command and no narrowed scan was
used.
EXIT_CODE: 0

MCP result:
```
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-31T07-29","summary":"Ran bundled PoshQC test against 'C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-31T07-29'."}
```

The MCP tool returns an ok flag and a one-sentence summary and prints no
counts, so the numeric results below are read from the run's own artifacts:
`artifacts/pester/pester-junit.xml` and
`artifacts/pester/powershell-coverage.xml`.

## Test counts (from `artifacts/pester/pester-junit.xml`)

Root `testsuites` attributes: `tests="3940" errors="0" failures="0"`.
Per-`testcase` tally over the same document:

```
TESTCASES total=3940 skipped=9 failed=0 errored=0 passed=3931
```

Active passed: 3931
Skipped or disabled: 9
Failed: 0
Errored: 0

## Coverage (from `artifacts/pester/powershell-coverage.xml`)

The report's `LINE` counter is the authoritative line-coverage source:

```
counter: {'type': 'LINE', 'missed': '411', 'covered': '7447'}
```

Covered line count: 7447
Total line count: 7858 (7447 covered + 411 missed)

These are stated as separate numeric values so a changed denominator is
visible: the baseline denominator was 7848 and the final denominator is 7858.

LINE_COVERAGE: 94.76966149147366%

Branch coverage: not applicable. Pester measures no branch coverage in any
output format, so the uniform 75% branch threshold in
`.claude/rules/quality-tiers.md` is not evaluable for PowerShell and no
branch-coverage gate applies. This is a threshold exemption only; every
PowerShell production file remains in the coverage denominator.

## Threshold comparison

| Metric | Baseline (P0-T5 artifact) | Final | Result |
| --- | --- | --- | --- |
| Active passed | 3923 | 3931 | above the 3923 floor |
| Skipped or disabled | 9 | 9 | at the floor |
| Failed / errored | 0 / 0 | 0 / 0 | unchanged |
| Covered lines | 7437 | 7447 | — |
| Total lines | 7848 | 7858 | denominator grew by 10 |
| LINE_COVERAGE | 94.762996941896% | 94.76966149147366% | above baseline by 0.0067 pp |

The pass count exceeds the 3923 floor and the skip count is at the 9 floor,
consistent with the rebase onto `origin/main` having added 63 Pester lines to
`tests/scripts/claude-hooks/validate-bash.Tests.ps1`. Line coverage is above the
numeric baseline value recorded in the Phase 0 artifact, so there is no
shortfall and the rebase-attribution carve-out in this task is not invoked and
no recomputation over the file set unchanged since
`9f3514bf5da84110f23617382cbbeabf54f27427` is required. No P3-T1 restart is
triggered.

Output Summary: PoshQC test exited 0 with 3931 active tests passing, 9 skipped
or disabled, and zero failures or errors. Line coverage is 7447/7858 =
94.76966149147366%, above the recorded 94.762996941896% baseline. Pester
measures no branch coverage, so the branch threshold is exempt.
