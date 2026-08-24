# Pass-After — PowerShell Classifier Marker Rejection — [P3-T5]

Timestamp: 2026-08-23T02-06

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P3-T5]
State captured: POST-FIX, after the [P3-T3] guard was added and the [P3-T4] extension landed

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and
`scan_folders` set to `["tests/scripts/claude-lib/blast-radius"]`.

EXIT_CODE: 0 for the file under test

The run's overall exit code is 2, which is Pester's failed-test count. Both failures belong to
`BlastRadius.Manifest.Tests.ps1` and are the expected mid-sequence state of the plan, not a
regression of this file. They are itemized below.

## Source of every outcome below

The tool returns only an ok flag and a short summary, so every test name and outcome is read from
`artifacts/pester/pester-junit.xml`, not from the tool's return value.

Root element:

```xml
<testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="Pester" tests="393" errors="0" failures="2" disabled="0" time="29.389">
```

## The file under test reports zero failures

```xml
<testsuite name="...\tests\scripts\claude-lib\blast-radius\BlastRadiusTokenShape.Tests.ps1" tests="16" errors="0" failures="0" hostname="MEGALODON4" id="11" skipped="0" disabled="0" package="..." time="0.136">
```

16 tests, 0 errors, **0 failures**. The file grew from 5 cases at [P1-T3] to 16 at [P3-T4]: the five
marker cases now carry both halves of the paired assertion, plus the filename-position case, the
marker-free discrimination control, three degenerate-input cases, four relocated span cases, and the
module-export assertion.

## The same test names that failed in [P1-T4] now pass

| Test name | [P1-T4] fail-before | [P3-T5] pass-after |
| --- | --- | --- |
| `...rejects a token carrying the angle-open marker` (now `reports and rejects the marker case angle-open`) | FAILED | **Passed** |
| `...rejects a token carrying the angle-close marker` (now `...angle-close`) | FAILED | **Passed** |
| `...rejects a token carrying the delimited-variable interpolation marker` (now `...dollar-brace`) | FAILED | **Passed** |
| `...rejects a token carrying the subexpression interpolation marker` (now `...dollar-paren`) | FAILED | **Passed** |
| `...rejects a token carrying the percent marker` (now `...percent`) | FAILED | **Passed** |

The five case names were re-expressed at [P3-T4] when each case gained the predicate half of its
paired assertion, so the name now carries the marker identifier rather than the marker's prose
description. The identity of the five cases is unchanged: one per marker, same probe literal, same
classifier assertion, with a predicate assertion added. The immediately preceding run (before the
[P3-T4] extension) recorded the five original names as `Passed` with the same 0-failure suite
result, so the transition is on record under both namings.

## The two remaining failures are Phase 4's assigned work

| Failing test | Assigned to |
| --- | --- |
| `Blast-radius core.json manifest membership.Library coverage.lists every discovered library module in core.json paths` | [P4-T3] — register the new module in the bundled pack manifest |
| `Blast-radius core.json manifest membership.Bundled payload parity.ships a bundled counterpart for every library module` | [P4-T1] — create the bundled module mirror |

Both failures are caused by the same fact: the repository now contains
`.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`, and neither its manifest entry nor its
bundled counterpart exists yet. This is the plan's deliberate phase ordering — the module must
exist before it can be mirrored or registered — and both are closed by [P4-T6], whose acceptance
requires this manifest file to report zero failures.

No pre-existing test in the folder regressed: every other suite reports 0 errors and 0 failures.

## Toolchain stages for this task

| Stage | Command | Result |
| --- | --- | --- |
| format | `mcp__drm-copilot__run_poshqc_format` scoped to `.claude/lib/blast-radius` and the test folder | ok, no file rewritten |
| analyze | `mcp__drm-copilot__run_poshqc_analyze` scoped to the same two folders | ok |
| test | the command above | file under test 0 failures |

## File-size position after the phase

| File | Lines | Limit |
| --- | --- | --- |
| `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` | 187 | 500 |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | 472 | 500 |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1` | 197 | 500 |

The extraction module entered the phase at 498 lines, dropped to 449 after the [P3-T2] relocation,
and finished at 472 after the guard, its decision-logic comment, and the `.DESCRIPTION` amendment.
No task in the phase left any file above the limit at its own completion.

## Output Summary

Pass-after evidence established for the PowerShell runtime. `BlastRadiusTokenShape.Tests.ps1`
reports 16 tests, 0 errors, 0 failures, read from `artifacts/pester/pester-junit.xml`. The five
marker cases that failed at [P1-T4] now pass. The run's two remaining failures are the manifest
membership and bundled-parity assertions, both of which are Phase 4's assigned tasks and both of
which [P4-T6] gates. Format and analyze are clean.
