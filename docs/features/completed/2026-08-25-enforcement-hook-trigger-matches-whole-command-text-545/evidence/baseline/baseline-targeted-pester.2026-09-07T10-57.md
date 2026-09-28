# Phase 0 — Baseline Per-Suite Pester Results, Eight Named Suites

Timestamp: 2026-09-07T10-57

Task: [P0-T10]

Command (as mandated by the plan, ATTEMPTED FIRST, one per suite):
`pwsh -NoProfile -Command "Invoke-Pester -Path <suite> -Output Detailed"`

Command:
`mcp__drm-copilot__run_poshqc_test` with `workspace_root=C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a478b73e41951af31` — the same single run recorded in [P0-T7], whose JUnit report carries one `<testsuite>` element per suite file; per-suite figures read from `artifacts/pester/pester-junit.xml` by `python scratchpad/suite_summary.py`

EXIT_CODE: 2

The exit code 2 belongs to the whole-repository run and is caused by the two pre-existing failures
named in [P0-T7], both of which are in suites **other than** the eight below. All eight suites below
report zero failures.

## Route deviation

The mandated targeted `pwsh` invocation was refused by the runtime worktree-isolation guard, in the
same terms recorded in [P0-T7]; no process started and no exit code was produced. Per-suite results
were therefore taken from the JUnit report of the single whole-repository run. The substitution is
sound for the figures this task requires: Pester emits one `<testsuite>` element per test **file**,
carrying that file's own `tests`, `failures`, `errors`, and `skipped` attributes, so the per-suite
counts are exactly the counts a per-file run would report. What the substitution does **not**
reproduce is per-file run isolation; a suite that passes only because another suite ran first would
not be detected here. No suite below depends on another for its result, and all eight are
zero-failure, so the distinction does not change any figure recorded.

## Per-suite results

| # | Suite | Tests | Passed | Failed | Errors | Skipped | Time (s) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `tests/scripts/claude-hooks/validate-bash.Tests.ps1` | 26 | **26** | **0** | 0 | 0 | 0.239 |
| 2 | `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1` | 24 | **24** | **0** | 0 | 0 | 0.232 |
| 3 | `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` | 45 | **45** | **0** | 0 | 0 | 0.486 |
| 4 | `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` | 46 | **46** | **0** | 0 | 0 | 0.868 |
| 5 | `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` | 56 | **56** | **0** | 0 | 0 | 0.848 |
| 6 | `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1` | 9 | **9** | **0** | 0 | 0 | 0.292 |
| 7 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | 35 | **35** | **0** | 0 | 0 | 0.368 |
| 8 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | 58 | **58** | **0** | 0 | 0 | 0.544 |

Totals across the eight suites: 299 tests, 299 passed, 0 failed, 0 errors, 0 skipped.

Two of these counts are cited by later phases and are recorded explicitly so they can be compared
after the change:

- `enforce-parallel-abandon-gate.Tests.ps1` holds **24** cases, matching the "24 existing cases"
  the spec's acceptance criteria state must pass unmodified.
- `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` holds **58** cases. One
  of them reverses in [P1-T8] and one is added, so the post-[P1-T8] count is expected to be 59.

## Verbatim run-summary line for the first suite

The plan requires one verbatim run-summary line, observed on a successful run, so that later
assertions are written against observed output rather than inferred output. The first suite,
`tests/scripts/claude-hooks/validate-bash.Tests.ps1`, passed with zero failures, and its
run-summary record is reproduced here **verbatim** from `artifacts/pester/pester-junit.xml`:

```
<testsuite name="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a478b73e41951af31\tests\scripts\claude-hooks\validate-bash.Tests.ps1" tests="26" errors="0" failures="0" hostname="MEGALODON4" id="39" skipped="0" disabled="0" package="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a478b73e41951af31\tests\scripts\claude-hooks\validate-bash.Tests.ps1" time="0.239">
```

This is machine-emitted output from a successful run of that suite, not a reconstruction. Its shape
is the authority for any later assertion over per-suite results: the attributes available are
`name`, `tests`, `errors`, `failures`, `hostname`, `id`, `skipped`, `disabled`, `package`, and
`time`. Note in particular that **there is no `passed` attribute**; a passed count must be derived as
`tests - failures - errors - skipped`. An acceptance condition asserting a literal `passed=` field in
this output would be unsatisfiable.

For completeness, the console line the PoshQC module replays is built by the format string at
`scripts/powershell/PoshQC/PoshQC.Testing.psm1` line 424,
`"Tests Passed: {0}, Failed: {1}, Skipped: {2}, Inconclusive: {3}, NotRun: {4}"`. That is quoted from
the module source as a **format string**, not as observed output: the MCP route does not surface the
replayed console text, so no assertion in later phases may be written against that line's rendered
form on the strength of this artifact.

## Failing tests in these eight suites

None. All eight suites report `failures="0"` and `errors="0"`.

Output Summary: All eight named suites pass at baseline with zero failures and zero skips: 26, 24,
45, 46, 56, 9, 35, and 58 tests respectively, 299 in total, all passing. One verbatim run-summary
record is reproduced for the first suite, `validate-bash.Tests.ps1`, showing `tests="26"`
`failures="0"` `errors="0"` `skipped="0"` `time="0.239"`, and the absence of any `passed` attribute
is recorded so later assertions derive that value rather than expecting it in the output. The
mandated per-suite `pwsh` invocation was refused by the runtime worktree-isolation guard; figures
came from the per-file `<testsuite>` elements of the [P0-T7] run.
