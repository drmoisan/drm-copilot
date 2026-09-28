# PowerShell Pester Baseline (P0-T5)

Timestamp: 2026-08-25T23-33

Filename-stamp substitution: plan-fixed suffix `.2026-08-24T13-10.md` replaced with
`.2026-08-25T23-33.md` for this execution date. Path prefix and base name unchanged.

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3c3e2a8cfa4dbcd5`
(coverage enabled by `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`)

EXIT_CODE: 0

## Runner Attribution

The numbers below were produced by the MCP runner `mcp__drm-copilot__run_poshqc_test`. The known
tooling trap — the MCP runner resolving its Pester runsettings from the installed VS Code extension
rather than from the in-repo settings file — did not obstruct this task: the run emitted a coverage
row for `scripts/dev-tools/Invoke-ReleaseTagPush.ps1`, which is already registered in the
`CodeCoverage.Path` allow-list. The documented fallback (importing
`./scripts/powershell/PoshQC/PoshQC.psd1 -Force` and calling `Invoke-PoshQCTest`) was therefore not
required and was not used.

Raw MCP result:

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a3c3e2a8cfa4dbcd5","summary":"Ran bundled PoshQC test against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a3c3e2a8cfa4dbcd5'."}
```

`ok: true` is the success signal and is recorded as `EXIT_CODE: 0`.

## Test Counts

Parsed from `artifacts/pester/pester-junit.xml` (root element attributes plus `testcase` node
counts).

| Metric | Value |
|---|---|
| Total tests | 3592 |
| Passed | 3583 |
| Failed | 0 |
| Skipped | 9 |
| Errors | 0 |
| Wall time (seconds) | 116.053 |

Passed is derived as total `testcase` nodes (3592) minus `failure` child nodes (0) minus `skipped`
child nodes (9).

## Overall Line Coverage

Parsed from the report-level `LINE` counter of `artifacts/pester/powershell-coverage.xml`.

| Metric | Value |
|---|---|
| Lines covered | 6656 |
| Lines missed | 267 |
| Total lines | 6923 |
| Overall line coverage | 96.14% |

The overall figure is above the uniform 85% line-coverage threshold that
`.claude/rules/quality-tiers.md` applies at every tier.

For reference, the report-level `INSTRUCTION` counter recorded 9152 covered and 416 missed. Pester
reports command (instruction) coverage for information only, with no threshold attached, and does
not measure branch coverage; no branch threshold is asserted.

## Per-File Counts — `scripts/dev-tools/Invoke-ReleaseTagPush.ps1`

Parsed by keying on the enclosing `package` element (the full directory path), not on the bare
`sourcefile` name. Exactly one `package`/`sourcefile` pair matched, so the attribution is
unambiguous:

- `package name` = `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3c3e2a8cfa4dbcd5/scripts/dev-tools`
- `sourcefile name` = `Invoke-ReleaseTagPush.ps1`

| Metric | Value |
|---|---|
| Lines covered | 46 |
| Lines missed | 2 |
| Total lines | 48 |
| Line coverage | 95.83% |

Instruction counter for the same file: 62 covered, 5 missed. Method counter: 6 covered, 1 missed.

Output Summary: PoshQC test completed successfully with `ok: true`, recorded as exit code 0. 3592
tests ran: 3583 passed, 0 failed, 9 skipped, 0 errors, in 116.053 seconds. Overall line coverage is
96.14% (6656 covered of 6923 total). The file this change modifies,
`scripts/dev-tools/Invoke-ReleaseTagPush.ps1`, is already in the coverage denominator and stands at
95.83% line coverage (46 covered of 48 total). The suite is green at the baseline commit
`afbf51dfe6508319a2d673603d31825077d8cddb`, which is the precondition for the deliberately-red
`[expect-fail]` runs of Phase 1 to be attributable to the tests those tasks add. All values recorded
above are numeric; no placeholder is used. These are the baseline figures P7-T6 compares its
post-change numbers against.
