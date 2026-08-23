# PowerShell test and coverage baseline — PoshQC test / Pester (Issue #500)

Timestamp: 2026-08-21T23:03:17Z
Issue: #500
Task: [P0-T14]

Command:
```
mcp__drm-copilot__run_poshqc_test (workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-21T17-16)
```
Coverage is enabled by the repository run settings at
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; the run emitted
`artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.koverage.xml`.

EXIT_CODE: 0

Output Summary:

Test counts, read from the `testsuites` element of `artifacts/pester/pester-junit.xml`:
- passed: **3116** (tests=3116 with failures=0 and errors=0)
- failed: **0**
- errors: **0**
- elapsed: 164.585 s

Coverage, read from the `report/counter` elements of
`artifacts/pester/powershell-coverage.koverage.xml`:

| Counter | Covered | Missed | Percentage |
| --- | --- | --- | --- |
| LINE | 5792 | 228 | **96.21%** |
| INSTRUCTION | 8115 | 334 | 96.05% |
| METHOD | 491 | 25 | 95.16% |
| CLASS | 70 | 0 | 100.00% |

Line coverage is **96.21%** (5792 / 6020), computed as `covered / (covered + missed)`.

**Pester measures no branch coverage.** The counter set it emits is INSTRUCTION, LINE, METHOD, and
CLASS; there is no BRANCH counter in any output format. Per `.claude/rules/quality-tiers.md` and
`.claude/rules/general-unit-test.md`, the 75% branch threshold therefore does not apply to
PowerShell. This is a threshold exemption only: PowerShell production files remain in the coverage
denominator under the Coverage Exclusion Policy.

Threshold status at baseline: line 96.21% >= 85%. The applicable threshold is met before the change.
