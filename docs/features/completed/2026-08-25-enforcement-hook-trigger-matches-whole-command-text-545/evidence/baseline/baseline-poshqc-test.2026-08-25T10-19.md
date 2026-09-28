# Phase 0 — Baseline PoshQC test (issue #545)

Timestamp: 2026-08-25T10-41

Task: [P0-T7]

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` =
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adcd2df193c6616e5`
(no `scan_folders` argument, so the scan set resolves from `config/poshqc-scan.json`:
`scripts`, `tests/powershell`, `tests/scripts`).

EXIT_CODE: 0

Raw tool result:

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adcd2df193c6616e5","summary":"Ran bundled PoshQC test against 'C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adcd2df193c6616e5'."}
```

## Freshness

This run was executed for this task; the result files were not read as they stood. The prior
contents were overwritten by this run. Freshness is confirmed by the coverage report attribute
`<report name="Pester (08/25/2026 10:28:00)">` and by `pester-junit.xml` carrying
`time="171.331"`, with the invocation issued at approximately 10:25 and the wrapper outputs
written at 10:40. The JaCoCo file's mtime (10:28) is earlier than its siblings' (10:40) because
Pester writes the coverage report mid-run while the wrapper writes the JUnit output at the end;
that skew is not staleness.

## Extraction, per the result-artifact extraction contract

### Test counts — `artifacts/pester/pester-junit.xml`

Read from the root `testsuites` element:

- `tests` = **3592**
- `failures` = **0**
- `errors` = **0**
- `disabled` = 9
- `time` = 171.331

Summed across the per-file `testsuite` elements:

- sum of `skipped` = **9**

The root element carries no `passed` attribute and no `skipped` attribute, so both figures are
derived, not read:

- passed = `tests - failures - errors - (summed skipped)` = 3592 - 0 - 0 - 9 = **3583**

### Coverage — `artifacts/pester/powershell-coverage.xml`

The document is JaCoCo-shaped, rooted at `report`, with 12 `package` children. There is no
`coverage` element and no `line-rate` attribute anywhere in it. Overall line coverage is computed
from the report-level `counter` element whose `type` attribute is `LINE` — the direct child of the
root `report` element:

- `missed` = 267
- `covered` = 6656
- overall line coverage = `covered / (covered + missed)` = 6656 / 6923 = **96.1433%**

## Output Summary

- Passed: **3583** (derived: 3592 tests - 0 failures - 0 errors - 9 summed skipped)
- Failed: **0** (root `testsuites/@failures`)
- Skipped: **9** (summed across per-file `testsuite/@skipped`)
- Overall line coverage: **96.1433%** (report-level `counter[@type='LINE']`, 6656 covered of 6923)

No placeholder value is recorded and no threshold is asserted against the coverage percentage.

## Consequence for the batch toolchain gate

The baseline failed count is **zero**. Under the batch toolchain gate definition in the plan's
Change budget and batching section, each batch gate ([P4-T6], [P5-T7], [P5-T10], [P6-T6],
[P6-T12], [P7-T5], [P7-T9], [P8-T6], [P8-T9]) is therefore satisfied only by exit code 0 on all
three stages. The zero-delta alternative does not apply.

Note on the coverage aggregate: this figure comes from the MCP runner, which instruments coverage
from the installed extension's runsettings rather than either in-repo copy. It is recorded for
information only. The per-file 85% gate is enforced through the self-hosted route in [P0-T8],
[P7-T8], [P9-T9], [P11-T4], and [P11-T7].
