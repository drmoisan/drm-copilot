# Pester Baseline With Coverage — [P0-T5]

Timestamp: 2026-08-26T05-28

Task: [P0-T5]
Workspace root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a931fa47c98f755c3`
Tree state: unmodified with respect to the declared write set. No production or test file had been
edited at the time of this run.

Command:

```text
mcp__drm-copilot__run_poshqc_test  workspace_root="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a931fa47c98f755c3"
```

EXIT_CODE: 0

MCP result:

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a931fa47c98f755c3","summary":"Ran bundled PoshQC test against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a931fa47c98f755c3'."}
```

## Route Used for the Coverage Numbers

The MCP runner reads its settings from the installed extension rather than from this checkout, so a
coverage entry that exists only in this repository can be absent from the MCP run's output. That
hazard did NOT materialize here.

The MCP run wrote both output files into this workspace and the coverage report contains a class
entry for the file under test:

```text
artifacts/pester/pester-junit.xml                  (1,451,409 bytes, written 2026-08-26 05:28)
artifacts/pester/powershell-coverage.xml           (  592,477 bytes, written 2026-08-26 05:27)
artifacts/pester/powershell-coverage.koverage.xml  (  585,053 bytes, written 2026-08-26 05:28)
```

**Route: the MCP run (`mcp__drm-copilot__run_poshqc_test`).** The fallback route — invoking the
self-hosted PoshQC module directly via `pwsh` — was not required, because the MCP run produced a
coverage row for `.claude/hooks/enforce-prd-feature-before-planner.ps1`. The class entry resolves to
package `.../.claude/hooks`, that is, the self-hosted copy and not the bundled mirror under
`extensions/drm-copilot/resources/`.

`artifacts/` is gitignored in this checkout, so the two XML files are not committed. Their numeric
contents are transcribed below.

## Extraction

The numbers below were read out of the two XML files by a parsing script, not estimated.

```text
pwsh -NoProfile -ExecutionPolicy Bypass -File <scratchpad>/extract-pester-baseline.ps1
```

Extraction EXIT_CODE: 0

Raw extraction output:

```text
ROOT_ATTR_tests=3592
ROOT_ATTR_failures=0
ROOT_ATTR_errors=0
ROOT_ATTR_disabled=9
SUITE_COUNT=148
SUM_tests=3592
SUM_failures=0
SUM_errors=0
SUM_skipped=9
SUM_disabled=0
COMPUTED_passed=3583
TARGET_SUITE_MATCHES=1
TARGET_SUITE_NAME=C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a931fa47c98f755c3\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.Tests.ps1
TARGET_ATTR_tests=47
TARGET_ATTR_failures=0
TARGET_ATTR_errors=0
TARGET_ATTR_skipped=0
TARGET_ATTR_disabled=0
TARGET_TESTCASE_COUNT=47
TARGET_TESTCASE_FAILED=0
TARGET_TESTCASE_SKIPPED=0
TARGET_PASSED=47
REPORT_COUNTER_INSTRUCTION_missed=416_covered=9152
REPORT_COUNTER_LINE_missed=267_covered=6656
REPORT_COUNTER_METHOD_missed=27_covered=577
REPORT_COUNTER_CLASS_missed=0_covered=82
OVERALL_LINE_covered=6656
OVERALL_LINE_missed=267
OVERALL_LINE_total=6923
OVERALL_LINE_PERCENT=96.14
CLASS_PACKAGE=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a931fa47c98f755c3/.claude/hooks
CLASS_NAME=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a931fa47c98f755c3/.claude/hooks/enforce-prd-feature-before-planner
CLASS_LINE_covered=84
CLASS_LINE_missed=9
CLASS_LINE_total=93
CLASS_LINE_PERCENT=90.32
```

## Baseline Test Counts (from `artifacts/pester/pester-junit.xml`)

| Metric | Baseline value |
| --- | --- |
| Total tests | 3592 |
| Passed | 3583 |
| Failed | 0 |
| Skipped | 9 |
| Errors | 0 |
| Test suites (files) | 148 |
| Wall time | 111.493 s |

The root `<testsuites>` element carries `tests="3592" errors="0" failures="0" disabled="9"`. Summing
the 148 child `<testsuite>` elements reproduces `tests=3592`, `failures=0`, `errors=0`, and
`skipped=9`; Pester records the skipped total on the root element's `disabled` attribute and on each
child's `skipped` attribute, so the two spellings describe the same 9 tests. Passed is therefore
3592 minus 0 failed minus 0 errored minus 9 skipped, which equals 3583.

## Baseline Per-File Passed Count

| Test file | Tests | Passed | Failed | Skipped |
| --- | --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | 47 | **47** | 0 | 0 |

Exactly one `<testsuite>` in the JUnit report matched that file name. Its `tests` attribute is 47,
it carries 47 `<testcase>` children, and none of those children carries a `<failure>` or `<skipped>`
element. The baseline passed count for this file is **47**. [P3-T1] compares its post-change passed
count against this value.

## Baseline Coverage (from `artifacts/pester/powershell-coverage.xml`, JaCoCo format)

Overall, report-level `LINE` counter:

| Metric | Baseline value |
| --- | --- |
| Lines covered | 6656 |
| Lines missed | 267 |
| Lines total | 6923 |
| **Overall line coverage** | **96.14 %** |

Per-file, class entry whose `sourcefilename` is `enforce-prd-feature-before-planner.ps1` in package
`.../.claude/hooks`:

| Metric | Baseline value |
| --- | --- |
| Lines covered | 84 |
| Lines missed | 9 |
| Lines total (analyzable) | 93 |
| **Per-file line coverage for `.claude/hooks/enforce-prd-feature-before-planner.ps1`** | **90.32 %** |

The per-file denominator of 93 is the analyzable-line count Pester instruments, not the file's 305
physical lines recorded in [P0-T2]. The file's `INSTRUCTION` counter is 105 covered and 13 missed.

Per `.claude/rules/quality-tiers.md` and `.claude/rules/powershell.md`, the applicable threshold is
line coverage at or above 85 percent. No branch-coverage gate applies to PowerShell, because Pester
does not measure branch coverage. Both the overall figure (96.14 %) and the per-file figure
(90.32 %) are above the 85 percent threshold at baseline.

Output Summary: The Pester baseline run completed successfully (EXIT_CODE 0) across 148 test files.
Test counts: 3583 passed, 0 failed, 9 skipped, out of 3592 total, in 111.493 seconds. The file
`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` contributed 47 tests, all
47 passing, with 0 failed and 0 skipped; 47 is the baseline per-file passed count that [P3-T1] must
not fall below. Overall line coverage is 96.14 percent (6656 of 6923 lines). Per-file line coverage
for `.claude/hooks/enforce-prd-feature-before-planner.ps1` is 90.32 percent (84 of 93 analyzable
lines, 9 missed). All four numeric values were read from the MCP run's own output files —
`artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` — so the MCP route
supplied every number and the direct self-hosted fallback route was not needed. No placeholder value
appears in this artifact.
