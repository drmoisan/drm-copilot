# Verification-module per-file coverage after the P2-T19 through P2-T22 coverage-shortfall remediation

Timestamp: 2026-08-26T01-13

Filename-stamp substitution: the plan fixes every evidence filename at `.2026-08-24T13-10.md`. This
artifact was produced on a later date, so the executor substituted its own `yyyy-MM-ddTHH-mm` stamp
`2026-08-26T01-13` into that same position, per the "Evidence filename timestamps" rule of the plan.
The path prefix and base name are unchanged.

Command: `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"`

EXIT_CODE: 3

The non-zero exit code is the count of the three deliberate Phase 1 `[expect-fail]` regression tests,
which Phases 3 and 4 turn green. It is not attributable to this task. See "Full-suite state" below.

## Measurement route

The figure below was obtained by the DIRECT self-hosted invocation named in the plan's "Per-file
coverage measurement route", not by `mcp__drm-copilot__run_poshqc_test`. The MCP tool resolves its
Pester runsettings from the installed VS Code extension bundle, which carries no `CodeCoverage.Path`
entry for `scripts/dev-tools/Invoke-ReleaseVerification.ps1`, so it emits no coverage row at all for
that file. A missing row from the MCP runner is a tooling-path artifact and was not read as a
coverage failure. The direct invocation was run LAST, after the MCP test-stage gate run, because both
runners write the same `artifacts/pester/powershell-coverage.xml` path.

The row was parsed by keying on the enclosing `package` element (full directory path), never on the
bare `sourcefile` name:

- `package` name: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3c3e2a8cfa4dbcd5/scripts/dev-tools`
- `sourcefile` name: `Invoke-ReleaseVerification.ps1`

## Output Summary

Per-file line coverage of `scripts/dev-tools/Invoke-ReleaseVerification.ps1`:

- Covered lines: 83
- Missed lines: 9
- Total measured lines: 92
- Line coverage: 90.22 percent

Prior figures recorded before this remediation, for comparison:

- Covered lines: 76
- Total measured lines: 92
- Line coverage: 82.61 percent

Delta: +7 covered lines, +7.61 percentage points. The covered-line count 83 is strictly greater than
the recorded prior value of 76, and 90.22 percent is at or above the uniform 85 percent line-coverage
threshold in `.claude/rules/quality-tiers.md` and `.claude/rules/general-unit-test.md`.

Test counts for `tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1`:

- Passed: 31
- Failed: 0

That file held 24 tests before this remediation; the seven tests added by P2-T19 through P2-T22
bring it to 31.

## The seven newly covered lines

Each was a distinct uncovered measured line whose guarding condition was already covered, so each
contributed a full +1.

| Line | Function | Branch |
| --- | --- | --- |
| 114 | `ConvertFrom-JsonSafely` | whitespace-only `return $null` |
| 121 | `ConvertFrom-JsonSafely` | `catch` `return $null` |
| 243 | `Resolve-PublishStepConclusion` | absent-JOB `return 'STEP_MISSING'` |
| 258 | `Resolve-PublishStepConclusion` | neither-skipped-nor-success fall-through |
| 340 | `Get-RecoveryInstruction` | lookup-miss `return ''` |
| 398 | `Get-CodexPinnedMcpVersion` | empty-content `return $null` |
| 404 | `Get-CodexPinnedMcpVersion` | regex-miss `return $null` |

## The nine remaining uncovered lines are deliberately uncovered

Observed uncovered line numbers: 57, 58, 74, 75, 92, 485, 496, 497, 498. This set is exactly the set
the plan prohibits covering, and it is unchanged by this remediation.

- Lines 57, 58 (`Invoke-GhExe` body), 74, 75 (`Invoke-NpmExe` body), and 92 (`Invoke-Sleep` body) are
  the three wrapper seams. Covering them requires spawning a real `gh` or `npm` process or taking a
  real wall-clock wait, which AC21 and AC22 prohibit.
- Lines 485, 496, 497, 498 are the entry-point block that the dot-source guard exists to keep from
  executing.

No test added by P2-T19 through P2-T22 reaches any of these nine lines.

## Test purity

Every test added by P2-T19 through P2-T22 is a pure-helper call requiring no seam. None references
`New-TemporaryFile`, `GetTempFileName`, the TEMP environment variable, `TestDrive`, or `Start-Sleep`,
and none invokes a real `npm`, `gh`, or `git` process. All JSON and config payloads are supplied as
in-memory string literals deserialized in the test. P7-T9 is the task that verifies this across the
file.

## Full-suite state

From the same direct run:

- Passed: 3614
- Failed: 3
- Skipped: 9
- Total test cases in `artifacts/pester/pester-junit.xml`: 3626

The three failures are exactly the deliberate Phase 1 `[expect-fail]` regression tests:

1. `pushes the mcp-server tag before the extension tag` — turns green at P3-T4.
2. `declares a pull_request trigger scoped to the mcp-server package and the workflow file` — turns
   green at P4-T1.
3. `guards the publish step on the tag ref and not on the event name` — turns green at P4-T2.

No other test failed. The count moved from 3607 passed before this work to 3614 passed, which is the
seven added tests and no regression.

## File-size check

`tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1` stands at 346 lines, against the
500-line cap in `.claude/rules/general-code-change.md`. It was 279 lines before this remediation.
`scripts/dev-tools/Invoke-ReleaseVerification.ps1` is unmodified by these tasks and remains at 499
lines; no production file was changed.
