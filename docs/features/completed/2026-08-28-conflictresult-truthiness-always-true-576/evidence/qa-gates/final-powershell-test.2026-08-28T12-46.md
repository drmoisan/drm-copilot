# Final PowerShell Test Gate — [P6-T8]

Timestamp: 2026-08-28T12-46

Command: MCP tool `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a9456a3f1a21c9952`, then in the same task `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"`

EXIT_CODE: 0

ExpectedExitCode: 0

The `ExpectedExitCode:` value is the [P0-T11] baseline exit code, which was 0. The self-hosted run's
exit code was captured directly from the invoking shell, not through a pipe.

## MCP Tool Result

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a9456a3f1a21c9952","summary":"Ran bundled PoshQC test against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a9456a3f1a21c9952'."}
```

| Field | Value |
| --- | --- |
| `ok` | `true` |
| Verbatim `summary` | `Ran bundled PoshQC test against 'C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a9456a3f1a21c9952'.` |

## Self-Hosted Run — Verbatim `Tests Passed:` Line

```
Tests Passed: 3839, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
```

| Category | [P0-T11] baseline | This run | Required | Met |
| --- | --- | --- | --- | --- |
| Passed | 3837 | 3839 | exactly baseline + 2 = 3839 | Yes |
| Failed | 0 | 0 | not higher than baseline (0) | Yes |
| Skipped | 9 | 9 | not asserted | — |

The passed count is exactly two higher than the baseline. The failed count is 0, equal to the
baseline, so no failing test is named for either run.

Verbatim `Covered` line:

```
Covered 94.19% / 0%. 10,563 analyzed Commands in 88 Files.
```

## Two-Line Line-Coverage Comparison

Read from the JaCoCo `LINE` counter of the `sourcefile` element named `BlastRadius.psm1` in
`artifacts/pester/powershell-coverage.xml`:

```
  INSTRUCTION missed=0 covered=165
  LINE missed=0 covered=109
  METHOD missed=0 covered=8
  CLASS missed=0 covered=1
```

1. **[P0-T11] baseline line-coverage percentage for `.claude/lib/blast-radius/BlastRadius.psm1`:**
   100 percent, from LINE missed 0 and covered 109.
2. **This run's post-change percentage:** 100 percent, from LINE missed 0 and covered 109.

100 percent is at least the uniform 85 percent line threshold and is not below the baseline value. No
branch-coverage value is asserted, because Pester does not measure branch coverage.

## Supplementary Per-Suite Observations

| Suite | `testcase` elements | `status` `Passed` |
| --- | --- | --- |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1` | 29 | 29 |
| PowerShell parity suite BlastRadius.Parity.Tests.ps1 under tests/scripts/claude-lib/blast-radius | 76 | 76 |

Both suites are fully green. The parity-suite figure supports [P6-T12].

Output Summary: `EXIT_CODE: 0` with `ExpectedExitCode: 0`. The MCP tool returned `ok: true` with the
verbatim `summary` string
`Ran bundled PoshQC test against 'C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a9456a3f1a21c9952'.`
The self-hosted run's `Tests Passed:` line reports 3839 passed, exactly two higher than the [P0-T11]
baseline of 3837, and 0 failed, not higher than the baseline failed count of 0, so no failing test is
named. The two-line comparison records a baseline line-coverage percentage of 100 for
`.claude/lib/blast-radius/BlastRadius.psm1` and a post-change percentage of 100, at least 85 percent
and not below the baseline. This task discharges AC17 together with [P6-T6] and [P6-T7].
