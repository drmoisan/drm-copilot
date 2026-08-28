# PowerShell Conflict Tests After the Pester Additions — [P4-T5]

Timestamp: 2026-08-28T12-46

Command: MCP tool `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a9456a3f1a21c9952`, then in the same task `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"`

EXIT_CODE: 0

The self-hosted invocation's exit code was captured directly from the invoking shell, not through a
pipe.

## MCP Tool Result

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a9456a3f1a21c9952","summary":"Ran bundled PoshQC test against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a9456a3f1a21c9952'."}
```

No count and no coverage value is read from this payload; it carries none.

## Self-Hosted Run — Verbatim `Tests Passed:` Line

```
Tests Passed: 3839, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
```

| Category | [P0-T11] baseline | This run | Required | Met |
| --- | --- | --- | --- | --- |
| Passed | 3837 | 3839 | exactly baseline + 2 = 3839 | Yes |
| Failed | 0 | 0 | not higher than baseline (0) | Yes |
| Skipped | 9 | 9 | not asserted | — |

The passed count is exactly two higher than the baseline, matching the two `It` blocks added by
[P4-T3] and [P4-T4]. The failed count is 0, equal to the baseline, so no failing test is named for
either run.

Verbatim `Covered` line:

```
Covered 94.19% / 0%. 10,563 analyzed Commands in 88 Files.
```

## Per-`It` Status, Read from the Pester JUnit XML

The console output is produced at Pester's `Normal` verbosity, which never prints the name of a
passing `It`, so per-`It` status is read from the `testcase` elements of the JUnit XML under
artifacts/pester rather than from the console.

| `testcase` name | `status` | `classname` |
| --- | --- | --- |
| `Test-BlastRadiusConflict result shape.The documented return contract.returns the conflict verdict and a reasons collection` | `Passed` | `...\tests\scripts\claude-lib\blast-radius\BlastRadius.Conflict.Tests.ps1` |
| `Test-BlastRadiusConflict result shape.The documented return contract.is unconditionally truthy even when its conflict key is false` | `Passed` | `...\tests\scripts\claude-lib\blast-radius\BlastRadius.Conflict.Tests.ps1` |
| `Test-BlastRadiusConflict result shape.The documented return contract.documents the truthiness divergence in its comment-based help` | `Passed` | `...\tests\scripts\claude-lib\blast-radius\BlastRadius.Conflict.Tests.ps1` |

The first row is the pre-existing `It` whose `testcase` name ends with the phrase `returns the
conflict verdict and a reasons collection`; it is the frozen two-key result-shape assertion. The
second row is the `It` added by [P4-T3]; the third is the `It` added by [P4-T4]. All three `status`
attributes read `Passed`.

## Blast-Radius Module Line Coverage

Read from the JaCoCo `LINE` counter of the `sourcefile` element named `BlastRadius.psm1` in
`artifacts/pester/powershell-coverage.xml`:

```
  INSTRUCTION missed=0 covered=165
  LINE missed=0 covered=109
  METHOD missed=0 covered=8
  CLASS missed=0 covered=1
```

| Measure | [P0-T11] baseline | This run |
| --- | --- | --- |
| LINE missed | 0 | 0 |
| LINE covered | 109 | 109 |
| Derived line coverage | 100 percent | **100 percent** |

100 percent is at least the 85 percent uniform line threshold and is not lower than the baseline
value. No branch-coverage value is asserted, because Pester does not measure branch coverage.

## Supplementary Observation — PowerShell Parity Suite

The PowerShell parity suite BlastRadius.Parity.Tests.ps1 under tests/scripts/claude-lib/blast-radius
reported 76 `testcase` elements in this run, of which 76 read `status` `Passed` and 0 read anything
else. It is recorded here as a supporting observation for [P6-T12].

Output Summary: `EXIT_CODE: 0`. The MCP tool returned `ok: true` with the verbatim `summary` string
`Ran bundled PoshQC test against 'C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a9456a3f1a21c9952'.`
The self-hosted run's `Tests Passed:` line reports 3839 passed, exactly two higher than the [P0-T11]
baseline of 3837, with a failed count of 0 that is not higher than the baseline failed count of 0, so
no failing test is named. The three `testcase` elements named above — the two `It` blocks added by
[P4-T3] and [P4-T4] and the pre-existing result-shape `It` — all read `status` `Passed` in the JUnit
XML. The derived line coverage for `.claude/lib/blast-radius/BlastRadius.psm1` is 100 percent from a
JaCoCo `LINE` counter of missed 0 and covered 109, at least 85 percent and not lower than the
baseline. This task discharges AC15, and together with [P6-T12] it discharges AC8.
