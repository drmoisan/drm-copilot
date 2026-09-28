# Fail-before — `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` against the unfixed hook (issue #545)

Timestamp: 2026-09-07T15-28

Task: [P10-T14] `[expect-fail]`

TOOLCHAIN_SUBSTITUTION: the folder-scoped `mcp__drm-copilot__run_poshqc_test` route was used in place
of the plan's `Invoke-Pester -Path <suite>` form, which is not invocable in this session because
`pwsh`, `powershell`, and `cmd` cannot be invoked from any context here. Per-suite and per-case
results, including each failure message, were read out of `artifacts/pester/pester-junit.xml`.

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31` and
`scan_folders=["tests/scripts/claude-hooks"]`

EXIT_CODE: 4

ExpectedExitCode: 1

The exit code the MCP runner reports is the folder-wide failed-test count rather than a plain 1. Of
those 4, **3** belong to the suite this task drives and 1 is the documented pre-existing
`enforce-pr-author-skill.Tests.ps1` failure. The declared expectation of 1 records that a non-zero,
failing outcome is the intended result of this task; the observed value is non-zero as required.

## Suite result — before [P10-T15]

`tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1`: **3 tests, 3
failures, 0 errors, 0 skipped. Every case in the suite fails.**

| # | `It` name | Result | Observed failure message |
| --- | --- | --- | --- |
| 1 | `AT-11 takes a grep whose quoted search term is the disposition token out of scope` | **FAIL** | `Expected: 'allow' But was: 'deny'` |
| 2 | `AT-12 brings the equals-joined spelling of the disposition option into scope` | **FAIL** | `Expected $true, but got $false.` |
| 3 | `does not accept a confirmation marker that sits in a different segment from the disposition token` | **FAIL** | `Expected: 'deny' But was: 'allow'` |

All three trace to the same cause: the gate collapses whitespace and then asks whether the WHOLE
command string contains a literal, so it can distinguish neither a mention from an invocation nor one
segment from another.

- Case 1 is **over-match**: `grep -n "--disposition abandon" scripts/dev_tools/parallel_mutation_abandon_cli.py`
  searches the source for the token. Nothing on that line abandons anything, but the containment test
  sees the literal inside the quoted search term and denies.
- Case 2 is **under-match**: `--disposition=abandon` is the same invocation to the producer's
  `argparse` registration, but contains no `--disposition abandon` substring, so the gate never
  fires. The executed pre-change confirmation of that returned `$false` is recorded separately in
  `evidence/regression-testing/at12-runtime-confirmation.2026-09-07T15-25.md`, as spec D11.6 requires.
- Case 3 is a **confirmation-scope** defect: `echo --confirm-abandon && run --disposition abandon`
  carries the confirmation marker in a segment that has nothing to do with the abandon, and the
  whole-string containment accepts it as an acknowledgement.

## Existing suite state in the same run

`tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1`: **24 tests, 0 failures**, equal
to its [P0-T10] baseline passed count of 24. Every case listed individually in the run passed,
including `allows when the confirmation marker precedes the disposition token` at line 62, which the
[P10-T16] acceptance requires to remain passing unmodified after the fix.

## Known-red inventory update

The three failing names above are appended to the [P1-T13] known-red inventory as rows 39 through 41,
each carrying **phase 10** as the closing phase and [P10-T15] as the closing task. The inventory stood
at 0 rows remaining after [P10-T3] closed rows 35 through 38; it now stands at **3 of 41 rows
remaining**, all three closing within this same phase.

Output Summary: fail-before captured as required. The suite reports **3 tests / 3 failures** against
the unfixed hook, with a non-zero exit code; every case in the suite fails and each failure message is
recorded verbatim above. The three defects are the AT-11 over-match on a quoted search term, the AT-12
under-match on the equals-joined spelling, and the acceptance of a confirmation marker from an
unrelated segment. The existing `enforce-parallel-abandon-gate.Tests.ps1` suite is green at
**24 tests / 0 failures**, equal to its baseline. The three failing names were appended to the
known-red inventory with phase 10 recorded as the closing phase.
